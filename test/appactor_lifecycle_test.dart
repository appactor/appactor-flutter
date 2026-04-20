import 'dart:convert';

import 'package:appactor_flutter/appactor_flutter.dart';
import 'package:appactor_flutter/src/sdk_version.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, debugDefaultTargetPlatformOverride;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('appactor_flutter');
  final recordedCalls = <MethodCall>[];

  Future<dynamic> handleCall(MethodCall call) async {
    recordedCalls.add(call);
    if (call.method != 'execute') return null;

    final args = Map<String, dynamic>.from(call.arguments as Map);
    final method = args['method'] as String;
    switch (method) {
      case 'configure':
      case 'enable_apple_search_ads_tracking':
      case 'reset':
        return jsonEncode({'success': null});
      default:
        return jsonEncode({'success': null});
    }
  }

  List<String> wireMethods() {
    return recordedCalls
        .map((call) => Map<String, dynamic>.from(call.arguments as Map))
        .map((args) => args['method'] as String)
        .toList();
  }

  Map<String, dynamic> executePayloadFor(String method) {
    final args = recordedCalls
        .map((call) => Map<String, dynamic>.from(call.arguments as Map))
        .firstWhere((entry) => entry['method'] == method);
    return jsonDecode(args['json'] as String) as Map<String, dynamic>;
  }

  setUp(() async {
    recordedCalls.clear();
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, handleCall);
    await AppActor.instance.reset();
    recordedCalls.clear();
  });

  tearDown(() async {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test(
    'configure enables ASA on iOS after native configure and omits dead asa payload',
    () async {
      AppActor.instance.enableSearchAdsTracking();

      await AppActor.instance.configure(
        'pk_test_123',
        options: const AppActorOptions(logLevel: AppActorLogLevel.debug),
      );

      expect(wireMethods(), ['configure', 'enable_apple_search_ads_tracking']);

      final configurePayload = executePayloadFor('configure');
      expect(configurePayload['api_key'], 'pk_test_123');
      final options = Map<String, dynamic>.from(
        configurePayload['options'] as Map,
      );
      expect(options['log_level'], 'debug');
      expect(options['platform_info'], {
        'flavor': 'flutter',
        'version': appActorSdkVersion,
      });
      expect(configurePayload.containsKey('asa'), isFalse);

      final asaPayload = executePayloadFor('enable_apple_search_ads_tracking');
      expect(asaPayload, {
        'auto_track_purchases': true,
        'track_in_sandbox': false,
        'debug_mode': false,
      });
    },
  );

  test(
    'configure sends each call to native and still enables ASA on iOS',
    () async {
      AppActor.instance.enableSearchAdsTracking();

      await AppActor.instance.configure('pk_test_123');
      await AppActor.instance.configure('pk_test_123');

      expect(wireMethods(), [
        'configure',
        'enable_apple_search_ads_tracking',
        'configure',
        'enable_apple_search_ads_tracking',
      ]);
    },
  );

  test(
    'configure does not enable ASA when Flutter target platform is not iOS',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      AppActor.instance.enableSearchAdsTracking();

      await AppActor.instance.configure('pk_test_123');

      expect(wireMethods(), ['configure']);
    },
  );

  test('configure forwards appUserId through the bootstrap request', () async {
    await AppActor.instance.configure(
      'pk_test_123',
      appUserId: 'user_flutter_123',
    );

    final configurePayload = executePayloadFor('configure');
    expect(configurePayload['app_user_id'], 'user_flutter_123');
  });

  test('configure selects the iOS key from AppActorPlatformKeys', () async {
    await AppActor.instance.configure(
      const AppActorPlatformKeys(ios: 'pk_ios_123', android: 'pk_android_123'),
    );

    final configurePayload = executePayloadFor('configure');
    expect(configurePayload['api_key'], 'pk_ios_123');
  });

  test('configure selects the Android key from AppActorPlatformKeys', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    await AppActor.instance.configure(
      const AppActorPlatformKeys(ios: 'pk_ios_123', android: 'pk_android_123'),
    );

    final configurePayload = executePayloadFor('configure');
    expect(configurePayload['api_key'], 'pk_android_123');
    expect(
      Map<String, dynamic>.from(
        configurePayload['options'] as Map,
      )['platform_info'],
      {'flavor': 'flutter', 'version': appActorSdkVersion},
    );
  });

  test(
    'configure rejects AppActorPlatformKeys on unsupported platforms',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

      expect(
        () => AppActor.instance.configure(
          const AppActorPlatformKeys(
            ios: 'pk_ios_123',
            android: 'pk_android_123',
          ),
        ),
        throwsA(isA<UnsupportedError>()),
      );
    },
  );
}
