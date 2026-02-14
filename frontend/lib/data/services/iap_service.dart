import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../core/config/app_config.dart';
import 'pocketbase_service.dart';
import 'premium_service.dart';

const String _productId = 'premium';

/// IAP service: buy/restore Premium, verify via backend, deliver to PremiumService.
class IapService {
  IapService(this._premiumService, PocketbaseService pbService)
      : _baseUrl = AppConfig.baseUrl.replaceAll(RegExp(r'/$'), ''),
        _pbService = pbService;

  final PremiumService _premiumService;
  final String _baseUrl;
  final PocketbaseService _pbService;

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _isInitialized = false;

  /// Initialize and listen to purchase stream. Call early (e.g. from main).
  Future<void> initialize() async {
    if (_isInitialized) return;
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (e) => debugPrint('[IapService] purchaseStream error: $e'),
    );
    _isInitialized = true;
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _isInitialized = false;
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final p in purchases) {
      if (p.status == PurchaseStatus.purchased ||
          p.status == PurchaseStatus.restored) {
        _verifyAndDeliver(p);
      } else if (p.status == PurchaseStatus.error) {
        debugPrint('[IapService] purchase error: ${p.error}');
      }
    }
  }

  Future<void> _verifyAndDeliver(PurchaseDetails p) async {
    try {
      final verified = await verifyPurchaseWithBackend(p);
      if (verified) {
        await _premiumService.setPremiumPurchased();
        if (p.pendingCompletePurchase) {
          await _iap.completePurchase(p);
        }
      }
    } catch (e) {
      debugPrint('[IapService] verify failed: $e');
    }
  }

  /// Call POST /api/iap/verify with platform, receipt/token, device_id.
  Future<bool> verifyPurchaseWithBackend(PurchaseDetails p) async {
    await _pbService.initialize();
    final deviceId = await getOrCreateDeviceId();

    final source = p.verificationData.source;
    final platform = source == 'AppStore' ? 'ios' : 'android';
    final serverData = p.verificationData.serverVerificationData;

    final body = <String, dynamic>{
      'platform': platform,
      'device_id': deviceId,
      'product_id': p.productID,
    };

    if (platform == 'ios') {
      body['receipt_data'] = serverData;
    } else {
      // Android: serverVerificationData can be raw token or JSON
      body['purchase_token'] = _extractPurchaseToken(serverData);
      if (body['purchase_token'] == null || (body['purchase_token'] as String).isEmpty) {
        debugPrint('[IapService] Android: could not extract purchase_token');
        return false;
      }
    }

    final uri = Uri.parse('$_baseUrl/api/iap/verify');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      final err = jsonDecode(response.body) as Map<String, dynamic>?;
      debugPrint('[IapService] verify API error: ${err?['error'] ?? response.body}');
      return false;
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>?;
    return data?['verified'] == true;
  }

  /// Android serverVerificationData may be raw token or JSON with purchaseToken.
  String? _extractPurchaseToken(String serverData) {
    final trimmed = serverData.trim();
    if (trimmed.isEmpty) return null;
    if (!trimmed.startsWith('{')) return trimmed; // raw token
    try {
      final map = jsonDecode(trimmed) as Map<String, dynamic>?;
      return map?['purchaseToken'] as String? ?? map?['purchase_token'] as String?;
    } catch (_) {
      return trimmed;
    }
  }

  /// Start purchase flow. Returns when user completes or cancels.
  Future<bool> buyPremium() async {
    if (!await _iap.isAvailable()) {
      debugPrint('[IapService] IAP not available');
      return false;
    }
    final products = await _iap.queryProductDetails({_productId});
    if (products.notFoundIDs.isNotEmpty || products.productDetails.isEmpty) {
      debugPrint('[IapService] product not found: $_productId');
      return false;
    }
    final purchaseParam = PurchaseParam(productDetails: products.productDetails.first);
    return _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  /// Restore previous purchases.
  Future<void> restorePurchases() async {
    if (!await _iap.isAvailable()) return;
    await _iap.restorePurchases();
  }
}
