## 0.0.2

- Updated native SDK dependencies to 0.0.2 (Android Maven Central + iOS CocoaPods/SPM).
- Added `offeringId` field to `AppActorPackage` for purchase analytics attribution.
- Native pipeline hardening: partial batch sync recovery, dead-letter retry at startup, identity transition buffer overflow handling.
- Native storage improvements: receipt queue persist failure recovery with graceful degradation.
- Native error reporting: structured rate-limit information (`scope`, `retryAfterSeconds`) now available on `AppActorError` — fields were already present in the Dart model since 0.0.1.
- iOS: fixed 304 cache inconsistency fallback and cross-user cache guard.

## 0.0.1

- Initial release of AppActor Flutter SDK.
