import 'package:flutter/foundation.dart';

import '../internal/deep_equals.dart';
import 'enums.dart';

@immutable
class AppActorCustomerInfo {
  final Map<String, AppActorEntitlementInfo> entitlements;
  final Map<String, AppActorSubscriptionInfo> subscriptions;
  final Map<String, List<AppActorNonSubscription>> nonSubscriptions;
  final Map<String, int>? consumableBalances;
  final AppActorTokenBalance? tokenBalance;
  final String? snapshotDate;
  final String? appUserId;
  final String? requestId;
  final String? requestDate;
  final String? firstSeen;
  final String? lastSeen;
  final String? managementUrl;
  final bool isComputedOffline;
  final Map<String, List<String>> productEntitlements;
  final Set<String> activeEntitlementKeys;

  const AppActorCustomerInfo({
    this.entitlements = const {},
    this.subscriptions = const {},
    this.nonSubscriptions = const {},
    this.consumableBalances,
    this.tokenBalance,
    this.snapshotDate,
    this.appUserId,
    this.requestId,
    this.requestDate,
    this.firstSeen,
    this.lastSeen,
    this.managementUrl,
    this.isComputedOffline = false,
    this.productEntitlements = const {},
    this.activeEntitlementKeys = const {},
  });

  Map<String, AppActorEntitlementInfo> get activeEntitlements =>
      Map.fromEntries(entitlements.entries.where((e) => e.value.isActive));

  bool hasActiveEntitlement(String key) =>
      activeEntitlementKeys.contains(key);

  factory AppActorCustomerInfo.fromJson(Map<String, dynamic> json) {
    final entitlements = _parseEntitlements(json['entitlements']);
    return AppActorCustomerInfo(
      entitlements: entitlements,
      subscriptions: _parseSubscriptions(json['subscriptions']),
      nonSubscriptions: _parseNonSubscriptions(json['non_subscriptions']),
      consumableBalances: json['consumable_balances'] != null
          ? Map<String, int>.from(
              (json['consumable_balances'] as Map).map(
                (k, v) => MapEntry(k as String, (v as num).toInt()),
              ),
            )
          : null,
      tokenBalance: json['token_balance'] != null
          ? AppActorTokenBalance.fromJson(
              json['token_balance'] as Map<String, dynamic>)
          : null,
      snapshotDate: json['snapshot_date'] as String?,
      appUserId: json['app_user_id'] as String?,
      requestId: json['request_id'] as String?,
      requestDate: json['request_date'] as String?,
      firstSeen: json['first_seen'] as String?,
      lastSeen: json['last_seen'] as String?,
      managementUrl: json['management_url'] as String?,
      isComputedOffline: json['is_computed_offline'] as bool? ?? false,
      productEntitlements: json['product_entitlements'] != null
          ? (json['product_entitlements'] as Map).map(
              (k, v) => MapEntry(
                k as String,
                (v as List).map((e) => e as String).toList(),
              ),
            )
          : const {},
      activeEntitlementKeys: json['active_entitlement_keys'] != null
          ? Set<String>.from(json['active_entitlement_keys'] as Iterable)
          : const {},
    );
  }

  static Map<String, AppActorEntitlementInfo> _parseEntitlements(dynamic raw) {
    if (raw is! Map) return const {};
    return raw.map((k, v) => MapEntry(
          k as String,
          AppActorEntitlementInfo.fromJson(v as Map<String, dynamic>),
        ));
  }

  static Map<String, AppActorSubscriptionInfo> _parseSubscriptions(
      dynamic raw) {
    if (raw is! Map) return const {};
    return raw.map((k, v) => MapEntry(
          k as String,
          AppActorSubscriptionInfo.fromJson(v as Map<String, dynamic>),
        ));
  }

  static Map<String, List<AppActorNonSubscription>> _parseNonSubscriptions(
      dynamic raw) {
    if (raw is! Map) return const {};
    return raw.map((k, v) => MapEntry(
          k as String,
          (v as List)
              .map((e) => AppActorNonSubscription.fromJson(
                  e as Map<String, dynamic>))
              .toList(),
        ));
  }

  @override
  String toString() =>
      'AppActorCustomerInfo(appUserId: $appUserId, '
      '${entitlements.length} entitlements, '
      '${subscriptions.length} subscriptions, '
      'activeKeys: $activeEntitlementKeys)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppActorCustomerInfo &&
          runtimeType == other.runtimeType &&
          appUserId == other.appUserId &&
          requestId == other.requestId &&
          isComputedOffline == other.isComputedOffline &&
          snapshotDate == other.snapshotDate &&
          requestDate == other.requestDate &&
          firstSeen == other.firstSeen &&
          lastSeen == other.lastSeen &&
          managementUrl == other.managementUrl &&
          tokenBalance == other.tokenBalance &&
          setEquals(activeEntitlementKeys, other.activeEntitlementKeys) &&
          mapEquals(consumableBalances, other.consumableBalances) &&
          mapEquals(entitlements, other.entitlements) &&
          mapEquals(subscriptions, other.subscriptions) &&
          mapOfListsEquals(nonSubscriptions, other.nonSubscriptions) &&
          mapOfListsEquals(productEntitlements, other.productEntitlements);

