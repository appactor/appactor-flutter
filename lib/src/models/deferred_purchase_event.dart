import 'package:flutter/foundation.dart';

import 'customer_info.dart';

/// Emitted when a previously pending (deferred) purchase resolves.
///
/// On iOS this corresponds to Ask-to-Buy approvals; on Android it covers
/// pending Google Play purchases (cash payments, slow carrier billing).
@immutable
class AppActorDeferredPurchaseEvent {
  final String productId;
  final AppActorCustomerInfo customerInfo;

  const AppActorDeferredPurchaseEvent({
    required this.productId,
    required this.customerInfo,
  });

  factory AppActorDeferredPurchaseEvent.fromJson(Map<String, dynamic> json) {
    return AppActorDeferredPurchaseEvent(
      productId: json['product_id'] as String? ?? '',
      customerInfo: AppActorCustomerInfo.fromJson(
        json['customer_info'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }

  @override
  String toString() =>
      'AppActorDeferredPurchaseEvent(productId: $productId)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppActorDeferredPurchaseEvent &&
          runtimeType == other.runtimeType &&
          productId == other.productId &&
          customerInfo == other.customerInfo;

  @override
  int get hashCode => Object.hash(productId, customerInfo);
}
