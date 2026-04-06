import '../appactor.dart';
import '../appactor_platform.dart';
import '../models/customer_info.dart';
import '../models/deferred_purchase_event.dart';
import '../models/purchase_intent.dart';
import '../models/receipt_event.dart';

extension AppActorStreams on AppActor {
  Stream<AppActorCustomerInfo> get onCustomerInfoUpdated =>
      AppActorPlatform.customerInfoEvents
          .map((json) => AppActorCustomerInfo.fromJson(json));

  Stream<AppActorReceiptPipelineEvent> get onReceiptPipelineEvent =>
      AppActorPlatform.receiptPipelineEvents
          .map((json) => AppActorReceiptPipelineEvent.fromJson(json));

  /// Stream of promoted IAP / win-back offer intents from the App Store.
  /// iOS only (iOS 16.4+). Never emits on Android.
  Stream<AppActorPurchaseIntent> get onPurchaseIntent =>
      AppActorPlatform.purchaseIntentEvents
          .map((json) => AppActorPurchaseIntent.fromJson(json));

  /// Emits when a previously pending (deferred) purchase resolves.
  ///
  /// On iOS: Ask-to-Buy approvals. On Android: pending Google Play purchases.
  Stream<AppActorDeferredPurchaseEvent> get onDeferredPurchaseResolved =>
      AppActorPlatform.deferredPurchaseEvents
          .map((json) => AppActorDeferredPurchaseEvent.fromJson(json));
}