  @override
  int get hashCode => Object.hashAll([
        appUserId,
        requestId,
        isComputedOffline,
        snapshotDate,
        requestDate,
        firstSeen,
        lastSeen,
        managementUrl,
        tokenBalance,
        Object.hashAll(activeEntitlementKeys.toList()..sort()),
        entitlements.length,
        subscriptions.length,
      ]);
}

@immutable
class AppActorEntitlementInfo {
  final String identifier;
  final bool isActive;
  final String? status;
  final String? productIdentifier;
  final String? grantedBy;
  final AppActorOwnershipType ownershipType;
  final AppActorPeriodType periodType;
  final bool willRenew;
  final AppActorSubscriptionStatus? subscriptionStatus;
  final AppActorStore store;
  final String? basePlanId;
  final String? offerId;
  final bool? isSandbox;
  final AppActorCancellationReason? cancellationReason;
  final String? purchaseDate;
  final String? startsAt;
  final String? latestPurchaseDate;
  final String? originalPurchaseDate;
  final String? expirationDate;
  final String? gracePeriodExpiresAt;
  final String? billingIssueDetectedAt;
  final String? unsubscribeDetectedAt;
  final String? renewedAt;
  final String? activePromotionalOfferType;
  final String? activePromotionalOfferId;

  const AppActorEntitlementInfo({
    required this.identifier,
    required this.isActive,
    this.status,
    this.productIdentifier,
    this.grantedBy,
    this.ownershipType = AppActorOwnershipType.unknown,
    this.periodType = AppActorPeriodType.normal,
    this.willRenew = false,
    this.subscriptionStatus,
    this.store = AppActorStore.unknown,
    this.basePlanId,
    this.offerId,
    this.isSandbox,
    this.cancellationReason,
    this.purchaseDate,
    this.startsAt,
    this.latestPurchaseDate,
    this.originalPurchaseDate,
    this.expirationDate,
    this.gracePeriodExpiresAt,
    this.billingIssueDetectedAt,
    this.unsubscribeDetectedAt,
    this.renewedAt,
    this.activePromotionalOfferType,
    this.activePromotionalOfferId,
  });

