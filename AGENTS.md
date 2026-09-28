# AGENTS.md

This file provides guidance to Codex (Codex.ai/code) when working with code in this repository.

## Project Overview

AppActor Flutter SDK — a Flutter plugin that wraps native AppActorPlugin SDKs (iOS/Android) to provide server-authoritative in-app purchase management. The Dart layer is intentionally thin; most business logic lives in the native SDKs.

## Common Commands

```bash
# Run Dart unit tests
flutter test

# Run a single test file
flutter test test/appactor_flutter_test.dart

# Analyze code (lint)
flutter analyze

# Build example app
cd example && flutter build ios --no-codesign
cd example && flutter build apk

# Run example app
cd example && flutter run
```

**Android native tests:**
```bash
cd android && ./gradlew test
```

## Architecture

### Plugin Channel Bridge Pattern

All Dart-native communication flows through a single `MethodChannel('appactor_flutter')`:

1. **`AppActor`** (`lib/src/appactor.dart`) — Public singleton facade (`AppActor.instance`). Exposes all SDK methods via 7 extensions in `lib/src/extensions/` (lifecycle, identity, purchase, data, config, streams, iOS). Wire method names are constants in `MethodNames` (`lib/src/internal/method_names.dart`), including the 0.0.4 purchase sync additions `quiet_sync_purchases` and `drain_receipt_queue_and_refresh_customer`.

2. **`AppActorPlatform`** (`lib/src/appactor_platform.dart`) — Platform bridge layer. Serializes params to JSON, sends via `invokeMethod('execute', ...)`, deserializes responses. Handles errors by checking for an `error` key in the response JSON and throwing `AppActorError`.

3. **Native plugins** receive an `execute` call with `method` + `json` string, delegate to the native AppActorPlugin SDK, and return a JSON string response. The response JSON has `success` or `error` at the top level. `AppActorPlatform.execute()` extracts the `success` field: if it's a Map, returns as-is; otherwise wraps as `{ 'value': success }` (e.g. booleans from `isConfigured()`).

### Event System

Native-to-Dart events flow through `MethodChannel` handler to broadcast `StreamController`s:
- `customer_info_updated` -> `onCustomerInfoUpdated` stream
- `receipt_pipeline_event` -> `onReceiptPipelineEvent` stream
- `sdk_log` -> auto-printed to console via `debugPrint()` (debug builds only, no listener needed)
- `purchase_intent_received` -> `onPurchaseIntent` stream (iOS only, promoted IAP / win-back offers)
- `deferred_purchase_resolved` -> `onDeferredPurchaseResolved` stream (Ask-to-Buy on iOS, pending purchases on Android)

Malformed events are silently dropped to prevent isolate crashes.

An app can run several Flutter engines (firebase_messaging's background handler on Android and flutter_local_notifications' background actions on iOS start one), but the native SDK has one event listener per process. Both native bridges therefore keep a list of attached engines and send each event to every engine whose Dart side has sent `listen`, which `AppActorPlatform.ensureInitialized()` does when it registers the handler; the listener starts with the first engine and stops when the last one detaches. Do not go back to one static channel: a second engine would take the events away from the app's own. An engine that never touches AppActor gets no events, because they would only pile up in its channel buffer, and on iOS a message to an engine that isn't running yet asserts. On iOS the plugin instance is published to the registrar because the engine calls `detachFromEngine(for:)` only on published objects, and it does so from its dealloc, so it may run off the main thread. When the last engine detaches, the native bridge drops its `onPurchaseIntent` callback and the native SDK buys a promoted purchase itself.

`purchase_intent_received` events wait in `AppActorPlatform._pendingPurchaseIntents` (up to 10, each good for 5 minutes like the native `PurchaseIntentStore`) until a listener is there, and `reset()` clears them. The controller is sync so a listener that cancels from its callback (`.first`, `take`) leaves the rest for the next one; a listener that pauses instead (`await for` with `break`) loses the ones queued behind the first.

### configure() and Hot Restart

