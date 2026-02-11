import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import 'pocketbase_service.dart';

/// Service kiểm tra trạng thái premium của user.
/// Gọi API / PocketBase khi cần thiết (ví dụ: trước khi mở chapter premium, mua sách).
@injectable
class PremiumService {
  PremiumService(this._pbService);
  final PocketbaseService _pbService;

  /// Kiểm tra user có premium không.
  /// Hiện tại: chưa có backend → luôn false.
  /// Sau khi có: gọi API/PocketBase (users.premium hoặc subscription table).
  Future<bool> checkIsPremium() async {
    try {
      if (!_pbService.isAuthenticated) return false;
      final user = _pbService.currentUser;
      if (user == null) return false;

      // TODO: Khi có premium logic - gọi API hoặc đọc field từ user
      // Ví dụ: return user.data['premium'] == true;
      // Hoặc: await _pb.collection('subscriptions').getFirstList(filter: 'user="${user.id}" && active=true');
      return false;
    } catch (e) {
      debugPrint('PremiumService.checkIsPremium error: $e');
      return false;
    }
  }

  /// Stream/cache nếu cần refresh thường xuyên (tùy chọn)
  /// Future<void> refreshPremiumStatus() async { ... }
}