  factory AppActorEntitlementInfo.fromJson(Map<String, dynamic> json) {
    return AppActorEntitlementInfo(
      identifier: json['identifier'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? false,
      status: json['status'] as String?,
      productIdentifier: json['product_identifier'] as String?,
      grantedBy: json['granted_by'] as String?,
      ownershipType: AppActorOwnershipType.fromString(
          json['ownership_type'] as String? ?? 'unknown'),
      periodType: AppActorPeriodType.fromString(
          json['period_type'] as String? ?? 'normal'),
      willRenew: json['will_renew'] as bool? ?? false,
      subscriptionStatus: json['subscription_status'] != null
          ? AppActorSubscriptionStatus.fromString(
              json['subscription_status'] as String)
          : null,
      store: AppActorStore.fromString(json['store'] as String? ?? 'unknown'),
      basePlanId: json['base_plan_id'] as String?,
      offerId: json['offer_id'] as String?,
      isSandbox: json['is_sandbox'] as bool?,
      cancellationReason: json['cancellation_reason'] != null
          ? AppActorCancellationReason.fromString(
              json['cancellation_reason'] as String)
          : null,
      purchaseDate: json['purchase_date'] as String?,
      startsAt: json['starts_at'] as String?,
      latestPurchaseDate: json['latest_purchase_date'] as String?,
      originalPurchaseDate: json['original_purchase_date'] as String?,
      expirationDate: json['expiration_date'] as String?,
      gracePeriodExpiresAt: json['grace_period_expires_at'] as String?,
      billingIssueDetectedAt: json['billing_issue_detected_at'] as String?,
      unsubscribeDetectedAt: json['unsubscribe_detected_at'] as String?,
      renewedAt: json['renewed_at'] as String?,
      activePromotionalOfferType:
          json['active_promotional_offer_type'] as String?,
      activePromotionalOfferId:
          json['active_promotional_offer_id'] as String?,
    );
  }

  @override
  String toString() =>
      'AppActorEntitlementInfo(identifier: $identifier, '
      'isActive: $isActive, store: $store, '
      'productIdentifier: $productIdentifier)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppActorEntitlementInfo &&
          runtimeType == other.runtimeType &&
          identifier == other.identifier &&
          isActive == other.isActive &&
          status == other.status &&
          productIdentifier == other.productIdentifier &&
          grantedBy == other.grantedBy &&
          ownershipType == other.ownershipType &&
          periodType == other.periodType &&
          willRenew == other.willRenew &&
          subscriptionStatus == other.subscriptionStatus &&
          store == other.store &&
          basePlanId == other.basePlanId &&
          offerId == other.offerId &&
          isSandbox == other.isSandbox &&
          cancellationReason == other.cancellationReason &&
          purchaseDate == other.purchaseDate &&
          startsAt == other.startsAt &&
          latestPurchaseDate == other.latestPurchaseDate &&
          originalPurchaseDate == other.originalPurchaseDate &&
          expirationDate == other.expirationDate &&
          gracePeriodExpiresAt == other.gracePeriodExpiresAt &&
          billingIssueDetectedAt == other.billingIssueDetectedAt &&
          unsubscribeDetectedAt == other.unsubscribeDetectedAt &&
          renewedAt == other.renewedAt &&
          activePromotionalOfferType == other.activePromotionalOfferType &&
          activePromotionalOfferId == other.activePromotionalOfferId;

  @override
  int get hashCode => Object.hashAll([
        identifier, isActive, status, productIdentifier, grantedBy,
        ownershipType, periodType, willRenew, subscriptionStatus, store,
        basePlanId, offerId, isSandbox, cancellationReason, purchaseDate,
        startsAt, latestPurchaseDate, originalPurchaseDate, expirationDate,
        gracePeriodExpiresAt, billingIssueDetectedAt, unsubscribeDetectedAt,
        renewedAt, activePromotionalOfferType, activePromotionalOfferId,
      ]);
}

@immutable
class AppActorSubscriptionInfo {
  final String subscriptionKey;
  final String productIdentifier;
  final AppActorStore store;
  final String? basePlanId;
  final String? offerId;
  final bool isActive;
  final String? expiresDate;
  final String? purchaseDate;
  final String? startsAt;
  final AppActorPeriodType? periodType;
  final String? status;
  final bool? autoRenew;
  final bool? isSandbox;
  final String? gracePeriodExpiresAt;
  final String? unsubscribeDetectedAt;
  final AppActorCancellationReason? cancellationReason;
  final String? renewedAt;
  final String? originalTransactionId;
  final String? latestTransactionId;
  final String? activePromotionalOfferType;
  final String? activePromotionalOfferId;

  const AppActorSubscriptionInfo({
    required this.subscriptionKey,
    required this.productIdentifier,
    this.store = AppActorStore.unknown,
    this.basePlanId,
    this.offerId,
    this.isActive = false,
    this.expiresDate,
    this.purchaseDate,
    this.startsAt,
    this.periodType,
    this.status,
    this.autoRenew,
    this.isSandbox,
    this.gracePeriodExpiresAt,
    this.unsubscribeDetectedAt,
    this.cancellationReason,
    this.renewedAt,
    this.originalTransactionId,
    this.latestTransactionId,
    this.activePromotionalOfferType,
    this.activePromotionalOfferId,
  });

  factory AppActorSubscriptionInfo.fromJson(Map<String, dynamic> json) {
    return AppActorSubscriptionInfo(
      subscriptionKey: json['subscription_key'] as String? ?? '',
      productIdentifier: json['product_identifier'] as String? ?? '',
      store: AppActorStore.fromString(json['store'] as String? ?? 'unknown'),
      basePlanId: json['base_plan_id'] as String?,
      offerId: json['offer_id'] as String?,
      isActive: json['is_active'] as bool? ?? false,
      expiresDate: json['expires_date'] as String?,
      purchaseDate: json['purchase_date'] as String?,
      startsAt: json['starts_at'] as String?,
      periodType: json['period_type'] != null
          ? AppActorPeriodType.fromString(json['period_type'] as String)
          : null,
      status: json['status'] as String?,
      autoRenew: json['auto_renew'] as bool?,
      isSandbox: json['is_sandbox'] as bool?,
      gracePeriodExpiresAt: json['grace_period_expires_at'] as String?,
      unsubscribeDetectedAt: json['unsubscribe_detected_at'] as String?,
      cancellationReason: json['cancellation_reason'] != null
          ? AppActorCancellationReason.fromString(
              json['cancellation_reason'] as String)
          : null,
      renewedAt: json['renewed_at'] as String?,
      originalTransactionId: json['original_transaction_id'] as String?,
      latestTransactionId: json['latest_transaction_id'] as String?,
      activePromotionalOfferType:
          json['active_promotional_offer_type'] as String?,
      activePromotionalOfferId:
          json['active_promotional_offer_id'] as String?,
    );
  }

