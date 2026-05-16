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
    return jsonEncode({'success': null});
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

  test(
    'setAttributes normalizes values and uses the set_attributes wire method',
    () async {
      await AppActor.instance.setAttributes({
        'plan': const AppActorAttributeValue.string('pro'),
        'age': const AppActorAttributeValue.number(42),
        'trial': const AppActorAttributeValue.boolean(true),
        'categories': const AppActorAttributeValue.stringList([
          'watch_faces',
          'widgets',
        ]),
        'last_seen': DateTime.utc(2026, 5, 16, 12),
      });

      expect(wireMethods(), ['set_attributes']);
      expect(executePayloadFor('set_attributes'), {
        'attributes': {
          'plan': 'pro',
          'age': 42,
          'trial': true,
          'categories': ['watch_faces', 'widgets'],
          'last_seen': '2026-05-16T12:00:00.000Z',
        },
      });
    },
  );

  test(
    'single attribute APIs use custom key validation and expected payloads',
    () async {
      await AppActor.instance.setAttribute('tier', 'gold');
      await AppActor.instance.unsetAttribute('legacy_tier');

      expect(wireMethods(), ['set_attribute', 'unset_attribute']);
      expect(executePayloadFor('set_attribute'), {
        'key': 'tier',
        'value': 'gold',
      });
      expect(executePayloadFor('unset_attribute'), {'key': 'legacy_tier'});
    },
  );

  test('profile and device helpers use native bridge methods', () async {
    await AppActor.instance.setEmail('user@example.com');
    await AppActor.instance.setDisplayName('Ada Lovelace');
    await AppActor.instance.setPhoneNumber('+15551234567');
    await AppActor.instance.setPushToken('push-token-123');
    await AppActor.instance.collectDeviceIdentifiers();

    expect(wireMethods(), [
      'set_email',
      'set_display_name',
      'set_phone_number',
      'set_push_token',
      'collect_device_identifiers',
    ]);
    expect(executePayloadFor('set_email'), {'email': 'user@example.com'});
    expect(executePayloadFor('set_display_name'), {
      'display_name': 'Ada Lovelace',
    });
    expect(executePayloadFor('set_phone_number'), {
      'phone_number': '+15551234567',
    });
    expect(executePayloadFor('set_push_token'), {
      'push_token': 'push-token-123',
    });
    expect(executePayloadFor('collect_device_identifiers'), isEmpty);
  });

  test(
    'integration identifiers and attribution serialize wire values',
    () async {
      await AppActor.instance.setIntegrationIdentifier(
        AppActorIntegrationIdentifier.appsFlyerId,
        'af-user-123',
      );
      await AppActor.instance.updateAttribution(
        AppActorAttribution(
          provider: AppActorAttributionProvider.appleSearchAds,
          status: AppActorAttributionStatus.nonOrganic,
          campaignId: 'campaign-1',
          adGroupId: 'adgroup-1',
          attributedAt: DateTime.utc(2026, 5, 16, 13, 30),
          metadata: const {'source': 'flutter'},
        ),
      );

      expect(wireMethods(), [
        'set_integration_identifier',
        'update_attribution',
      ]);
      expect(executePayloadFor('set_integration_identifier'), {
        'type': 'appsflyer_id',
        'value': 'af-user-123',
      });
      expect(executePayloadFor('update_attribution'), {
        'provider': 'apple_search_ads',
        'status': 'non_organic',
        'campaign_id': 'campaign-1',
        'ad_group_id': 'adgroup-1',
        'attributed_at': '2026-05-16T13:30:00.000Z',
        'metadata': {'source': 'flutter'},
      });
    },
  );

  test('custom attribute keys reject reserved prefixes', () async {
    expect(
      AppActor.instance.setAttribute('', 'x'),
      throwsA(isA<ArgumentError>()),
    );
    expect(
      AppActor.instance.setAttribute(r'$email', 'x'),
      throwsA(isA<ArgumentError>()),
    );
    expect(
      AppActor.instance.setAttribute('appactor.source', 'x'),
      throwsA(isA<ArgumentError>()),
    );
    expect(
      AppActor.instance.setAttributes({'AppActor.source': 'x'}),
      throwsA(isA<ArgumentError>()),
    );
    expect(
      AppActor.instance.setAttribute('x' * 65, 'x'),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('attribute values reject backend-incompatible shapes', () async {
    expect(
      AppActor.instance.setAttribute('score', double.nan),
      throwsA(isA<ArgumentError>()),
    );
    expect(
      AppActor.instance.setAttributes({
        'nested': {'value': true},
      }),
      throwsA(isA<ArgumentError>()),
    );
    expect(
      AppActor.instance.setAttribute('mixed_array', ['a', 1]),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('enum fromString helpers parse wire values', () {
    expect(
      AppActorIntegrationIdentifier.fromString('appsflyer_id'),
      AppActorIntegrationIdentifier.appsFlyerId,
    );
    expect(
      AppActorAttributionProvider.fromString('apple_search_ads'),
      AppActorAttributionProvider.appleSearchAds,
    );
    expect(
      AppActorAttributionStatus.fromString('non_organic'),
      AppActorAttributionStatus.nonOrganic,
    );
  });
}
