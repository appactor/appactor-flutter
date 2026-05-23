import '../appactor.dart';
import '../appactor_platform.dart';
import '../internal/method_names.dart';
import '../models/customer_info.dart';
import '../models/enums.dart';
import '../models/offerings.dart';
import '../models/purchase_result.dart';

String? _normalizePlacement(String? placement) {
  final normalized = placement?.trim();
  if (normalized == null || normalized.isEmpty || normalized.length > 255) {
    return null;
  }
  return normalized;
}

extension AppActorPurchase on AppActor {
  Future<AppActorPurchaseResult> purchasePackage(
    AppActorPackage package, {
    String? offeringId,
    String? oldPurchaseToken,
    AppActorSubscriptionReplacementMode? replacementMode,
    int? quantity,
    String? placement,
  }) async {
    if (quantity != null && quantity < 1) {
      throw ArgumentError.value(
        quantity,
        'quantity',
        'Purchase quantity must be at least 1.',
      );
    }
    final effectiveOfferingId = offeringId ?? package.offeringId;
    final effectivePlacement = _normalizePlacement(placement);
    final result = await AppActorPlatform.execute(MethodNames.purchasePackage, {
      'package_id': package.id,
      if (effectiveOfferingId != null) 'offering_id': effectiveOfferingId,
      if (oldPurchaseToken != null) 'old_purchase_token': oldPurchaseToken,
      if (replacementMode != null)
        'replacement_mode': replacementMode.wireValue,
      if (quantity != null) 'quantity': quantity,
      if (effectivePlacement != null) 'placement': effectivePlacement,
    });
    return AppActorPurchaseResult.fromJson(result);
  }

  Future<AppActorCustomerInfo> restorePurchases({
    bool? syncWithAppStore,
  }) async {
    final result = await AppActorPlatform.execute(
      MethodNames.restorePurchases,
      {if (syncWithAppStore != null) 'sync_with_app_store': syncWithAppStore},
    );
    return AppActorCustomerInfo.fromJson(result);
  }

  /// Quietly syncs store purchases to the backend without draining the
  /// local receipt queue.
  Future<AppActorCustomerInfo> syncPurchases() async {
    final result = await AppActorPlatform.execute(MethodNames.syncPurchases);
    return AppActorCustomerInfo.fromJson(result);
  }

  /// Deprecated alias for [syncPurchases].
  Future<AppActorCustomerInfo> quietSyncPurchases() async {
    final result = await AppActorPlatform.execute(
      MethodNames.quietSyncPurchases,
    );
    return AppActorCustomerInfo.fromJson(result);
  }

  /// Explicit queue-drain + customer refresh call exposed by the native SDK.
  Future<AppActorCustomerInfo> drainReceiptQueueAndRefreshCustomer() async {
    final result = await AppActorPlatform.execute(
      MethodNames.drainReceiptQueueAndRefreshCustomer,
    );
    return AppActorCustomerInfo.fromJson(result);
  }
}
