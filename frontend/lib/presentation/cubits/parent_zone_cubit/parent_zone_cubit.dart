import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';

import 'parent_zone_state.dart';

class ParentZoneCubit extends Cubit<ParentZoneState> {
  ParentZoneCubit() : super(const ParentZoneInitial());

  final LocalAuthentication _auth = LocalAuthentication();

  /// Check device support and show appropriate UI
  Future<void> loadAuthStatus() async {
    emit(const ParentZoneInitial());

    try {
      final canCheckBiometrics = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();

      if (!isDeviceSupported && !canCheckBiometrics) {
        emit(const ParentZoneNotSupported());
        return;
      }

      emit(const ParentZoneAuthRequired(isSupported: true));
    } catch (e) {
      emit(const ParentZoneNotSupported());
    }
  }

  /// Trigger device auth (biometric or PIN/passcode)
  Future<void> authenticate(String localizedReason) async {
    try {
      final didAuthenticate = await _auth.authenticate(
        localizedReason: localizedReason,
        biometricOnly: false, // Allow fallback to PIN/passcode
      );

      if (didAuthenticate) {
        emit(const ParentZoneUnlocked());
      } else {
        emit(const ParentZoneAuthFailed());
      }
    } catch (e) {
      emit(ParentZoneAuthFailed(e.toString()));
    }
  }
}
