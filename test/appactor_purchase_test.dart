import 'dart:convert';

import 'package:appactor_flutter/appactor_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('appactor_flutter');
  final recordedCalls = <MethodCall>[];

  Future<dynamic> handleCall(MethodCall call) async {
    if (call.method != 'execute') return null;
    recordedCalls.add(call);

    final args = Map<String, dynamic>.from(call.arguments as Map);
    final method = args['method'] as String;
    switch (method) {
      case 'purchase_package':
        return jsonEncode({
          'success': {'status': 'success'},
        });
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

  Map<String, dynamic> executePayloadFor(String method) {
    final args = recordedCalls
        .map((call) => Map<String, dynamic>.from(call.arguments as Map))
        .firstWhere((entry) => entry['method'] == method);
    return jsonDecode(args['json'] as String) as Map<String, dynamic>;
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

  test(
    'purchasePackage serializes quantity and placement on the native wire contract',
    () async {
      const package = AppActorPackage(
        id: 'monthly',
        productId: 'pro_monthly',
        offeringId: 'default',
      );

      final result = await AppActor.instance.purchasePackage(
        package,
        quantity: 3,
        placement: '  onboarding_paywall  ',
      );

      expect(result.status, AppActorPurchaseStatus.purchased);
      expect(wireMethods(), ['purchase_package']);
      expect(executePayloadFor('purchase_package'), {
        'package_id': 'monthly',
        'offering_id': 'default',
        'quantity': 3,
        'placement': 'onboarding_paywall',
      });
    },
  );

  test(
    'purchasePackage omits null placement from the native payload',
    () async {
      const package = AppActorPackage(id: 'monthly', productId: 'pro_monthly');

      await AppActor.instance.purchasePackage(package, placement: null);

      expect(wireMethods(), ['purchase_package']);
      expect(executePayloadFor('purchase_package'), {'package_id': 'monthly'});
    },
  );

  test(
    'purchasePackage omits blank placement from the native payload',
    () async {
      const package = AppActorPackage(id: 'monthly', productId: 'pro_monthly');

      await AppActor.instance.purchasePackage(package, placement: '   ');

      expect(wireMethods(), ['purchase_package']);
      expect(executePayloadFor('purchase_package'), {'package_id': 'monthly'});
    },
  );

  test('purchasePackage serializes max length placement', () async {
    const package = AppActorPackage(id: 'monthly', productId: 'pro_monthly');
    final placement = 'x' * 255;

    await AppActor.instance.purchasePackage(package, placement: placement);

    expect(wireMethods(), ['purchase_package']);
    expect(executePayloadFor('purchase_package'), {
      'package_id': 'monthly',
      'placement': placement,
    });
  });

  test(
    'purchasePackage omits overlong placement from the native payload',
    () async {
      const package = AppActorPackage(id: 'monthly', productId: 'pro_monthly');

      await AppActor.instance.purchasePackage(package, placement: 'x' * 256);

      expect(wireMethods(), ['purchase_package']);
      expect(executePayloadFor('purchase_package'), {'package_id': 'monthly'});
    },
  );

  test(
    'purchasePackage rejects invalid quantity before native dispatch',
    () async {
      const package = AppActorPackage(id: 'monthly', productId: 'pro_monthly');

      expect(
        () => AppActor.instance.purchasePackage(package, quantity: 0),
        throwsArgumentError,
      );
      expect(recordedCalls, isEmpty);
    },
  );

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
