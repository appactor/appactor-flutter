import '../appactor.dart';
import '../appactor_platform.dart';
import '../internal/method_names.dart';
import '../models/customer_info.dart';
import '../models/enums.dart';
import '../models/offerings.dart';
import '../models/purchase_result.dart';

extension AppActorPurchase on AppActor {
  Future<AppActorPurchaseResult> purchasePackage(
    AppActorPackage package, {
    String? offeringId,
    String? oldPurchaseToken,
    AppActorSubscriptionReplacementMode? replacementMode,
    int? quantity,
  }) async {
    final effectiveOfferingId = offeringId ?? package.offeringId;
    final result = await AppActorPlatform.execute(MethodNames.purchasePackage, {
      'package_id': package.id,
      if (effectiveOfferingId != null) 'offering_id': effectiveOfferingId,
      if (oldPurchaseToken != null) 'old_purchase_token': oldPurchaseToken,
      if (replacementMode != null) 'replacement_mode': replacementMode.wireValue,
      if (quantity != null) 'quantity': quantity,
    });
    return AppActorPurchaseResult.fromJson(result);
  }

  Future<AppActorCustomerInfo> restorePurchases({
    bool? syncWithAppStore,
  }) async {
    final result = await AppActorPlatform.execute(MethodNames.restorePurchases, {
      if (syncWithAppStore != null) 'sync_with_app_store': syncWithAppStore,
    });
    return AppActorCustomerInfo.fromJson(result);
  }

  Future<AppActorCustomerInfo> syncPurchases() async {
    final result = await AppActorPlatform.execute(MethodNames.syncPurchases);
    return AppActorCustomerInfo.fromJson(result);
  }
}
