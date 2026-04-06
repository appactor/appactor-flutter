import 'package:flutter/foundation.dart';
import 'customer_info.dart';
import 'enums.dart';

enum AppActorPurchaseStatus {
  purchased,
  cancelled,
  pending,
  restored,
  unknown;

  factory AppActorPurchaseStatus.fromString(String value) {
    // Native SDKs send "success" for completed purchases
    if (value == 'success') return AppActorPurchaseStatus.purchased;
    return AppActorPurchaseStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AppActorPurchaseStatus.unknown,
    );
  }
}

@immutable
class AppActorPurchaseResult {
  final AppActorPurchaseStatus status;
  final AppActorCustomerInfo? customerInfo;
  final AppActorPurchaseInfo? purchaseInfo;

  const AppActorPurchaseResult({
    required this.status,
    this.customerInfo,
    this.purchaseInfo,
  });

  bool get isPurchased => status == AppActorPurchaseStatus.purchased;
  bool get isCancelled => status == AppActorPurchaseStatus.cancelled;
  bool get isPending => status == AppActorPurchaseStatus.pending;
  bool get isRestored => status == AppActorPurchaseStatus.restored;

  factory AppActorPurchaseResult.fromJson(Map<String, dynamic> json) {
    return AppActorPurchaseResult(
      status: AppActorPurchaseStatus.fromString(
          json['status'] as String? ?? 'unknown'),
      customerInfo: json['customer_info'] != null
          ? AppActorCustomerInfo.fromJson(
              json['customer_info'] as Map<String, dynamic>)
          : null,
      purchaseInfo: json['purchase_info'] != null
          ? AppActorPurchaseInfo.fromJson(
              json['purchase_info'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  String toString() => 'AppActorPurchaseResult(status: ${status.name})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppActorPurchaseResult &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          customerInfo == other.customerInfo &&
          purchaseInfo == other.purchaseInfo;

  @override
  int get hashCode => Object.hash(status, customerInfo, purchaseInfo);
}

@immutable
class AppActorPurchaseInfo {
  final AppActorStore store;
  final String? productId;
  final String? transactionId;
  final String? originalTransactionId;
  final String? purchaseDate;
  final bool? isSandbox;

  const AppActorPurchaseInfo({
    this.store = AppActorStore.unknown,
    this.productId,
    this.transactionId,
    this.originalTransactionId,
    this.purchaseDate,
    this.isSandbox,
  });

  factory AppActorPurchaseInfo.fromJson(Map<String, dynamic> json) {
    return AppActorPurchaseInfo(
      store: AppActorStore.fromString(json['store'] as String? ?? 'unknown'),
      productId: json['product_id'] as String?,
      transactionId: json['transaction_id'] as String?,
      originalTransactionId: json['original_transaction_id'] as String?,
      purchaseDate: json['purchase_date'] as String?,
      isSandbox: json['is_sandbox'] as bool?,
    );
  }

  @override
  String toString() =>
      'AppActorPurchaseInfo(store: $store, '
      'productId: $productId, transactionId: $transactionId)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppActorPurchaseInfo &&
          runtimeType == other.runtimeType &&
          store == other.store &&
          productId == other.productId &&
          transactionId == other.transactionId &&
          originalTransactionId == other.originalTransactionId &&
          purchaseDate == other.purchaseDate &&
          isSandbox == other.isSandbox;

  @override
  int get hashCode => Object.hash(store, productId, transactionId,
      originalTransactionId, purchaseDate, isSandbox);
}
