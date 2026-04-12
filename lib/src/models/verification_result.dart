/// The result of verifying a server response's cryptographic signature.
///
/// Exposed on [AppActorCustomerInfo] and [AppActorOfferings] so the app
/// can react to verification failures.
enum AppActorVerificationResult {
  /// Verification was not performed (signing disabled or transitional).
  notRequested,

  /// Response signature was successfully verified by the server.
  verified,

  /// Entitlements were verified on-device via StoreKit 2 (iOS only,
  /// offline / server unreachable).
  verifiedOnDevice,

  /// Response signature verification failed — possible tampering.
  failed;

  String get wireValue => name;

  /// Whether the result represents a trusted verification (server or device).
  bool get isVerified => this == verified || this == verifiedOnDevice;

  static AppActorVerificationResult fromString(String value) {
    for (final e in values) {
      if (e.wireValue == value || e.name == value) return e;
    }
    return notRequested;
  }
}
