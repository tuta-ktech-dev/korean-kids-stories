sealed class ParentZoneState {
  const ParentZoneState();
}

class ParentZoneInitial extends ParentZoneState {
  const ParentZoneInitial();
}

class ParentZoneAuthRequired extends ParentZoneState {
  final bool isSupported;

  const ParentZoneAuthRequired({this.isSupported = true});
}

/// Device does not support biometric/PIN - show fallback message
class ParentZoneNotSupported extends ParentZoneState {
  const ParentZoneNotSupported();
}

class ParentZoneAuthFailed extends ParentZoneState {
  final String? message;

  const ParentZoneAuthFailed([this.message]);
}

class ParentZoneUnlocked extends ParentZoneState {
  const ParentZoneUnlocked();
}
