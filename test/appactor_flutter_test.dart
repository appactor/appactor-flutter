import 'package:flutter_test/flutter_test.dart';
import 'package:appactor_flutter/appactor_flutter.dart';

void main() {
  group('AppActorError', () {
    test('fromJson parses error correctly', () {
      final error = AppActorError.fromJson({
        'code': 2005,
        'message': 'Network error',
        'detail': 'Connection timeout, transient=true',
      });

      expect(error.code, 2005);
      expect(error.message, 'Network error');
      expect(error.detail, contains('transient=true'));
      expect(error.isTransient, true);
      expect(error.isSdkError, true);
      expect(error.isPluginError, false);
    });

    test('plugin error code range', () {
      final error = AppActorError(code: 1003, message: 'Unknown method');
      expect(error.isPluginError, true);
      expect(error.isSdkError, false);
    });

    test('equality', () {
      const a = AppActorError(code: 1001, message: 'Null response');
      const b = AppActorError(code: 1001, message: 'Null response');
      const c = AppActorError(code: 1002, message: 'Other');
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(c)));
    });

    test('toString', () {
      const error = AppActorError(code: 2005, message: 'Fail', detail: 'x');
      expect(error.toString(), contains('2005'));
      expect(error.toString(), contains('Fail'));
    });
  });

  group('AppActorCustomerInfo', () {
    test('fromJson parses empty customer info', () {
      final info = AppActorCustomerInfo.fromJson({});
      expect(info.entitlements, isEmpty);
      expect(info.subscriptions, isEmpty);
      expect(info.activeEntitlementKeys, isEmpty);
      expect(info.isComputedOffline, false);
    });

    test('fromJson parses full customer info', () {
      final info = AppActorCustomerInfo.fromJson({
        'app_user_id': 'user_123',
        'request_id': 'req_abc',
        'entitlements': {
          'premium': {
            'identifier': 'premium',
            'is_active': true,
            'product_identifier': 'com.app.monthly',
            'store': 'app_store',
            'ownership_type': 'purchased',
            'period_type': 'normal',
          },
        },
        'subscriptions': {
          'com.app.monthly': {
            'subscription_key': 'monthly',
            'product_identifier': 'com.app.monthly',
            'store': 'app_store',
            'is_active': true,
          },
        },
        'active_entitlement_keys': ['premium'],
        'is_computed_offline': false,
      });

      expect(info.appUserId, 'user_123');
      expect(info.requestId, 'req_abc');
      expect(info.entitlements.length, 1);
      expect(info.entitlements['premium']!.isActive, true);
      expect(info.activeEntitlementKeys, {'premium'});
      expect(info.hasActiveEntitlement('premium'), true);
      expect(info.hasActiveEntitlement('basic'), false);
    });

    test('equality', () {
      final json = {
        'app_user_id': 'user_1',
        'active_entitlement_keys': ['a'],
      };
      final a = AppActorCustomerInfo.fromJson(json);
      final b = AppActorCustomerInfo.fromJson(json);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);

      final c = AppActorCustomerInfo.fromJson({'app_user_id': 'user_2'});
      expect(a, isNot(equals(c)));
    });

    test('toString', () {
      final info = AppActorCustomerInfo.fromJson({'app_user_id': 'user_1'});
      expect(info.toString(), contains('user_1'));
    });
  });

  group('AppActorOfferings', () {
    test('fromJson parses offerings with packages', () {
      final offerings = AppActorOfferings.fromJson({
        'current': {
          'id': 'default',
          'display_name': 'Default Offering',
          'is_current': true,
          'metadata': {'tier': 'standard'},
          'packages': [
            {
              'id': 'monthly',
              'package_type': 'monthly',
              'product_id': 'com.app.monthly',
              'product_type': 'subscription',
              'store': 'app_store',
              'price': 9.99,
              'price_amount_micros': 9990000,
              'currency_code': 'USD',
              'localized_price_string': '\$9.99',
            },
          ],
        },
        'all': {},
        'product_entitlements': {
          'com.app.monthly': ['premium'],
        },
      });

      expect(offerings.current, isNotNull);
      expect(offerings.current!.id, 'default');
      expect(offerings.current!.metadata, {'tier': 'standard'});
      expect(offerings.current!.packages.length, 1);
      expect(offerings.current!.packages.first.price, 9.99);
      expect(offerings.current!.packages.first.priceAmountMicros, 9990000);
      expect(offerings.productEntitlements['com.app.monthly'], ['premium']);
    });

    test('equality', () {
      final json = {
        'current': {
          'id': 'default',
          'display_name': 'Test',
          'packages': [
            {'id': 'p1', 'product_id': 'pid1'},
          ],
        },
        'all': {},
      };
      final a = AppActorOfferings.fromJson(json);
      final b = AppActorOfferings.fromJson(json);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });
  });

  group('AppActorPurchaseResult', () {
    test('fromJson parses purchased result', () {
      final result = AppActorPurchaseResult.fromJson({
        'status': 'purchased',
        'customer_info': {'app_user_id': 'user_123'},
        'purchase_info': {
          'store': 'app_store',
          'product_id': 'com.app.monthly',
          'transaction_id': 'txn_123',
        },
      });

      expect(result.isPurchased, true);
      expect(result.isCancelled, false);
      expect(result.customerInfo?.appUserId, 'user_123');
      expect(result.purchaseInfo?.transactionId, 'txn_123');
    });

    test('equality', () {
      final json = {
        'status': 'purchased',
        'customer_info': {'app_user_id': 'u1'},
      };
      final a = AppActorPurchaseResult.fromJson(json);
      final b = AppActorPurchaseResult.fromJson(json);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });
  });

  group('AppActorPurchaseStatus', () {
    test('fromString parses valid values', () {
      expect(
        AppActorPurchaseStatus.fromString('purchased'),
        AppActorPurchaseStatus.purchased,
      );
      expect(
        AppActorPurchaseStatus.fromString('success'),
        AppActorPurchaseStatus.purchased,
      );
      expect(
        AppActorPurchaseStatus.fromString('cancelled'),
        AppActorPurchaseStatus.cancelled,
      );
      expect(
        AppActorPurchaseStatus.fromString('pending'),
        AppActorPurchaseStatus.pending,
      );
      expect(
        AppActorPurchaseStatus.fromString('restored'),
        AppActorPurchaseStatus.restored,
      );
    });

    test('fromString returns unknown for invalid values', () {
      expect(
        AppActorPurchaseStatus.fromString('invalid'),
        AppActorPurchaseStatus.unknown,
      );
      expect(
        AppActorPurchaseStatus.fromString(''),
        AppActorPurchaseStatus.unknown,
      );
    });
  });

  group('AppActorReceiptPipelineEvent', () {
    test('fromJson parses posted_ok event', () {
      final event = AppActorReceiptPipelineEvent.fromJson({
        'type': 'posted_ok',
        'transaction_id': 'GPA.1234-5678',
        'product_id': 'com.app.monthly',
        'app_user_id': 'user_123',
      });

      expect(event.isPostedOk, true);
      expect(event.transactionId, 'GPA.1234-5678');
      expect(event.key, isNull);
    });

    test('fromJson parses duplicate_skipped event', () {
      final event = AppActorReceiptPipelineEvent.fromJson({
        'type': 'duplicate_skipped',
        'product_id': 'com.app.monthly',
        'app_user_id': 'user_123',
        'key': 'receipt_abc123',
      });

      expect(event.isDuplicateSkipped, true);
      expect(event.transactionId, isNull);
      expect(event.key, 'receipt_abc123');
    });

    test('equality', () {
      final json = {
        'type': 'posted_ok',
        'product_id': 'p1',
        'app_user_id': 'u1',
      };
      final a = AppActorReceiptPipelineEvent.fromJson(json);
      final b = AppActorReceiptPipelineEvent.fromJson(json);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });
  });

  group('AppActorRemoteConfigs', () {
    test('fromJson and subscript access', () {
      final configs = AppActorRemoteConfigs.fromJson({
        'items': [
          {'key': 'paywall_v2', 'value': true, 'value_type': 'boolean'},
          {'key': 'trial_days', 'value': 7, 'value_type': 'integer'},
        ],
      });

      expect(configs['paywall_v2']?.boolValue, true);
      expect(configs['trial_days']?.numberValue, 7);
      expect(configs['nonexistent'], isNull);
    });

    test('equality', () {
      final json = {
        'items': [
          {'key': 'k', 'value': 'v', 'value_type': 'string'},
        ],
      };
      final a = AppActorRemoteConfigs.fromJson(json);
      final b = AppActorRemoteConfigs.fromJson(json);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });
  });

  group('AppActorExperimentAssignment', () {
    test('fromJson parses assignment', () {
      final assignment = AppActorExperimentAssignment.fromJson({
        'experiment_id': 'exp_001',
        'experiment_key': 'pricing_test',
        'variant_id': 'var_a',
        'variant_key': 'control',
        'payload': {'price': 4.99},
        'value_type': 'json',
        'assigned_at': '2026-03-30T00:00:00Z',
      });

      expect(assignment.experimentKey, 'pricing_test');
      expect(assignment.variantKey, 'control');
      expect(assignment.payload, isA<Map>());
    });

    test('equality with dynamic payload', () {
      final json = {
        'experiment_id': 'e1',
        'experiment_key': 'ek',
        'variant_id': 'v1',
        'variant_key': 'vk',
        'payload': {
          'nested': [1, 2, 3],
        },
        'value_type': 'json',
        'assigned_at': '2026-01-01',
      };
      final a = AppActorExperimentAssignment.fromJson(json);
      final b = AppActorExperimentAssignment.fromJson(json);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });
  });

  group('AppActorLogLevel', () {
    test('fromString parses valid values', () {
      expect(AppActorLogLevel.fromString('debug'), AppActorLogLevel.debug);
      expect(AppActorLogLevel.fromString('info'), AppActorLogLevel.info);
      expect(AppActorLogLevel.fromString('warn'), AppActorLogLevel.warn);
      expect(AppActorLogLevel.fromString('error'), AppActorLogLevel.error);
    });

    test('fromString defaults to info for unknown', () {
      expect(AppActorLogLevel.fromString('garbage'), AppActorLogLevel.info);
      expect(AppActorLogLevel.fromString(''), AppActorLogLevel.info);
    });

    test('wireValue matches enum name', () {
      for (final level in AppActorLogLevel.values) {
        expect(level.wireValue, level.name);
      }
    });
  });

  group('AppActorTokenBalance', () {
    test('equality and toString', () {
      const a = AppActorTokenBalance(renewable: 5, nonRenewable: 3, total: 8);
      const b = AppActorTokenBalance(renewable: 5, nonRenewable: 3, total: 8);
      const c = AppActorTokenBalance(renewable: 1, nonRenewable: 0, total: 1);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(c)));
      expect(a.toString(), contains('renewable: 5'));
    });
  });

  group('AppActorPurchaseIntent', () {
    test('fromJson parses full intent', () {
      final intent = AppActorPurchaseIntent.fromJson({
        'intent_id': 'abc-123',
        'product_id': 'com.app.yearly',
        'offer_id': 'win_back_1',
        'offer_type': 'winBack',
      });
      expect(intent.intentId, 'abc-123');
      expect(intent.productId, 'com.app.yearly');
      expect(intent.offerId, 'win_back_1');
      expect(intent.offerType, 'winBack');
    });

    test('fromJson handles null optionals', () {
      final intent = AppActorPurchaseIntent.fromJson({
        'intent_id': 'xyz',
        'product_id': 'com.app.monthly',
      });
      expect(intent.intentId, 'xyz');
      expect(intent.productId, 'com.app.monthly');
      expect(intent.offerId, isNull);
      expect(intent.offerType, isNull);
    });

    test('equality', () {
      final json = {
        'intent_id': 'id1',
        'product_id': 'p1',
        'offer_id': 'o1',
        'offer_type': 'promotional',
      };
      final a = AppActorPurchaseIntent.fromJson(json);
      final b = AppActorPurchaseIntent.fromJson(json);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('toString', () {
      const intent = AppActorPurchaseIntent(intentId: 'id', productId: 'pid');
      expect(intent.toString(), contains('intentId: id'));
      expect(intent.toString(), contains('productId: pid'));
    });
  });

  group('AppActorVerificationResult', () {
    test('fromString parses wire values', () {
      expect(
        AppActorVerificationResult.fromString('notRequested'),
        AppActorVerificationResult.notRequested,
      );
      expect(
        AppActorVerificationResult.fromString('verified'),
        AppActorVerificationResult.verified,
      );
      expect(
        AppActorVerificationResult.fromString('verifiedOnDevice'),
        AppActorVerificationResult.verifiedOnDevice,
      );
      expect(
        AppActorVerificationResult.fromString('failed'),
        AppActorVerificationResult.failed,
      );
    });

    test('fromString returns notRequested for unknown', () {
      expect(
        AppActorVerificationResult.fromString('garbage'),
        AppActorVerificationResult.notRequested,
      );
      expect(
        AppActorVerificationResult.fromString(''),
        AppActorVerificationResult.notRequested,
      );
    });

    test('isVerified', () {
      expect(AppActorVerificationResult.notRequested.isVerified, false);
      expect(AppActorVerificationResult.verified.isVerified, true);
      expect(AppActorVerificationResult.verifiedOnDevice.isVerified, true);
      expect(AppActorVerificationResult.failed.isVerified, false);
    });

    test('wireValue roundtrip', () {
      for (final v in AppActorVerificationResult.values) {
        expect(AppActorVerificationResult.fromString(v.wireValue), v);
      }
    });
  });

  group('CustomerInfo verification', () {
    test('fromJson parses verification field', () {
      final info = AppActorCustomerInfo.fromJson({
        'app_user_id': 'user_1',
        'verification': 'verified',
      });
      expect(info.verification, AppActorVerificationResult.verified);
      expect(info.verification.isVerified, true);
    });

    test('fromJson defaults verification to notRequested', () {
      final info = AppActorCustomerInfo.fromJson({'app_user_id': 'user_1'});
      expect(info.verification, AppActorVerificationResult.notRequested);
    });

    test('verification affects equality', () {
      final a = AppActorCustomerInfo.fromJson({
        'app_user_id': 'user_1',
        'verification': 'verified',
      });
      final b = AppActorCustomerInfo.fromJson({
        'app_user_id': 'user_1',
        'verification': 'failed',
      });
      expect(a, isNot(equals(b)));
    });
  });

  group('Offerings verification', () {
    test('fromJson parses verification field', () {
      final offerings = AppActorOfferings.fromJson({
        'all': {},
        'verification': 'verified',
      });
      expect(offerings.verification, AppActorVerificationResult.verified);
    });

    test('fromJson defaults verification to notRequested', () {
      final offerings = AppActorOfferings.fromJson({'all': {}});
      expect(offerings.verification, AppActorVerificationResult.notRequested);
    });

    test('verification affects equality', () {
      final a = AppActorOfferings.fromJson({
        'all': {},
        'verification': 'verified',
      });
      final b = AppActorOfferings.fromJson({
        'all': {},
        'verification': 'failed',
      });
      expect(a, isNot(equals(b)));
    });

    test('verifiedOnDevice from iOS', () {
      final offerings = AppActorOfferings.fromJson({
        'all': {},
        'verification': 'verifiedOnDevice',
      });
      expect(
        offerings.verification,
        AppActorVerificationResult.verifiedOnDevice,
      );
      expect(offerings.verification.isVerified, true);
    });
  });

  // ─── Typed Enum Tests ───

  group('AppActorStore', () {
    test('fromString parses wire values', () {
      expect(AppActorStore.fromString('play_store'), AppActorStore.playStore);
      expect(AppActorStore.fromString('app_store'), AppActorStore.appStore);
      expect(AppActorStore.fromString('stripe'), AppActorStore.stripe);
      expect(
        AppActorStore.fromString('promotional'),
        AppActorStore.promotional,
      );
      expect(AppActorStore.fromString('unknown'), AppActorStore.unknown);
    });

    test('fromString handles camelCase names', () {
      expect(AppActorStore.fromString('playStore'), AppActorStore.playStore);
      expect(AppActorStore.fromString('appStore'), AppActorStore.appStore);
    });

    test('fromString returns unknown for invalid', () {
      expect(AppActorStore.fromString('amazon'), AppActorStore.unknown);
      expect(AppActorStore.fromString(''), AppActorStore.unknown);
    });

    test('wireValue roundtrip', () {
      for (final v in AppActorStore.values) {
        expect(AppActorStore.fromString(v.wireValue), v);
      }
    });
  });

  group('AppActorPackageType', () {
    test('fromString parses wire values', () {
      expect(
        AppActorPackageType.fromString('weekly'),
        AppActorPackageType.weekly,
      );
      expect(
        AppActorPackageType.fromString('monthly'),
        AppActorPackageType.monthly,
      );
      expect(
        AppActorPackageType.fromString('two_month'),
        AppActorPackageType.twoMonth,
      );
      expect(
        AppActorPackageType.fromString('three_month'),
        AppActorPackageType.threeMonth,
      );
      expect(
        AppActorPackageType.fromString('six_month'),
        AppActorPackageType.sixMonth,
      );
      expect(
        AppActorPackageType.fromString('annual'),
        AppActorPackageType.annual,
      );
      expect(
        AppActorPackageType.fromString('lifetime'),
        AppActorPackageType.lifetime,
      );
      expect(
        AppActorPackageType.fromString('consumable'),
        AppActorPackageType.consumable,
      );
      expect(
        AppActorPackageType.fromString('custom'),
        AppActorPackageType.custom,
      );
    });

    test('fromString handles aliases', () {
      expect(
        AppActorPackageType.fromString('twoMonth'),
        AppActorPackageType.twoMonth,
      );
      expect(
        AppActorPackageType.fromString('two_months'),
        AppActorPackageType.twoMonth,
      );
      expect(
        AppActorPackageType.fromString('threeMonth'),
        AppActorPackageType.threeMonth,
      );
      expect(
        AppActorPackageType.fromString('three_months'),
        AppActorPackageType.threeMonth,
      );
      expect(
        AppActorPackageType.fromString('sixMonth'),
        AppActorPackageType.sixMonth,
      );
      expect(
        AppActorPackageType.fromString('six_months'),
        AppActorPackageType.sixMonth,
      );
    });

    test('fromString returns custom for invalid', () {
      expect(
        AppActorPackageType.fromString('biweekly'),
        AppActorPackageType.custom,
      );
    });

    test('wireValue roundtrip', () {
      for (final v in AppActorPackageType.values) {
        expect(AppActorPackageType.fromString(v.wireValue), v);
      }
    });
  });

  group('AppActorProductType', () {
    test('fromString parses wire values', () {
      expect(
        AppActorProductType.fromString('subscription'),
        AppActorProductType.subscription,
      );
      expect(
        AppActorProductType.fromString('non_consumable'),
        AppActorProductType.nonConsumable,
      );
      expect(
        AppActorProductType.fromString('consumable'),
        AppActorProductType.consumable,
      );
      expect(
        AppActorProductType.fromString('unknown'),
        AppActorProductType.unknown,
      );
    });

    test('fromString handles camelCase', () {
      expect(
        AppActorProductType.fromString('nonConsumable'),
        AppActorProductType.nonConsumable,
      );
    });

    test('wireValue roundtrip', () {
      for (final v in AppActorProductType.values) {
        expect(AppActorProductType.fromString(v.wireValue), v);
      }
    });
  });

  group('AppActorOwnershipType', () {
    test('fromString parses wire values', () {
      expect(
        AppActorOwnershipType.fromString('purchased'),
        AppActorOwnershipType.purchased,
      );
      expect(
        AppActorOwnershipType.fromString('family_shared'),
        AppActorOwnershipType.familyShared,
      );
      expect(
        AppActorOwnershipType.fromString('unknown'),
        AppActorOwnershipType.unknown,
      );
    });

    test('wireValue roundtrip', () {
      for (final v in AppActorOwnershipType.values) {
        expect(AppActorOwnershipType.fromString(v.wireValue), v);
      }
    });
  });

  group('AppActorPeriodType', () {
    test('fromString parses all wire values', () {
      expect(
        AppActorPeriodType.fromString('weekly'),
        AppActorPeriodType.weekly,
      );
      expect(
        AppActorPeriodType.fromString('monthly'),
        AppActorPeriodType.monthly,
      );
      expect(
        AppActorPeriodType.fromString('two_month'),
        AppActorPeriodType.twoMonth,
      );
      expect(
        AppActorPeriodType.fromString('three_month'),
        AppActorPeriodType.threeMonth,
      );
      expect(
        AppActorPeriodType.fromString('six_month'),
        AppActorPeriodType.sixMonth,
      );
      expect(
        AppActorPeriodType.fromString('annual'),
        AppActorPeriodType.annual,
      );
      expect(
        AppActorPeriodType.fromString('lifetime'),
        AppActorPeriodType.lifetime,
      );
      expect(
        AppActorPeriodType.fromString('normal'),
        AppActorPeriodType.normal,
      );
      expect(AppActorPeriodType.fromString('trial'), AppActorPeriodType.trial);
      expect(AppActorPeriodType.fromString('intro'), AppActorPeriodType.intro);
    });

    test('wireValue roundtrip', () {
      for (final v in AppActorPeriodType.values) {
        expect(AppActorPeriodType.fromString(v.wireValue), v);
      }
    });
  });

  group('AppActorSubscriptionStatus', () {
    test('fromString parses wire values', () {
      expect(
        AppActorSubscriptionStatus.fromString('active'),
        AppActorSubscriptionStatus.active,
      );
      expect(
        AppActorSubscriptionStatus.fromString('grace_period'),
        AppActorSubscriptionStatus.gracePeriod,
      );
      expect(
        AppActorSubscriptionStatus.fromString('billing_retry'),
        AppActorSubscriptionStatus.billingRetry,
      );
      expect(
        AppActorSubscriptionStatus.fromString('expired'),
        AppActorSubscriptionStatus.expired,
      );
      expect(
        AppActorSubscriptionStatus.fromString('revoked'),
        AppActorSubscriptionStatus.revoked,
      );
      expect(
        AppActorSubscriptionStatus.fromString('upgraded'),
        AppActorSubscriptionStatus.upgraded,
      );
    });

    test('wireValue roundtrip', () {
      for (final v in AppActorSubscriptionStatus.values) {
        expect(AppActorSubscriptionStatus.fromString(v.wireValue), v);
      }
    });
  });

  group('AppActorCancellationReason', () {
    test('fromString parses wire values', () {
      expect(
        AppActorCancellationReason.fromString('customer_cancelled'),
        AppActorCancellationReason.customerCancelled,
      );
      expect(
        AppActorCancellationReason.fromString('developer_cancelled'),
        AppActorCancellationReason.developerCancelled,
      );
    });

    test('wireValue roundtrip', () {
      for (final v in AppActorCancellationReason.values) {
        expect(AppActorCancellationReason.fromString(v.wireValue), v);
      }
    });
  });

  group('AppActorConfigValueType', () {
    test('fromString parses all values', () {
      expect(
        AppActorConfigValueType.fromString('boolean'),
        AppActorConfigValueType.boolean,
      );
      expect(
        AppActorConfigValueType.fromString('number'),
        AppActorConfigValueType.number,
      );
      expect(
        AppActorConfigValueType.fromString('string'),
        AppActorConfigValueType.string,
      );
      expect(
        AppActorConfigValueType.fromString('json'),
        AppActorConfigValueType.json,
      );
      expect(
        AppActorConfigValueType.fromString('unknown'),
        AppActorConfigValueType.unknown,
      );
    });

    test('fromString returns unknown for invalid', () {
      expect(
        AppActorConfigValueType.fromString('xml'),
        AppActorConfigValueType.unknown,
      );
    });
  });

  group('AppActorSubscriptionReplacementMode', () {
    test('fromString parses wire values', () {
      expect(
        AppActorSubscriptionReplacementMode.fromString('with_time_proration'),
        AppActorSubscriptionReplacementMode.withTimeProration,
      );
      expect(
        AppActorSubscriptionReplacementMode.fromString('charge_prorated'),
        AppActorSubscriptionReplacementMode.chargeProrated,
      );
      expect(
        AppActorSubscriptionReplacementMode.fromString('without_proration'),
        AppActorSubscriptionReplacementMode.withoutProration,
      );
      expect(
        AppActorSubscriptionReplacementMode.fromString('charge_full_price'),
        AppActorSubscriptionReplacementMode.chargeFullPrice,
      );
      expect(
        AppActorSubscriptionReplacementMode.fromString('deferred'),
        AppActorSubscriptionReplacementMode.deferred,
      );
    });

    test('fromString returns null for unknown', () {
      expect(AppActorSubscriptionReplacementMode.fromString(null), isNull);
      expect(AppActorSubscriptionReplacementMode.fromString('garbage'), isNull);
    });

    test('wireValue roundtrip', () {
      for (final v in AppActorSubscriptionReplacementMode.values) {
        expect(AppActorSubscriptionReplacementMode.fromString(v.wireValue), v);
      }
    });
  });

  // ─── Model Integration Tests ───

  group('Model enum integration', () {
    test('EntitlementInfo fromJson parses enums', () {
      final info = AppActorEntitlementInfo.fromJson({
        'identifier': 'premium',
        'is_active': true,
        'store': 'play_store',
        'ownership_type': 'family_shared',
        'period_type': 'monthly',
        'subscription_status': 'grace_period',
        'cancellation_reason': 'customer_cancelled',
      });
      expect(info.store, AppActorStore.playStore);
      expect(info.ownershipType, AppActorOwnershipType.familyShared);
      expect(info.periodType, AppActorPeriodType.monthly);
      expect(info.subscriptionStatus, AppActorSubscriptionStatus.gracePeriod);
      expect(
        info.cancellationReason,
        AppActorCancellationReason.customerCancelled,
      );
    });

    test('EntitlementInfo nullable enum fields', () {
      final info = AppActorEntitlementInfo.fromJson({
        'identifier': 'basic',
        'is_active': false,
      });
      expect(info.subscriptionStatus, isNull);
      expect(info.cancellationReason, isNull);
    });

    test('Package toPurchaseParams uses wireValue', () {
      const pkg = AppActorPackage(
        id: 'p1',
        productId: 'com.app.monthly',
        productType: AppActorProductType.subscription,
        store: AppActorStore.appStore,
      );
      final params = pkg.toPurchaseParams();
      expect(params['product_type'], 'subscription');
      expect(params['store'], 'app_store');
    });

    test('Package fromJson parses cross-platform packageType', () {
      // Android sends snake_case
      final android = AppActorPackage.fromJson({
        'id': 'p1',
        'product_id': 'pid',
        'package_type': 'two_month',
      });
      expect(android.packageType, AppActorPackageType.twoMonth);

      // iOS sends camelCase
      final ios = AppActorPackage.fromJson({
        'id': 'p2',
        'product_id': 'pid',
        'package_type': 'twoMonth',
      });
      expect(ios.packageType, AppActorPackageType.twoMonth);
    });

    test('RemoteConfigItem valueType is typed enum', () {
      final item = AppActorRemoteConfigItem.fromJson({
        'key': 'flag',
        'value': true,
        'value_type': 'boolean',
      });
      expect(item.valueType, AppActorConfigValueType.boolean);
    });

    test('ExperimentAssignment valueType is typed enum', () {
      final exp = AppActorExperimentAssignment.fromJson({
        'experiment_id': 'e1',
        'experiment_key': 'ek',
        'variant_id': 'v1',
        'variant_key': 'vk',
        'value_type': 'json',
        'assigned_at': '2026-01-01',
      });
      expect(exp.valueType, AppActorConfigValueType.json);
    });

    test('PurchaseInfo store is typed enum', () {
      final info = AppActorPurchaseInfo.fromJson({
        'store': 'app_store',
        'product_id': 'pid',
      });
      expect(info.store, AppActorStore.appStore);
    });

    test('Offering convenience accessors', () {
      final offering = AppActorOffering.fromJson({
        'id': 'default',
        'display_name': 'Default',
        'packages': [
          {
            'id': 'p1',
            'package_type': 'monthly',
            'product_id': 'com.app.monthly',
          },
          {
            'id': 'p2',
            'package_type': 'annual',
            'product_id': 'com.app.annual',
          },
          {'id': 'p3', 'package_type': 'six_month', 'product_id': 'com.app.6m'},
        ],
      });
      expect(offering.monthly?.id, 'p1');
      expect(offering.annual?.id, 'p2');
      expect(offering.sixMonth?.id, 'p3');
      expect(offering.weekly, isNull);
      expect(offering.lifetime, isNull);
      expect(offering.packageFor(AppActorPackageType.monthly)?.id, 'p1');
    });
  });

  group('Promotional offer fields', () {
    test('EntitlementInfo parses promo fields', () {
      final info = AppActorEntitlementInfo.fromJson({
        'identifier': 'premium',
        'is_active': true,
        'active_promotional_offer_type': 'intro7d',
        'active_promotional_offer_id': 'offer_123',
      });
      expect(info.activePromotionalOfferType, 'intro7d');
      expect(info.activePromotionalOfferId, 'offer_123');
    });

    test('SubscriptionInfo parses promo fields', () {
      final info = AppActorSubscriptionInfo.fromJson({
        'subscription_key': 'sub_1',
        'product_identifier': 'com.app.monthly',
        'is_active': true,
        'active_promotional_offer_type': 'winBack',
        'active_promotional_offer_id': 'offer_456',
      });
      expect(info.activePromotionalOfferType, 'winBack');
      expect(info.activePromotionalOfferId, 'offer_456');
    });

    test('promo fields are null when absent', () {
      final info = AppActorEntitlementInfo.fromJson({
        'identifier': 'basic',
        'is_active': false,
      });
      expect(info.activePromotionalOfferType, isNull);
      expect(info.activePromotionalOfferId, isNull);
    });
  });

  group('Error enrichment', () {
    test('fromJson parses enriched fields', () {
      final error = AppActorError.fromJson({
        'code': 2007,
        'message': 'Rate limited',
        'detail': 'httpStatus=429, transient=true',
        'request_id': 'req_abc123',
        'scope': 'ip',
        'retry_after_seconds': 30.0,
      });
      expect(error.requestId, 'req_abc123');
      expect(error.scope, 'ip');
      expect(error.retryAfterSeconds, 30.0);
      expect(error.isTransient, true);
    });

    test('fromJson handles missing enriched fields', () {
      final error = AppActorError.fromJson({
        'code': 2005,
        'message': 'Network error',
      });
      expect(error.requestId, isNull);
      expect(error.scope, isNull);
      expect(error.retryAfterSeconds, isNull);
    });

    test('enriched error equality', () {
      final a = AppActorError.fromJson({
        'code': 2007,
        'message': 'msg',
        'request_id': 'r1',
        'scope': 'ip',
        'retry_after_seconds': 10.0,
      });
      final b = AppActorError.fromJson({
        'code': 2007,
        'message': 'msg',
        'request_id': 'r1',
        'scope': 'ip',
        'retry_after_seconds': 10.0,
      });
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });
  });

  group('AppActorAsaDiagnostics', () {
    test('parses native iOS diagnostics fields', () {
      final diagnostics = AppActorAsaDiagnostics.fromJson({
        'attribution_completed': true,
        'pending_purchase_event_count': 2,
        'debug_mode': true,
        'auto_track_purchases': false,
        'track_in_sandbox': true,
      });

      expect(diagnostics.attributionCompleted, true);
      expect(diagnostics.pendingPurchaseEventCount, 2);
      expect(diagnostics.debugMode, true);
      expect(diagnostics.autoTrackPurchases, false);
      expect(diagnostics.trackInSandbox, true);
    });
  });
}
