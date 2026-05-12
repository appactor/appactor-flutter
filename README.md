<h1 align="center" style="border-bottom: none">
<b>
    <a href="https://appactor.com">
        AppActor
    </a>
</b>
<br>In-App Purchase Infrastructure
<br>for Flutter
</h1>

<p align="center">
<a href="https://github.com/appactor/appactor-flutter/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg"></a>
<img src="https://img.shields.io/badge/iOS-15%2B-blue.svg">
<img src="https://img.shields.io/badge/Android-24%2B-green.svg">
<a href="https://pub.dev/packages/appactor_flutter"><img src="https://img.shields.io/badge/pub.dev-compatible-blue.svg"></a>
</p>

AppActor handles in-app purchases, subscriptions, and entitlements so you can focus on building your app. One SDK for both iOS and Android.

## Installation

```yaml
dependencies:
  appactor_flutter: ^0.0.10
```

## Quick Start

```dart
import 'package:appactor_flutter/appactor_flutter.dart';

// Configure once. This returns after the native bootstrap flow completes.
await AppActor.instance.configure(
  'pk_YOUR_API_KEY',
  // Optional: pass appUserId to start with an explicit identity.
  // Omit it to reuse a cached ID or create a new anonymous user.
  appUserId: 'user_123',
);

// Fetch offerings
final offerings = await AppActor.instance.getOfferings();

// Make a purchase
final result = await AppActor.instance.purchasePackage(
  offerings.current!.monthly!,
);

// Check entitlements
final info = await AppActor.instance.getCustomerInfo();
final isPremium = info.hasActiveEntitlement('premium');
```

## Purchase Sync

```dart
// Current native sync behavior:
// drains the receipt queue, then refreshes customer info.
final refreshed = await AppActor.instance.syncPurchases();

// Lightweight sync without draining the receipt queue.
final quiet = await AppActor.instance.quietSyncPurchases();

// Explicit queue-drain API exposed by the native plugins.
final drained = await AppActor.instance.drainReceiptQueueAndRefreshCustomer();
```

## Platform Notes

- `configure()` returns after the native SDK finishes bootstrap.
- Pass `appUserId:` to `configure()` if you want to start with a known user ID.
- Call `enableSearchAdsTracking()` before `configure()` if you use Apple Search Ads attribution on iOS.
- Call `enableInstallReferrer()` after `configure()` if you want Google Play Install Referrer support on Android.
- iOS-only APIs such as `presentOfferCodeRedeemSheet()`, `getAsaDiagnostics()`, and `purchaseFromIntent()` throw `UnsupportedError` on non-iOS platforms.

## Documentation

Visit [appactor.com/docs](https://appactor.com/docs) for full documentation.

## Contributing

- Open an issue for bug reports or feature requests
- Email us at [sdk@appactor.com](mailto:sdk@appactor.com)

## License

MIT License. See [LICENSE](LICENSE) for details.
