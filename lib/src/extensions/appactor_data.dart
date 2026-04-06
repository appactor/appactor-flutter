import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:typed_data';

import '../appactor.dart';
import '../appactor_platform.dart';
import '../internal/method_names.dart';
import '../models/customer_info.dart';
import '../models/enums.dart';
import '../models/offerings.dart';
import '../models/remote_config.dart';
import '../models/storefront.dart';

extension AppActorData on AppActor {
  /// Sets bundled JSON as fallback offerings for first-launch offline scenarios.
  ///
  /// The fallback is used only when both network and disk cache fail.
  /// Fallback offerings are immediately stale — the next call triggers a
  /// network refresh.
  ///
  /// [jsonData] is the raw offerings JSON bytes (typically loaded from an
  /// asset bundle via `rootBundle.load('assets/fallback_offerings.json')`).
  Future<void> setFallbackOfferings(Uint8List jsonData) async {
    await AppActorPlatform.execute(MethodNames.setFallbackOfferings, {
      'json_data': base64Encode(jsonData),
    });
  }

  Future<AppActorCustomerInfo> getCustomerInfo() async {
    final result = await AppActorPlatform.execute(MethodNames.getCustomerInfo);
    return AppActorCustomerInfo.fromJson(result);
  }

  Future<AppActorOfferings> getOfferings() async {
    final result = await AppActorPlatform.execute(MethodNames.getOfferings);
    return AppActorOfferings.fromJson(result);
  }

  Future<Set<String>> activeEntitlementKeysOffline() async {
    final result =
        await AppActorPlatform.execute(MethodNames.activeEntitlementsOffline);
    final list = result['keys'];
    if (list is List) return Set<String>.from(list);
    return const {};
  }

  Future<AppActorOfferings?> getCachedOfferings() async {
    final result =
        await AppActorPlatform.execute(MethodNames.getCachedOfferings);
    if (result['value'] == null && !result.containsKey('current')) return null;
    return AppActorOfferings.fromJson(result);
  }

  Future<AppActorRemoteConfigs?> getCachedRemoteConfigs() async {
    final result =
        await AppActorPlatform.execute(MethodNames.getCachedRemoteConfigs);
    if (result['value'] == null && !result.containsKey('items')) return null;
    return AppActorRemoteConfigs.fromJson(result);
  }

  Future<AppActorCustomerInfo> getCachedCustomerInfo() async {
    final result =
        await AppActorPlatform.execute(MethodNames.getCachedCustomerInfo);
    return AppActorCustomerInfo.fromJson(result);
  }

  /// Whether the current store supports purchases.
  /// Android only — always returns `true` on iOS.
  Future<bool> canMakePurchases() async {
    if (!Platform.isAndroid) return true;
    final result =
        await AppActorPlatform.execute(MethodNames.canMakePurchases);
    return result['value'] == true;
  }

  /// Returns the current storefront (store + country code).
  /// Android only — returns `null` on iOS.
  Future<AppActorStorefront?> getStorefront() async {
    if (!Platform.isAndroid) return null;
    final result = await AppActorPlatform.execute(MethodNames.getStorefront);
    if (result['value'] == null && !result.containsKey('store')) return null;
    return AppActorStorefront.fromJson(result);
  }

  /// Returns the set of capabilities supported by the current store.
  /// Android only — returns an empty set on iOS.
  Future<Set<AppActorStoreCapability>> getStoreCapabilities() async {
    if (!Platform.isAndroid) return const {};
    final result =
        await AppActorPlatform.execute(MethodNames.getStoreCapabilities);
    final list = result['value'];
    if (list is List) {
      return list
          .map((e) => AppActorStoreCapability.fromString(e as String))
          .whereType<AppActorStoreCapability>()
          .toSet();
    }
    return const {};
  }
}
