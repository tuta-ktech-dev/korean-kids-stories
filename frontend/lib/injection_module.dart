import 'package:injectable/injectable.dart';

import 'data/services/iap_service.dart';
import 'data/services/pocketbase_service.dart';
import 'data/services/premium_service.dart';
import 'data/services/tracking_service.dart';

/// Registers services that aren't annotated (e.g. singletons)
@module
abstract class InjectionModule {
  @lazySingleton
  PocketbaseService get pocketbaseService => PocketbaseService();

  @lazySingleton
  TrackingService get trackingService => TrackingService();

  @lazySingleton
  IapService iapService(PocketbaseService pb, PremiumService premium) =>
      IapService(premium, pb);
}
