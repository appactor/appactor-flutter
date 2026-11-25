import 'dart:convert';

import 'package:appactor_flutter/appactor_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppActorPackage.lookupKey', () {
    test('fromJson parses valid snake_case lookup_key', () {
      final pkg = AppActorPackage.fromJson({
        'id': 'pkg_1',
        'lookup_key': 'pro_monthly',
        'package_type': 'monthly',
        'product_id': 'com.app.monthly',
      });

      expect(pkg.lookupKey, 'pro_monthly');
    });

    test('fromJson trims leading and trailing whitespace on lookup_key', () {
      final pkg = AppActorPackage.fromJson({
        'id': 'pkg_1',
        'lookup_key': '  \t pro_monthly \n ',
        'package_type': 'monthly',
        'product_id': 'com.app.monthly',
      });

      expect(pkg.lookupKey, 'pro_monthly');
    });

    test('fromJson handles null, absent, empty, and blank lookup_key without fallback', () {
      final cases = <String, Map<String, dynamic>>{
        'absent (iOS nil wire format)': {
          'id': 'pkg_monthly',
          'package_type': 'monthly',
          'product_id': 'com.app.monthly',
          'store_product_id': 'com.app.monthly.store',
          'display_name': 'Monthly',
          'server_id': 'srv_1',
        },
        'explicit null (Android null wire format)': {
          'id': 'pkg_monthly',
          'lookup_key': null,
          'package_type': 'monthly',
          'product_id': 'com.app.monthly',
        },
        'empty string': {
          'id': 'pkg_monthly',
          'lookup_key': '',
          'package_type': 'monthly',
          'product_id': 'com.app.monthly',
        },
        'blank whitespace string': {
          'id': 'pkg_monthly',
          'lookup_key': '   \t\r\n  ',
          'package_type': 'monthly',
          'product_id': 'com.app.monthly',
        },
      };

      for (final entry in cases.entries) {
        final pkg = AppActorPackage.fromJson(entry.value);
        expect(pkg.lookupKey, isNull, reason: entry.key);
        expect(pkg.id, 'pkg_monthly', reason: entry.key);
        expect(pkg.packageType, AppActorPackageType.monthly, reason: entry.key);
        expect(pkg.productId, 'com.app.monthly', reason: entry.key);
      }
    });

    test('fromJson safely ignores non-string lookup_key values', () {
      for (final raw in <Object?>[123, 45.6, true, <String, dynamic>{}, <dynamic>[]]) {
        final pkg = AppActorPackage.fromJson({
          'id': 'pkg_1',
          'lookup_key': raw,
          'product_id': 'com.app.monthly',
        });
        expect(pkg.lookupKey, isNull, reason: 'raw=${raw.runtimeType}');
      }
    });

    test('const constructor remains backward-compatible with optional lookupKey', () {
      const legacy = AppActorPackage(id: 'pkg_1', productId: 'com.app.monthly');
      expect(legacy.lookupKey, isNull);

      const keyed = AppActorPackage(
        id: 'pkg_1',
        lookupKey: 'pro_monthly',
        productId: 'com.app.monthly',
      );
      expect(keyed.lookupKey, 'pro_monthly');
    });

    test('equality, hashCode, and toString account for lookupKey', () {
      const a = AppActorPackage(
        id: 'pkg_1',
        lookupKey: 'pro_monthly',
        productId: 'com.app.monthly',
      );
      final fromPaddedJson = AppActorPackage.fromJson({
        'id': 'pkg_1',
        'lookup_key': '  pro_monthly  ',
        'product_id': 'com.app.monthly',
      });
      const differentKey = AppActorPackage(
        id: 'pkg_1',
        lookupKey: 'pro_annual',
        productId: 'com.app.monthly',
      );
      const noKey = AppActorPackage(
        id: 'pkg_1',
        productId: 'com.app.monthly',
      );
      final fromBlankJson = AppActorPackage.fromJson({
        'id': 'pkg_1',
        'lookup_key': '   ',
        'product_id': 'com.app.monthly',
      });

      expect(a, equals(fromPaddedJson));
      expect(a.hashCode, fromPaddedJson.hashCode);
      expect(a, isNot(equals(differentKey)));
      expect(a, isNot(equals(noKey)));
      expect(noKey, equals(fromBlankJson));
      expect(noKey.hashCode, fromBlankJson.hashCode);

      expect(a.toString(), contains('lookupKey: pro_monthly'));
      expect(noKey.toString(), contains('lookupKey: null'));
    });
  });

  group('AppActorOffering.packageForLookupKey', () {
    final offering = AppActorOffering.fromJson({
      'id': 'default',
      'display_name': 'Default',
      'is_current': true,
      'lookup_key': 'main',
      'packages': [
        {
          'id': 'pkg_monthly_id',
          'lookup_key': '  pro_monthly  ',
          'package_type': 'monthly',
          'product_id': 'com.app.monthly',
          'store_product_id': 'com.app.monthly.store',
          'server_id': 'srv_monthly',
        },
        {
          'id': 'pkg_annual_id',
          'lookup_key': 'pro_annual',
          'package_type': 'annual',
          'product_id': 'com.app.annual',
        },
        {
          'id': 'pkg_keyless_id',
          'lookup_key': null,
          'package_type': 'lifetime',
          'product_id': 'com.app.lifetime',
        },
      ],
    });

    test('returns exact match on normalized lookupKey', () {
      final monthly = offering.packageForLookupKey('pro_monthly');
      expect(monthly, isNotNull);
      expect(monthly!.id, 'pkg_monthly_id');
      expect(monthly.lookupKey, 'pro_monthly');

      final annual = offering.packageForLookupKey('pro_annual');
      expect(annual, isNotNull);
      expect(annual!.id, 'pkg_annual_id');
      expect(annual.lookupKey, 'pro_annual');
    });

    test('is case-sensitive and rejects unmatched keys without fallback', () {
      expect(offering.packageForLookupKey('PRO_MONTHLY'), isNull);
      expect(offering.packageForLookupKey('Pro_Monthly'), isNull);
      expect(offering.packageForLookupKey('nonexistent'), isNull);
    });

    test('rejects empty, blank, and whitespace-padded queries', () {
      expect(offering.packageForLookupKey(''), isNull);
      expect(offering.packageForLookupKey('   '), isNull);
      expect(offering.packageForLookupKey('\t\n'), isNull);
      expect(offering.packageForLookupKey(' pro_monthly'), isNull);
      expect(offering.packageForLookupKey('pro_monthly '), isNull);
      expect(offering.packageForLookupKey('  pro_monthly  '), isNull);
      expect(offering.packageForLookupKey('\tpro_annual\n'), isNull);
    });

    test('rejects empty/blank/padded queries even against manually constructed packages', () {
      const manualOffering = AppActorOffering(
        id: 'manual',
        displayName: 'Manual',
        packages: [
          AppActorPackage(
            id: 'p_empty',
            lookupKey: '',
            productId: 'com.app.empty',
          ),
          AppActorPackage(
            id: 'p_blank',
            lookupKey: '   ',
            productId: 'com.app.blank',
          ),
          AppActorPackage(
            id: 'p_padded',
            lookupKey: ' padded ',
            productId: 'com.app.padded',
          ),
        ],
      );

      expect(manualOffering.packageForLookupKey(''), isNull);
      expect(manualOffering.packageForLookupKey('   '), isNull);
      expect(manualOffering.packageForLookupKey(' padded '), isNull);
      expect(manualOffering.packageForLookupKey('padded'), isNull);
    });

    test('never falls back to id, packageType, productId, storeProductId, or serverId', () {
      // Fields belonging to keyed package
      expect(offering.packageForLookupKey('pkg_monthly_id'), isNull);
      expect(offering.packageForLookupKey('monthly'), isNull);
      expect(offering.packageForLookupKey('com.app.monthly'), isNull);
      expect(offering.packageForLookupKey('com.app.monthly.store'), isNull);
      expect(offering.packageForLookupKey('srv_monthly'), isNull);

      // Fields belonging to keyless package
      expect(offering.packageForLookupKey('pkg_keyless_id'), isNull);
      expect(offering.packageForLookupKey('lifetime'), isNull);
      expect(offering.packageForLookupKey('com.app.lifetime'), isNull);

      // Existing id/type helpers still work as before
      expect(offering.package('pkg_monthly_id')?.lookupKey, 'pro_monthly');
      expect(offering.packageFor(AppActorPackageType.lifetime)?.id, 'pkg_keyless_id');
    });

    test('returns null for legacy keyless cached offering payloads', () {
      final legacyOffering = AppActorOffering.fromJson({
        'id': 'legacy',
        'display_name': 'Legacy',
        'packages': [
          {
            'id': 'monthly',
            'package_type': 'monthly',
            'product_id': 'com.app.monthly',
          },
          {
            'id': 'annual',
            'package_type': 'annual',
            'product_id': 'com.app.annual',
          },
        ],
      });

      expect(legacyOffering.packages.every((p) => p.lookupKey == null), isTrue);
      expect(legacyOffering.packageForLookupKey('monthly'), isNull);
      expect(legacyOffering.packageForLookupKey('annual'), isNull);
      expect(legacyOffering.packageForLookupKey('com.app.monthly'), isNull);
      expect(legacyOffering.packageForLookupKey('anything'), isNull);
    });
  });

  group('Offerings bridge wire flow (getOfferings & getCachedOfferings)', () {
    const channel = MethodChannel('appactor_flutter');
    final recordedCalls = <MethodCall>[];
    late Map<String, dynamic> Function(String method) responseForMethod;

    setUp(() {
      recordedCalls.clear();
      responseForMethod = (_) => {'success': null};
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method != 'execute') return null;
            recordedCalls.add(call);
            final args = Map<String, dynamic>.from(call.arguments as Map);
            final method = args['method'] as String;
            return jsonEncode(responseForMethod(method));
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('getOfferings carries lookup_key for both iOS (omitted nil) and Android (explicit null)', () async {
      responseForMethod = (method) {
        if (method == 'get_offerings') {
          return {
            'success': {
              'current': {
                'id': 'off_1',
                'display_name': 'Main',
                'is_current': true,
                'lookup_key': 'main',
                'packages': [
                  {
                    'id': 'pkg_1',
                    'lookup_key': 'pro_monthly',
                    'package_type': 'monthly',
                    'product_id': 'com.app.monthly',
                    'offering_id': 'off_1',
                  },
                  {
                    'id': 'pkg_2',
                    'lookup_key': null,
                    'package_type': 'annual',
                    'product_id': 'com.app.annual',
                    'offering_id': 'off_1',
                  },
                  {
                    'id': 'pkg_3',
                    'package_type': 'lifetime',
                    'product_id': 'com.app.lifetime',
                    'offering_id': 'off_1',
                  },
                ],
              },
              'all': {
                'off_1': {
                  'id': 'off_1',
                  'display_name': 'Main',
                  'is_current': true,
                  'lookup_key': 'main',
                  'packages': [
                    {
                      'id': 'pkg_1',
                      'lookup_key': 'pro_monthly',
                      'package_type': 'monthly',
                      'product_id': 'com.app.monthly',
                      'offering_id': 'off_1',
                    },
                  ],
                },
              },
              'product_entitlements': {
                'com.app.monthly': ['pro'],
              },
              'verification': 'verified',
            },
          };
        }
        if (method == 'purchase_package') {
          return {
            'success': {'status': 'success'},
          };
        }
        return {'success': null};
      };

      final offerings = await AppActor.instance.getOfferings();
      final current = offerings.current!;
      expect(current.packages[0].lookupKey, 'pro_monthly');
      expect(current.packages[1].lookupKey, isNull);
      expect(current.packages[2].lookupKey, isNull);

      final resolved = current.packageForLookupKey('pro_monthly');
      expect(resolved, isNotNull);
      expect(resolved!.id, 'pkg_1');
      expect(current.packageForLookupKey('pkg_2'), isNull);
      expect(current.packageForLookupKey('pkg_3'), isNull);

      // Purchasing the resolved package still sends package_id + offering_id
      final purchaseResult = await AppActor.instance.purchasePackage(resolved);
      expect(purchaseResult.isPurchased, isTrue);
      final purchaseArgs = Map<String, dynamic>.from(
        recordedCalls.last.arguments as Map,
      );
      expect(purchaseArgs['method'], 'purchase_package');
      expect(jsonDecode(purchaseArgs['json'] as String), {
        'package_id': 'pkg_1',
        'offering_id': 'off_1',
      });
    });

    test('getCachedOfferings carries lookup_key including when iOS omits current', () async {
      responseForMethod = (_) => {
        'success': {
          'all': {
            'onboarding': {
              'id': 'off_onboarding',
              'display_name': 'Onboarding',
              'is_current': false,
              'lookup_key': 'onboarding',
              'packages': [
                {
                  'id': 'pkg_onb',
                  'lookup_key': '  intro_annual  ',
                  'package_type': 'annual',
                  'product_id': 'com.app.annual',
                },
                {
                  'id': 'pkg_blank',
                  'lookup_key': '   ',
                  'package_type': 'monthly',
                  'product_id': 'com.app.monthly',
                },
              ],
            },
          },
          'product_entitlements': <String, dynamic>{},
          'verification': 'notRequested',
        },
      };

      final cached = await AppActor.instance.getCachedOfferings();
      expect(cached, isNotNull);
      expect(cached!.current, isNull);
      final onboarding = cached.getOffering('onboarding')!;
      expect(onboarding.packageForLookupKey('intro_annual')?.id, 'pkg_onb');
      expect(onboarding.packageForLookupKey('pkg_blank'), isNull);
      expect(onboarding.packageForLookupKey('monthly'), isNull);
    });

    test('getCachedOfferings returns null when native cache is empty', () async {
      responseForMethod = (_) => {'success': null};

      final cached = await AppActor.instance.getCachedOfferings();
      expect(cached, isNull);
    });
  });
}
