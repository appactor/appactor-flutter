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
  appactor_flutter: ^0.0.1
```

## Quick Start

```dart
import 'package:appactor_flutter/appactor_flutter.dart';

// Configure once
await AppActor.instance.configure(apiKey: 'pk_YOUR_API_KEY');

// Fetch offerings
final offerings = await AppActor.instance.offerings();

// Make a purchase
final result = await AppActor.instance.purchase(package: offerings.current!.monthly!);

// Check entitlements
final info = await AppActor.instance.getCustomerInfo();
final isPremium = info.hasActiveEntitlement('premium');
```

## Documentation

Visit [appactor.com/docs](https://appactor.com/docs) for full documentation.

## Contributing

- Open an issue for bug reports or feature requests
- Email us at [sdk@appactor.com](mailto:sdk@appactor.com)

## License

MIT License. See [LICENSE](LICENSE) for details.
