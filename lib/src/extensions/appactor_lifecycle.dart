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
  ///
  /// Accepts either a single `String` API key or `AppActorPlatformKeys`
  /// for apps that use separate iOS and Android public keys.
  ///
  /// Returns when the native SDK has completed its startup/bootstrap flow.
  /// Pass [appUserId] to start with an explicit identity. When omitted, the
  /// native SDK reuses a cached ID or creates a new anonymous user.
  Future<void> configure(
    Object apiKey, {
    String? appUserId,
    AppActorOptions? options,
  }) async {
    // Hot restart safety: native SDK stays alive across Dart VM restarts.
    // Re-register the method call handler so events flow again.
    AppActorPlatform.ensureInitialized();
    final resolvedApiKey = _resolveApiKey(apiKey);
    final params = <String, dynamic>{
      'api_key': resolvedApiKey,
      if (appUserId != null) 'app_user_id': appUserId,
      'options': {
        ...?options?.toJson(),
        'platform_info': {'flavor': 'flutter', 'version': appActorSdkVersion},
      },
    };
    await AppActorPlatform.execute(MethodNames.configure, params);

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

String _resolveApiKey(Object apiKey) {
  if (apiKey is String) return apiKey;
  if (apiKey is AppActorPlatformKeys) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return apiKey.ios;
      case TargetPlatform.android:
        return apiKey.android;
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        throw UnsupportedError(
          'AppActorPlatformKeys is only supported on iOS and Android.',
        );
    }
  }

  throw ArgumentError.value(
    apiKey,
    'apiKey',
    'Expected a String or AppActorPlatformKeys.',
  );
}
