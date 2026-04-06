import 'dart:convert';

import 'package:appactor_flutter/appactor_flutter.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, debugDefaultTargetPlatformOverride;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('appactor_flutter');
  final recordedCalls = <MethodCall>[];
  bool mockConfigured = false;

  Future<dynamic> handleCall(MethodCall call) async {
    recordedCalls.add(call);
    if (call.method != 'execute') return null;

    final args = Map<String, dynamic>.from(call.arguments as Map);
    final method = args['method'] as String;
    switch (method) {
      case 'is_configured':
        return jsonEncode({'success': mockConfigured});
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
    mockConfigured = false;
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

  test('configure enables ASA on iOS after native configure and omits dead asa payload',
      () async {
    AppActor.instance.enableSearchAdsTracking();

    await AppActor.instance.configure(
      'pk_test_123',
      options: const AppActorOptions(logLevel: AppActorLogLevel.debug),
    );

    expect(
      wireMethods(),
      [
        'is_configured',
        'configure',
        'enable_apple_search_ads_tracking',
      ],
    );

    final configurePayload = executePayloadFor('configure');
    expect(configurePayload['api_key'], 'pk_test_123');
    expect(configurePayload['log_level'], 'debug');
    expect(configurePayload.containsKey('asa'), isFalse);

    final asaPayload = executePayloadFor('enable_apple_search_ads_tracking');
    expect(asaPayload, {
      'auto_track_purchases': true,
      'track_in_sandbox': false,
      'debug_mode': false,
    });
  });

  test('configure still enables ASA when native SDK is already configured', () async {
    mockConfigured = true;
    AppActor.instance.enableSearchAdsTracking();

    await AppActor.instance.configure('pk_test_123');

    expect(
      wireMethods(),
      [
        'is_configured',
        'enable_apple_search_ads_tracking',
      ],
    );
  });

  test('configure does not enable ASA when Flutter target platform is not iOS',
      () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    AppActor.instance.enableSearchAdsTracking();

    await AppActor.instance.configure('pk_test_123');

    expect(
      wireMethods(),
      [
        'is_configured',
        'configure',
      ],
    );
  });
}
