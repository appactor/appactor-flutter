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
<img src="https://img.shields.io/badge/iOS-15.1%2B-blue.svg">
<img src="https://img.shields.io/badge/Android-24%2B-green.svg">
<a href="https://pub.dev/packages/appactor_flutter"><img src="https://img.shields.io/badge/pub.dev-compatible-blue.svg"></a>
</p>

AppActor handles in-app purchases, subscriptions, and entitlements so you can focus on building your app. One SDK for both iOS and Android.

## Installation

```yaml
dependencies:
  appactor_flutter: ^0.0.17
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
  placement: 'onboarding_paywall',
);
// Optional quantity must be at least 1. Android supports only quantity 1;
// higher quantities are rejected by the native bridge.
// Optional placement is omitted when null or blank.

// Check entitlements
final info = await AppActor.instance.getCustomerInfo();
final isPremium = info.hasActiveEntitlement('premium');
```

## Offerings & Experiments

```dart
// All offerings, or one by its offering key (the dashboard "lookup key")
final offerings = await AppActor.instance.getOfferings();
offerings.current;                          // the current offering
offerings.allOfferings;                     // List<AppActorOffering>, current first
offerings['onboarding'];                    // by offeringKey
final onboarding = await AppActor.instance.getOffering('onboarding'); // fetch + lookup in one call

// Experiments — never null, so no null-checks
final paywall = await AppActor.instance.getExperiment('paywall_test');
if (paywall.isVariant('annual_first')) showAnnualFirst();
paywall.variantKey;                         // 'control', 'annual_first', … or null when not enrolled

final showOnboarding = (await AppActor.instance.getExperiment('has_onboard'))
    .boolValue(defaultValue: true);
final title = (await AppActor.instance.getExperiment('onboarding_flow'))['title'] as String? ?? 'Welcome';
```

## Customer Attributes

```dart
await AppActor.instance.setAttributes({
  'favorite_category': 'watch_faces',
  'signup_source': const AppActorAttributeValue.string('spring_campaign'),
  'last_seen': AppActorAttributeValue.dateTime(DateTime.now()),
  'feature_flags': const AppActorAttributeValue.boolList([true, false]),
});

await AppActor.instance.setEmail('user@example.com');
await AppActor.instance.setDisplayName('Ada Lovelace');
await AppActor.instance.setIntegrationIdentifier(
  AppActorIntegrationIdentifier.appsFlyerId,
  'af-user-123',
);
await AppActor.instance.setAdjustID('adjust-user-123');

await AppActor.instance.setMediaSource('facebook');
await AppActor.instance.setCampaign('spring_sale');
await AppActor.instance.setCampaign(null); // Clear a helper field.
```

`setAttribute()` and `setAttributes()` are for developer-defined custom
attributes only. Custom keys cannot use `$`, `appactor.`, or `integration.`
reserved prefixes. `DateTime` values are sent as a typed date envelope, boolean
arrays are supported, and `null` values are rejected; call
`unsetAttribute(key)` to remove a custom attribute.

Profile helpers such as `setEmail()`, `setDisplayName()`, `setPhoneNumber()`,
and `setPushToken()` use native reserved profile routes. Native iOS/Android
automatically send privacy-safe SDK/device context during `configure()`, such
as platform, app version, SDK version, device model, bundle/package ID, locale,
and timezone. `collectDeviceIdentifiers()` remains opt-in for additional
identifiers.

Integration identifiers and attribution are separate surfaces. Use
`setIntegrationIdentifier()` / provider helpers for external user or device IDs,
and use `updateAttribution()` / `setMediaSource()` / `setCampaign()` /
`setAdGroup()` / `setAd()` / `setKeyword()` / `setCreative()` for campaign
context. Passing `null` to an attribution convenience helper clears that helper
field through the native attribution route.

## Purchase Sync

```dart
// Quiet store sync without draining the local receipt queue.
final refreshed = await AppActor.instance.syncPurchases();

// Deprecated alias for syncPurchases().
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

- [Customer attributes and profile context](doc/customer-attributes.md)

Visit [appactor.com/docs](https://appactor.com/docs) for full documentation.

## Contributing

- Open an issue for bug reports or feature requests
- Email us at [sdk@appactor.com](mailto:sdk@appactor.com)

## License

MIT License. See [LICENSE](LICENSE) for details.
