import 'dart:convert';

import 'package:appactor_flutter/appactor_flutter.dart';
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
      case 'sync_purchases':
      case 'quiet_sync_purchases':
      case 'drain_receipt_queue_and_refresh_customer':
        return jsonEncode({
          'success': {
            'app_user_id': 'user_123',
            'active_entitlement_keys': ['premium'],
          },
        });
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

  setUp(() {
    recordedCalls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, handleCall);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('syncPurchases uses the sync wire method', () async {
    final info = await AppActor.instance.syncPurchases();

    expect(info.appUserId, 'user_123');
    expect(info.activeEntitlementKeys, {'premium'});
    expect(wireMethods(), ['sync_purchases']);
  });

  test('quietSyncPurchases uses the quiet sync wire method', () async {
    final info = await AppActor.instance.quietSyncPurchases();

    expect(info.appUserId, 'user_123');
    expect(wireMethods(), ['quiet_sync_purchases']);
  });

  test(
    'drainReceiptQueueAndRefreshCustomer uses the explicit queue drain wire method',
    () async {
      final info = await AppActor.instance
          .drainReceiptQueueAndRefreshCustomer();

      expect(info.appUserId, 'user_123');
      expect(wireMethods(), ['drain_receipt_queue_and_refresh_customer']);
    },
  );
}
