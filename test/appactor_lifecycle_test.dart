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
  var listenCalls = 0;

  Future<dynamic> handleCall(MethodCall call) async {
    if (call.method == 'listen') listenCalls++;
    if (call.method != 'execute') return null;
    recordedCalls.add(call);

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

  Future<void> emitIntent(String id) => emitNativeEvent(
        'purchase_intent_received',
        {'intent_id': id, 'product_id': 'pro_monthly'},
      );

  // Listens for a turn and returns the ids of the purchase intents it was handed.
  Future<List<String>> drainIntentIds() async {
    final ids = <String>[];
    final subscription = AppActor.instance.onPurchaseIntent.listen(
      (intent) => ids.add(intent.intentId),
    );
    await pumpEventQueue();
    await subscription.cancel();
    return ids;
  }

  setUp(() async {
    recordedCalls.clear();
    listenCalls = 0;
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

  test('the handler is registered with native so it sends events here', () async {
    await AppActor.instance.configure('pk_test_123');

    expect(listenCalls, 1);
  });

  group('held purchase intents', () {
    setUp(() => AppActor.instance.configure('pk_test_123'));

    test('one with no listener waits for the first one', () async {
      await emitIntent('intent_1');

      final ids = <String>[];
      final subscription = AppActor.instance.onPurchaseIntent.listen(
        (intent) => ids.add(intent.intentId),
      );
      await pumpEventQueue();
      expect(ids, ['intent_1']);

      await emitIntent('intent_2');
      await pumpEventQueue();
      expect(ids, ['intent_1', 'intent_2']);
      await subscription.cancel();

      expect(await drainIntentIds(), isEmpty);
    });

    test('a listener that stops after one leaves the rest for the next', () async {
      await emitIntent('intent_1');
      await emitIntent('intent_2');

      final first = await AppActor.instance.onPurchaseIntent.first;
      final second = await AppActor.instance.onPurchaseIntent.first;

      expect([first.intentId, second.intentId], ['intent_1', 'intent_2']);
    });

    test('at most 10 are held, the oldest go first', () async {
      for (var i = 1; i <= 11; i++) {
        await emitIntent('intent_$i');
      }

      expect(await drainIntentIds(), [for (var i = 2; i <= 11; i++) 'intent_$i']);
    });

    test('one the native side has forgotten is not delivered', () async {
      var now = DateTime(2026, 9, 28, 12);
      AppActorPlatform.now = () => now;
      await emitIntent('stale');
      now = now.add(const Duration(minutes: 6));
      await emitIntent('fresh');

      expect(await drainIntentIds(), ['fresh']);
    });

    test('reset drops the ones no one received', () async {
      await emitIntent('intent_before_reset');
      await AppActor.instance.reset();

      expect(await drainIntentIds(), isEmpty);
    });
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
