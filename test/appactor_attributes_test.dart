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
    if (method == 'log_in') {
      return jsonEncode({
        'success': {'app_user_id': 'identified_user'},
      });
    }
    if (method == 'log_out') {
      return jsonEncode({
        'success': {'value': true},
      });
    }
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

  List<Map<String, dynamic>> executePayloadsFor(String method) {
    return recordedCalls
        .map((call) => Map<String, dynamic>.from(call.arguments as Map))
        .where((entry) => entry['method'] == method)
        .map(
          (entry) =>
              jsonDecode(entry['json'] as String) as Map<String, dynamic>,
        )
        .toList();
  }

  setUp(() async {
    recordedCalls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, handleCall);
    await AppActor.instance.reset();
    recordedCalls.clear();
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
        'flags': const AppActorAttributeValue.boolList([true, false]),
        'last_seen': DateTime.utc(2026, 5, 16, 12),
      });

      expect(wireMethods(), ['set_attributes']);
      expect(executePayloadFor('set_attributes'), {
        'attributes': {
          'plan': 'pro',
          'age': 42,
          'trial': true,
          'categories': ['watch_faces', 'widgets'],
          'flags': [true, false],
          'last_seen': {
            'value': '2026-05-16T12:00:00.000Z',
            'valueType': 'date',
          },
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

    expect(
      AppActor.instance.setEmail('bad-email'),
      throwsA(isA<ArgumentError>()),
    );
    expect(
      AppActor.instance.setPhoneNumber('abc'),
      throwsA(isA<ArgumentError>()),
    );
  });

  test(
    'integration identifiers and attribution serialize wire values',
    () async {
      await AppActor.instance.setAppsflyerID('af-user-123');
      await AppActor.instance.setAdjustID('adj-user-123');
      await AppActor.instance.updateAttribution(
        AppActorAttribution(
          provider: AppActorAttributionProvider.appleSearchAds,
          status: AppActorAttributionStatus.nonOrganic,
          campaignId: 'campaign-1',
          adGroupId: 'adgroup-1',
          network: 'apple_search_ads',
          source: 'search',
          campaign: 'spring',
          adGroup: 'brand',
          attributedAt: DateTime.utc(2026, 5, 16, 13, 30),
          metadata: const {'source': 'flutter'},
        ),
      );

      expect(wireMethods(), [
        'set_integration_identifier',
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
        'network': 'apple_search_ads',
        'source': 'search',
        'campaign': 'spring',
        'ad_group': 'brand',
        'attributed_at': '2026-05-16T13:30:00.000Z',
        'metadata': {'source': 'flutter'},
      });
    },
  );

  test(
    'integration identifiers reject invalid values before native call',
    () async {
      expect(
        AppActor.instance.setAppsflyerID(' padded'),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        AppActor.instance.setAdjustID('x' * 1025),
        throwsA(isA<ArgumentError>()),
      );
      expect(recordedCalls, isEmpty);
    },
  );

  test(
    'attribution convenience helpers use custom provider and canonical fields',
    () async {
      await AppActor.instance.setMediaSource('facebook');
      await AppActor.instance.setCampaign('spring_sale');
      await AppActor.instance.setAdGroup('lookalike_us');
      await AppActor.instance.setAd('ad_1');
      await AppActor.instance.setKeyword('watch faces');
      await AppActor.instance.setCreative('video_1');

      expect(wireMethods(), [
        'update_attribution',
        'update_attribution',
        'update_attribution',
        'update_attribution',
        'update_attribution',
        'update_attribution',
      ]);
      expect(executePayloadsFor('update_attribution'), [
        {
          'provider': 'custom',
          'provider_name': 'facebook',
          'network': 'facebook',
          'source': 'facebook',
        },
        {
          'provider': 'custom',
          'provider_name': 'facebook',
          'network': 'facebook',
          'source': 'facebook',
          'campaign_name': 'spring_sale',
          'campaign': 'spring_sale',
        },
        {
          'provider': 'custom',
          'provider_name': 'facebook',
          'network': 'facebook',
          'source': 'facebook',
          'campaign_name': 'spring_sale',
          'campaign': 'spring_sale',
          'ad_group_name': 'lookalike_us',
          'ad_group': 'lookalike_us',
        },
        {
          'provider': 'custom',
          'provider_name': 'facebook',
          'network': 'facebook',
          'source': 'facebook',
          'campaign_name': 'spring_sale',
          'campaign': 'spring_sale',
          'ad_group_name': 'lookalike_us',
          'ad_group': 'lookalike_us',
          'ad_name': 'ad_1',
          'ad': 'ad_1',
        },
        {
          'provider': 'custom',
          'provider_name': 'facebook',
          'network': 'facebook',
          'source': 'facebook',
          'campaign_name': 'spring_sale',
          'campaign': 'spring_sale',
          'ad_group_name': 'lookalike_us',
          'ad_group': 'lookalike_us',
          'ad_name': 'ad_1',
          'ad': 'ad_1',
          'keyword': 'watch faces',
        },
        {
          'provider': 'custom',
          'provider_name': 'facebook',
          'network': 'facebook',
          'source': 'facebook',
          'campaign_name': 'spring_sale',
          'campaign': 'spring_sale',
          'ad_group_name': 'lookalike_us',
          'ad_group': 'lookalike_us',
          'ad_name': 'ad_1',
          'ad': 'ad_1',
          'keyword': 'watch faces',
          'creative_name': 'video_1',
          'creative': 'video_1',
        },
      ]);
    },
  );

  test(
    'custom integration identifiers and attribution providers are supported',
    () async {
      await AppActor.instance.setCustomIntegrationIdentifier(
        'kochava_device_id',
        'device-123',
      );
      await AppActor.instance.updateAttribution(
        AppActorAttribution.customProvider(
          'singular',
          campaignName: 'spring_sale',
          campaign: 'spring_sale',
        ),
      );

      expect(executePayloadFor('set_integration_identifier'), {
        'type': 'kochava_device_id',
        'value': 'device-123',
      });
      expect(executePayloadFor('update_attribution'), {
        'provider': 'singular',
        'campaign_name': 'spring_sale',
        'campaign': 'spring_sale',
      });
    },
  );

  test('direct attribution update refreshes helper snapshot', () async {
    await AppActor.instance.setMediaSource('facebook');
    await AppActor.instance.updateAttribution(
      const AppActorAttribution(
        provider: AppActorAttributionProvider.custom,
        providerName: 'tiktok',
        network: 'tiktok',
        source: 'tiktok',
      ),
    );
    await AppActor.instance.setCampaign('spring_sale');

    expect(executePayloadsFor('update_attribution').last, {
      'provider': 'custom',
      'provider_name': 'tiktok',
      'network': 'tiktok',
      'source': 'tiktok',
      'campaign_name': 'spring_sale',
      'campaign': 'spring_sale',
    });
  });

  test('attribution helper state resets across identity transitions', () async {
    await AppActor.instance.setMediaSource('facebook');
    await AppActor.instance.logIn('identified_user');
    await AppActor.instance.setCampaign('spring_sale');

    expect(executePayloadsFor('update_attribution'), [
      {
        'provider': 'custom',
        'provider_name': 'facebook',
        'network': 'facebook',
        'source': 'facebook',
      },
      {
        'provider': 'custom',
        'campaign_name': 'spring_sale',
        'campaign': 'spring_sale',
      },
    ]);
  });

  test('attribution canonical fields and metadata keys validate', () async {
    expect(
      AppActor.instance.updateAttribution(
        const AppActorAttribution(
          provider: AppActorAttributionProvider.custom,
          providerName: ' facebook',
        ),
      ),
      throwsA(isA<ArgumentError>()),
    );
    expect(
      AppActor.instance.updateAttribution(
        AppActorAttribution(
          provider: AppActorAttributionProvider.custom,
          campaignName: 'x' * 1025,
        ),
      ),
      throwsA(isA<ArgumentError>()),
    );
    expect(
      AppActor.instance.updateAttribution(
        const AppActorAttribution(
          provider: AppActorAttributionProvider.custom,
          metadata: {'appactor.private': 'x'},
        ),
      ),
      throwsA(isA<ArgumentError>()),
    );
    expect(recordedCalls, isEmpty);
  });

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
    expect(
      AppActor.instance.setAttribute('bad key', 'x'),
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
