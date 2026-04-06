import 'dart:io' show Platform;

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;

import '../appactor.dart';
import '../appactor_platform.dart';
import '../internal/method_names.dart';
import '../models/appactor_options.dart';
import '../sdk_version.dart';

AppActorAsaOptions? _searchAdsOptions;

extension AppActorLifecycle on AppActor {
  /// Enables Apple Search Ads attribution tracking.
  /// Must be called before [configure]. iOS only — the native enable call runs
  /// immediately after configure completes.
  void enableSearchAdsTracking({AppActorAsaOptions? options}) {
    _searchAdsOptions = options ?? const AppActorAsaOptions();
  }

  /// Configures the SDK with the given API key.
  /// Idempotent: safe to call on hot restart — silently skips if already configured.
  Future<void> configure(
    String apiKey, {
    AppActorOptions? options,
  }) async {
    // Hot restart safety: native SDK stays alive across Dart VM restarts.
    // Re-register the method call handler so events flow again.
    AppActorPlatform.ensureInitialized();
    final configured = await isConfigured();

    if (!configured) {
      final params = <String, dynamic>{
        ...?options?.toJson(),
        'api_key': apiKey,
        'platform_flavor': 'flutter',
        'platform_version': appActorSdkVersion,
      };
      await AppActorPlatform.execute(MethodNames.configure, params);
    }

    if (_searchAdsOptions != null &&
        defaultTargetPlatform == TargetPlatform.iOS) {
      await AppActorPlatform.execute(
        MethodNames.enableAppleSearchAdsTracking,
        _searchAdsOptions!.toJson(),
      );
    }
  }

  Future<void> reset() async {
    await AppActorPlatform.execute(MethodNames.reset);
    AppActorPlatform.resetState();
    _searchAdsOptions = null;
  }

  Future<bool> isConfigured() async {
    final result = await AppActorPlatform.execute(MethodNames.isConfigured);
    return result['value'] == true;
  }

  Future<String> sdkVersion() async {
    final result = await AppActorPlatform.execute(MethodNames.getSdkVersion);
    return result['value'] as String? ?? '';
  }

  Future<void> setLogLevel(AppActorLogLevel level) async {
    await AppActorPlatform.execute(MethodNames.setLogLevel, {
      'log_level': level.wireValue,
    });
  }

  /// Enables Google Play Install Referrer tracking (Android only).
  /// Must be called after [configure]. No-op on iOS.
  Future<void> enableInstallReferrer() async {
    if (!Platform.isAndroid) return;
    await AppActorPlatform.execute(MethodNames.enableInstallReferrer);
  }
}
