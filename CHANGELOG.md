## 0.0.9

- Updated native SDK dependencies to Android `0.1.2` and iOS `0.1.1` for source intent receipt classification support.

## 0.0.8

- Updated native SDK dependencies to Android `0.1.1` and iOS `0.1.0`.
- Removed stale ASA diagnostics pending-user-id fields that are no longer emitted by the native iOS SDK.

## 0.0.7

- Updated the Android native dependency to `0.1.0`.
- Exposed optional package `price_amount_micros` parsing for Android price visibility while leaving iOS payloads compatible.

## 0.0.6

- Updated native SDK dependencies to `0.0.9` on Android Maven Central and iOS CocoaPods/SPM.
- Native: Android purchase lookup now resolves through `storeProductId` while preserving public product identifiers.
- Native: hardened identity-transition purchase update handling and remote config / experiment cache isolation.
- Native: iOS response signature checks now bind cacheable requests to the full path/query target.

## 0.0.5

- Updated native SDK dependencies to `0.0.8` on Android Maven Central and iOS CocoaPods/SPM.
- Breaking: removed `isConfigured()` to match the native plugin contract. `configure()` is now the readiness boundary and returns after native bootstrap completes.
- Added `configure(..., appUserId: ...)` so Flutter can start with an explicit identity or let native reuse/create the anonymous user during bootstrap.
- `configure()` now sends canonical nested `options.platform_info` metadata to the native plugins.

## 0.0.4

- Updated native SDK dependencies to 0.0.4 (Android Maven Central + iOS CocoaPods/SPM).
- Added `quietSyncPurchases()` and `drainReceiptQueueAndRefreshCustomer()` to match the new native plugin requests.
- `syncPurchases()` now follows native 0.0.4 behavior and drains the receipt queue before refreshing customer info.
- Refreshed README and example actions for the 0.0.4 purchase sync surface.

## 0.0.3

- Updated native SDK dependencies to 0.0.3 (Android Maven Central + iOS CocoaPods/SPM).
- Added `AppActorVerificationResult` enum — exposes server response signature verification status (`notRequested`, `verified`, `verifiedOnDevice`, `failed`).
- Added `verification` field to `AppActorCustomerInfo` and `AppActorOfferings`.
- Native: CDN-cacheable response signing (salt-based verification for offerings and remote config endpoints).
- Native: transient error cache fallback — network errors, 5xx, and rate-limit responses now return stale cache instead of failing.
- Native: always-network with ETag/304 optimization for `getCustomerInfo()` — removes stale cache window.
- Native: 304 cache miss recovery — retries without ETag instead of throwing.

## 0.0.2

- Updated native SDK dependencies to 0.0.2 (Android Maven Central + iOS CocoaPods/SPM).
- Added `offeringId` field to `AppActorPackage` for purchase analytics attribution.
- Native pipeline hardening: partial batch sync recovery, dead-letter retry at startup, identity transition buffer overflow handling.
- Native storage improvements: receipt queue persist failure recovery with graceful degradation.
- Native error reporting: structured rate-limit information (`scope`, `retryAfterSeconds`) now available on `AppActorError` — fields were already present in the Dart model since 0.0.1.
- iOS: fixed 304 cache inconsistency fallback and cross-user cache guard.

## 0.0.1

- Initial release of AppActor Flutter SDK.