  @override
  String toString() =>
      'AppActorSubscriptionInfo(subscriptionKey: $subscriptionKey, '
      'productIdentifier: $productIdentifier, '
      'isActive: $isActive, store: $store)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppActorSubscriptionInfo &&
          runtimeType == other.runtimeType &&
          subscriptionKey == other.subscriptionKey &&
          productIdentifier == other.productIdentifier &&
          store == other.store &&
          basePlanId == other.basePlanId &&
          offerId == other.offerId &&
          isActive == other.isActive &&
          expiresDate == other.expiresDate &&
          purchaseDate == other.purchaseDate &&
          startsAt == other.startsAt &&
          periodType == other.periodType &&
          status == other.status &&
          autoRenew == other.autoRenew &&
          isSandbox == other.isSandbox &&
          gracePeriodExpiresAt == other.gracePeriodExpiresAt &&
          unsubscribeDetectedAt == other.unsubscribeDetectedAt &&
          cancellationReason == other.cancellationReason &&
          renewedAt == other.renewedAt &&
          originalTransactionId == other.originalTransactionId &&
          latestTransactionId == other.latestTransactionId &&
          activePromotionalOfferType == other.activePromotionalOfferType &&
          activePromotionalOfferId == other.activePromotionalOfferId;

  @override
  int get hashCode => Object.hashAll([
        subscriptionKey, productIdentifier, store, basePlanId, offerId,
        isActive, expiresDate, purchaseDate, startsAt, periodType,
        status, autoRenew, isSandbox, gracePeriodExpiresAt,
        unsubscribeDetectedAt, cancellationReason, renewedAt,
        originalTransactionId, latestTransactionId,
        activePromotionalOfferType, activePromotionalOfferId,
      ]);
}

@immutable
class AppActorNonSubscription {
  final String productIdentifier;
  final AppActorStore store;
  final String? basePlanId;
  final String? offerId;
  final String? originalTransactionIdentifier;
  final String? purchaseDate;
  final String? storeTransactionIdentifier;
  final bool? isSandbox;
  final bool? isConsumable;
  final bool? isRefund;

  const AppActorNonSubscription({
    required this.productIdentifier,
    this.store = AppActorStore.unknown,
    this.basePlanId,
    this.offerId,
    this.originalTransactionIdentifier,
    this.purchaseDate,
    this.storeTransactionIdentifier,
    this.isSandbox,
    this.isConsumable,
    this.isRefund,
  });

  factory AppActorNonSubscription.fromJson(Map<String, dynamic> json) {
    return AppActorNonSubscription(
      productIdentifier: json['product_identifier'] as String? ?? '',
      store: AppActorStore.fromString(json['store'] as String? ?? 'unknown'),
      basePlanId: json['base_plan_id'] as String?,
      offerId: json['offer_id'] as String?,
      originalTransactionIdentifier:
          json['original_transaction_identifier'] as String?,
      purchaseDate: json['purchase_date'] as String?,
      storeTransactionIdentifier:
          json['store_transaction_identifier'] as String?,
      isSandbox: json['is_sandbox'] as bool?,
      isConsumable: json['is_consumable'] as bool?,
      isRefund: json['is_refund'] as bool?,
    );
  }

  @override
  String toString() =>
      'AppActorNonSubscription(productIdentifier: $productIdentifier, '
      'store: $store)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppActorNonSubscription &&
          runtimeType == other.runtimeType &&
          productIdentifier == other.productIdentifier &&
          store == other.store &&
          basePlanId == other.basePlanId &&
          offerId == other.offerId &&
          originalTransactionIdentifier ==
              other.originalTransactionIdentifier &&
          purchaseDate == other.purchaseDate &&
          storeTransactionIdentifier == other.storeTransactionIdentifier &&
          isSandbox == other.isSandbox &&
          isConsumable == other.isConsumable &&
          isRefund == other.isRefund;

  @override
  int get hashCode => Object.hash(
      productIdentifier, store, basePlanId, offerId,
      originalTransactionIdentifier, purchaseDate,
      storeTransactionIdentifier, isSandbox, isConsumable, isRefund);
}

@immutable
class AppActorTokenBalance {
  final int renewable;
  final int nonRenewable;
  final int total;

  const AppActorTokenBalance({
    required this.renewable,
    required this.nonRenewable,
    required this.total,
  });

  factory AppActorTokenBalance.fromJson(Map<String, dynamic> json) {
    return AppActorTokenBalance(
      renewable: (json['renewable'] as num?)?.toInt() ?? 0,
      nonRenewable: (json['non_renewable'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  String toString() =>
      'AppActorTokenBalance(renewable: $renewable, '
      'nonRenewable: $nonRenewable, total: $total)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppActorTokenBalance &&
          runtimeType == other.runtimeType &&
          renewable == other.renewable &&
          nonRenewable == other.nonRenewable &&
          total == other.total;

  @override
  int get hashCode => Object.hash(renewable, nonRenewable, total);
}
