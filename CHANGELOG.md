# Changelog

## 0.0.24

- Added: `AppActorOffering.offeringKey` (the dashboard lookup key), `AppActorOfferings.getOffering(offeringKey)` / `offerings['key']` / `allOfferings` (current first), and `AppActor.instance.getOffering(offeringKey)` to fetch and look up in one call.
- Added: `AppActor.instance.getExperiment(key)` returns an `AppActorExperiment` that is never null — `isEnrolled`, `variantKey`, `isVariant(key)`, `boolValue / stringValue / intValue / doubleValue(defaultValue:)`, and `experiment['key']` for JSON payloads. `getExperimentAssignment` is unchanged underneath.
- Removed: `AppActorOfferings.offeringByLookupKey` — use `getOffering(offeringKey)` (a one-line rename).
- Updated the iOS native dependency to `AppActorPlugin 0.1.13`: the launch sweep now posts every unfinished StoreKit transaction and finishes each after the server accepts it, so older renewals no longer accumulate in `Transaction.unfinished`; unverified unfinished transactions are finished immediately. The native SDKs also gained the same offerings/experiments API.
- Updated the Android native dependency to `com.appactor:appactor-plugin:2.3.15` (same offerings/experiments API on the native side).

## 0.0.23

- Updated the Android native dependency to `com.appactor:appactor-plugin:2.3.14`: Google Play subscription purchases that do not name an explicit offer now auto-apply the best eligible offer Play returns for the base plan (longest free trial, else cheapest introductory price, else the base plan) — matching RevenueCat / Adapty. The native SDK also now exposes the resolved offer's pricing phases so trial/intro pricing can be surfaced. iOS is unaffected.

## 0.0.22

- Updated the Android native dependency to `com.appactor:appactor-plugin:2.3.13`: a Google Play subscription that names a specific offer (e.g. a free trial) now falls back to the base plan when Play omits that offer for a returning / trial-ineligible user, so the user is charged the standard price instead of being unable to subscribe. iOS is unaffected.

## 0.0.21

- Updated native dependencies to carry the cold-start improvements: iOS `AppActorPlugin 0.1.12` and Android `com.appactor:appactor-plugin:2.3.12` (cache-first/offline entitlement seeding at launch; skipped redundant device-attribute sync).

## 0.0.20

- Updated native dependencies to carry the audit-revision fixes: iOS `AppActorPlugin 0.1.11` (flutter-6 non-subscription `original_transaction_identifier`; ios-7 StoreKit product-cache TTL) and Android `com.appactor:appactor-plugin:2.3.11` (android-7 receipt-queue quarantine; android-12 bridge threading; android-25 date dedup).

## 0.0.19

- Updated the Android native dependency to `com.appactor:appactor-plugin:2.3.10` (AppActorPaymentProcessor god-class decomposition; behavior-preserving, public API unchanged). iOS native dependency stays at `AppActorPlugin 0.1.10`.

## 0.0.18

- **Breaking:** removed `AppActorPackage.toPurchaseParams()` and its deprecated `toJson()` alias. The purchase wire payload is built from `package_id` (plus optional `offering_id` / `old_purchase_token` / `replacement_mode` / `quantity` / `placement`); the native SDK resolves `product_id` / `store` / `base_plan_id` / `offer_id` server-side. (audit finding flutter-9)
- Fixed: a failed optional Apple Search Ads enable inside `configure()` no longer rejects the `configure()` Future after the core native configure has already succeeded. (audit finding flutter-1)
- Raised the iOS deployment target to `15.1` (from `15.0`).
- Updated native SDK dependencies to iOS `AppActorPlugin 0.1.10` and Android `appactor-plugin 2.3.9`, delivering the iOS/Android audit fixes (ios-2/3/16/17/19, android-3/4/6/10/19) to Flutter consumers.

## 0.0.17

- Updated native SDK dependencies to Android `2.3.8` and iOS `0.1.9` for Apple renewal coalescing cleanup hardening and current Android publication metadata.

## 0.0.16

- Updated native SDK dependencies to Android `2.3.7` and iOS `0.1.8` for profile context identity-transition hardening.

## 0.0.15

- Documented that native iOS/Android SDKs now automatically sync privacy-safe profile context during `configure()`.
- Clarified that `collectDeviceIdentifiers()` remains the explicit opt-in path for additional native identifiers.
- Updated native SDK dependencies to Android `2.3.6` and iOS `0.1.7`.

## 0.0.14

- Updated native SDK dependencies to Android `2.3.5` and iOS `0.1.6` for quiet `syncPurchases` parity and app-open renewal coalescing.
- Documented `syncPurchases()` as the quiet sync API while keeping `drainReceiptQueueAndRefreshCustomer()` as the explicit queue-drain API.

## 0.0.13

- Added optional Flutter purchase placement forwarding for `purchasePackage`; null or blank placements are omitted from the native payload.
- Updated native SDK dependencies to Android `2.3.4` and iOS `0.1.5` for purchase placement support.

## 0.0.12

- Updated native SDK dependencies to Android `2.3.3` and iOS `0.1.4` for attribution helper null-clear parity and Android quantity validation.
- Added Flutter-side purchase quantity validation for values below `1` while keeping native platforms responsible for supported quantity limits.
- Documented Android's current quantity limit and expanded attribution helper null-clear coverage.

## 0.0.11

- Updated native SDK dependencies to Android `2.3.2` and iOS `0.1.3` for polished customer attributes, integration identifiers, attribution helpers, and typed date payload parity.
- Added RevenueCat-style convenience helpers such as `setAppsflyerID`, `setAdjustID`, `setMediaSource`, and `setCampaign`.
- Tightened Flutter attribute validation so nulls require `unsetAttribute`, mixed arrays are rejected, and date values use a typed envelope.

## 0.0.10

- Updated native SDK dependencies to Android `0.1.3` and iOS `0.1.2` for queued transaction update source-intent parity.

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
