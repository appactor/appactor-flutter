import 'package:flutter/foundation.dart';

/// Represents a promoted IAP or win-back offer from the App Store (iOS only).
///
/// Received via [AppActor.instance.onPurchaseIntent] stream. Use
/// [AppActor.instance.purchaseFromIntent] to complete the purchase.
@immutable
class AppActorPurchaseIntent {
  final String intentId;
  final String productId;
  final String? offerId;
  final String? offerType;

  const AppActorPurchaseIntent({
    required this.intentId,
    required this.productId,
    this.offerId,
    this.offerType,
  });

  factory AppActorPurchaseIntent.fromJson(Map<String, dynamic> json) {
    return AppActorPurchaseIntent(
      intentId: json['intent_id'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      offerId: json['offer_id'] as String?,
      offerType: json['offer_type'] as String?,
    );
  }

  @override
  String toString() =>
      'AppActorPurchaseIntent(intentId: $intentId, productId: $productId, '
      'offerId: $offerId, offerType: $offerType)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppActorPurchaseIntent &&
          runtimeType == other.runtimeType &&
          intentId == other.intentId &&
          productId == other.productId &&
          offerId == other.offerId &&
          offerType == other.offerType;

  @override
  int get hashCode => Object.hash(intentId, productId, offerId, offerType);
}