`configure()` is idempotent: it checks `isConfigured()` before proceeding and calls `AppActorPlatform.ensureInitialized()` to re-register the method call handler. This is critical for Flutter hot restart, where the Dart VM restarts but native state persists — the event listener must be re-registered. `reset()` clears both native state and the Dart-side `_searchAdsTrackingEnabled` flag.

### Data Models (`lib/src/models/`)

All models are `@immutable` with manual `fromJson()` factory constructors (no code generation). Error classification uses code ranges: 1000-1999 = plugin errors, 2000+ = SDK errors. Transience is detected by parsing the `detail` string for `transient=true`. Complex dynamic JSON fields (e.g. remote config payloads) use a custom `deep_equals.dart` helper for recursive equality.

### Native Implementations

- **iOS** (`ios/Classes/AppActorFlutterPlugin.swift`): Swift 5.9+, min iOS 16, delegates to `AppActorPlugin`, uses `AppActorPluginDelegate` protocol for events. Dependency declared via CocoaPods (`AppActorPlugin`, `0.2.1`), resolved from the iOS SDK git repo.
- **Android** (`android/src/main/kotlin/.../AppActorFlutterPlugin.kt`): Kotlin 2.2.20, minSdk 26, compileSdk 36, JVM target Java 11. Implements `FlutterPlugin` + `ActivityAware`. Dependency: `com.appactor:appactor-plugin:2.4.3`, hosted on Maven Central — no additional authentication required.

### Public API Export

`lib/appactor_flutter.dart` is the single public barrel file — all public types are exported from here.

## Conventions

- Dart SDK constraint: `^3.11.4`, Flutter: `>=3.3.0`
- Linting: `flutter_lints` with `use_null_aware_elements` disabled
- No code generation (no build_runner, freezed, or json_serializable)
- No external state management or DI libraries
- JSON keys use `snake_case` in the wire format
- Enums serialize via `.wireValue` (maps to enum `name`); `fromString()` has fallback defaults for unknown values

## Key Gotchas

- **Version sync required**: `lib/src/sdk_version.dart` (`appActorSdkVersion`) must match `pubspec.yaml` version. Both must be updated on version bumps.
- **Purchase status wire translation**: Native sends `"success"` but Dart enum is `AppActorPurchaseStatus.purchased` — explicit mapping exists in `fromString()`.
- **Search Ads tracking order**: `enableSearchAdsTracking()` must be called BEFORE `configure()`. It is iOS-only but enforced at the Dart level with no platform guard.
- **Purchase payload is built from `package_id`**: `purchasePackage` (`lib/src/extensions/appactor_purchase.dart`) sends only `package_id` plus optional `offering_id`/`old_purchase_token`/`replacement_mode`/`quantity`/`placement`. The native AppActorPlugin SDK resolves `product_id`/`store`/`base_plan_id`/`offer_id` server-side from the package id, so `AppActorPackage` has no purchase-serialization method.
- **iOS-only methods throw, not no-op**: Methods in `appactor_ios.dart` (ASA diagnostics, offer code sheet, purchaseFromIntent) throw `UnsupportedError` on non-iOS platforms — they are not silent no-ops.

## Test Strategy

- **Dart unit tests** (`test/`): Model deserialization, error classification and deep equality are pure. The lifecycle, purchase and attribute tests mock the `appactor_flutter` channel (only `execute` calls are recorded; `listen` is counted separately) and push native events through it, which covers held purchase intents (cap, TTL, `.first`, reset).
- **Android native tests** (`android/src/test/`): Mockito. Method routing and error handling, plus the multi-engine bridge: mocked `FlutterPluginBinding`s attach several engines and the tests check what reaches each messenger through `deliver`. The `PluginEventListener` to main-handler hop needs a Looper and isn't covered.
- **iOS**: `example/ios/RunnerTests` only calls `handle`. The engine list and `EventRelay` are compile-checked, not tested; there is no simulator run.
- **Integration tests** (`example/integration_test/`): Sanity checks on real device/simulator (instance availability, configured state, SDK version).
