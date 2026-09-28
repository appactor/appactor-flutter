import 'dart:async';
import 'dart:convert';

import 'package:appactor_flutter/appactor_flutter.dart';
import 'package:appactor_flutter/src/appactor_platform.dart';
import 'package:appactor_flutter/src/sdk_version.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, debugDefaultTargetPlatformOverride;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('appactor_flutter');
  final recordedCalls = <MethodCall>[];
  var failAsaEnable = false;

  Future<dynamic> handleCall(MethodCall call) async {
    recordedCalls.add(call);
    if (call.method != 'execute') return null;

    final args = Map<String, dynamic>.from(call.arguments as Map);
    final method = args['method'] as String;
    switch (method) {
      case 'enable_apple_search_ads_tracking':
        if (failAsaEnable) {
          return jsonEncode({
            'error': {'code': 2000, 'message': 'ASA enable failed'},
          });
        }
        return jsonEncode({'success': null});
      case 'configure':
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

  Future<void> emitNativeEvent(String name, Map<String, dynamic> payload) async {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    final completion = Completer<void>();
    messenger.handlePlatformMessage(
      channel.name,
      channel.codec.encodeMethodCall(
        MethodCall('event', {'name': name, 'json': jsonEncode(payload)}),
      ),
      (_) => completion.complete(),
    );
    await completion.future;
  }

  setUp(() async {
    recordedCalls.clear();
    failAsaEnable = false;
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, handleCall);
    await AppActor.instance.reset();
    recordedCalls.clear();
  });

  tearDown(() async {
    AppActorPlatform.now = DateTime.now;
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
    'configure completes successfully even when the ASA enable call fails',
    () async {
      failAsaEnable = true;
      AppActor.instance.enableSearchAdsTracking();

      // The core native configure succeeded; an optional ASA-enable failure
      // must not reject configure() and make callers treat the SDK as
      // un-configured.
      await expectLater(
        AppActor.instance.configure('pk_test_123'),
        completes,
      );

      expect(wireMethods(), ['configure', 'enable_apple_search_ads_tracking']);
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

  test(
    'configure re-registers customer info events after reset in the same isolate',
    () async {
      final delivered = Completer<AppActorCustomerInfo>();
      final subscription = AppActor.instance.onCustomerInfoUpdated.listen((
        info,
      ) {
        if (!delivered.isCompleted) {
          delivered.complete(info);
        }
      });

      await AppActor.instance.configure('pk_test_123');
      await AppActor.instance.reset();
      await AppActor.instance.configure('pk_test_123');
      await emitNativeEvent('customer_info_updated', {
        'app_user_id': 'user_flutter_reset',
      });

      expect((await delivered.future).appUserId, 'user_flutter_reset');
      await subscription.cancel();
    },
  );

  test('a purchase intent with no listener waits for the first one', () async {
    await AppActor.instance.configure('pk_test_123');
    await emitNativeEvent('purchase_intent_received', {
      'intent_id': 'intent_1',
      'product_id': 'pro_monthly',
    });

    final intents = <AppActorPurchaseIntent>[];
    final subscription = AppActor.instance.onPurchaseIntent.listen(intents.add);
    await pumpEventQueue();
    expect(intents.map((intent) => intent.intentId), ['intent_1']);

    await emitNativeEvent('purchase_intent_received', {
      'intent_id': 'intent_2',
      'product_id': 'pro_monthly',
    });
    await pumpEventQueue();
    expect(intents.map((intent) => intent.intentId), ['intent_1', 'intent_2']);
    await subscription.cancel();

    final late = <AppActorPurchaseIntent>[];
    final lateSubscription = AppActor.instance.onPurchaseIntent.listen(
      late.add,
    );
    await pumpEventQueue();
    expect(late, isEmpty);
    await lateSubscription.cancel();
  });

  test('a listener that stops after one intent leaves the rest for the next', () async {
    await AppActor.instance.configure('pk_test_123');
    for (final id in ['intent_1', 'intent_2']) {
      await emitNativeEvent('purchase_intent_received', {
        'intent_id': id,
        'product_id': 'pro_monthly',
      });
    }

    final first = await AppActor.instance.onPurchaseIntent.first;
    final second = await AppActor.instance.onPurchaseIntent.first;

    expect([first.intentId, second.intentId], ['intent_1', 'intent_2']);
  });

  test('a purchase intent the native side has forgotten is not delivered', () async {
    var now = DateTime(2026, 9, 28, 12);
    AppActorPlatform.now = () => now;
    await AppActor.instance.configure('pk_test_123');
    await emitNativeEvent('purchase_intent_received', {
      'intent_id': 'stale',
      'product_id': 'pro_monthly',
    });
    now = now.add(const Duration(minutes: 6));
    await emitNativeEvent('purchase_intent_received', {
      'intent_id': 'fresh',
      'product_id': 'pro_monthly',
    });

    final intent = await AppActor.instance.onPurchaseIntent.first;

    expect(intent.intentId, 'fresh');
  });

  test('reset drops purchase intents no one received', () async {
    await AppActor.instance.configure('pk_test_123');
    await emitNativeEvent('purchase_intent_received', {
      'intent_id': 'intent_before_reset',
      'product_id': 'pro_monthly',
    });
    await AppActor.instance.reset();

    final intents = <AppActorPurchaseIntent>[];
    final subscription = AppActor.instance.onPurchaseIntent.listen(intents.add);
    await pumpEventQueue();
    expect(intents, isEmpty);
    await subscription.cancel();
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
