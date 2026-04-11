import 'package:flutter/foundation.dart';

import '../internal/deep_equals.dart';
import 'enums.dart';

@immutable
class AppActorOfferings {
  final AppActorOffering? current;
  final Map<String, AppActorOffering> all;
  final Map<String, List<String>> productEntitlements;

  const AppActorOfferings({
    this.current,
    this.all = const {},
    this.productEntitlements = const {},
  });

  AppActorOffering? offering(String id) => all[id];

  AppActorOffering? offeringByLookupKey(String lookupKey) {
    for (final offering in all.values) {
      if (offering.lookupKey == lookupKey) return offering;
    }
    return null;
  }

  factory AppActorOfferings.fromJson(Map<String, dynamic> json) {
    final allMap = <String, AppActorOffering>{};
    if (json['all'] is Map) {
      for (final entry in (json['all'] as Map).entries) {
        allMap[entry.key as String] = AppActorOffering.fromJson(
          entry.value as Map<String, dynamic>,
        );
      }
    }
    return AppActorOfferings(
      current: json['current'] != null
          ? AppActorOffering.fromJson(
              json['current'] as Map<String, dynamic>)
          : null,
      all: allMap,
      productEntitlements: json['product_entitlements'] != null
          ? (json['product_entitlements'] as Map).map(
              (k, v) => MapEntry(
                k as String,
                (v as List).map((e) => e as String).toList(),
              ),
            )
          : const {},
    );
  }

  @override
  String toString() =>
      'AppActorOfferings(current: ${current?.id}, ${all.length} offerings)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppActorOfferings &&
          runtimeType == other.runtimeType &&
          current == other.current &&
          mapEquals(all, other.all) &&
          mapOfListsEquals(productEntitlements, other.productEntitlements);

  @override
  int get hashCode => Object.hash(current, all.length, productEntitlements.length);
}

@immutable
class AppActorOffering {
  final String id;
  final String displayName;
  final bool isCurrent;
  final String? lookupKey;
  final Map<String, String>? metadata;
  final List<AppActorPackage> packages;

  const AppActorOffering({
    required this.id,
    required this.displayName,
    this.isCurrent = false,
    this.lookupKey,
    this.metadata,
    this.packages = const [],
  });

  AppActorPackage? package(String id) {
    for (final p in packages) {
      if (p.id == id) return p;
    }
    return null;
  }

  AppActorPackage? packageFor(AppActorPackageType type) {
    for (final p in packages) {
      if (p.packageType == type) return p;
    }
    return null;
  }

  AppActorPackage? get weekly => packageFor(AppActorPackageType.weekly);
  AppActorPackage? get monthly => packageFor(AppActorPackageType.monthly);
  AppActorPackage? get twoMonth => packageFor(AppActorPackageType.twoMonth);
  AppActorPackage? get threeMonth => packageFor(AppActorPackageType.threeMonth);
  AppActorPackage? get sixMonth => packageFor(AppActorPackageType.sixMonth);
  AppActorPackage? get annual => packageFor(AppActorPackageType.annual);
  AppActorPackage? get lifetime => packageFor(AppActorPackageType.lifetime);

  factory AppActorOffering.fromJson(Map<String, dynamic> json) {
    return AppActorOffering(
      id: json['id'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
      isCurrent: json['is_current'] as bool? ?? false,
      lookupKey: json['lookup_key'] as String?,
      metadata: json['metadata'] != null
          ? Map<String, String>.from(json['metadata'] as Map)
          : null,
      packages: json['packages'] is List
          ? (json['packages'] as List)
              .map((e) =>
                  AppActorPackage.fromJson(e as Map<String, dynamic>))
              .toList()
          : const [],
    );
  }

  @override
  String toString() =>
      'AppActorOffering(id: $id, displayName: $displayName, '
      '${packages.length} packages)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppActorOffering &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          displayName == other.displayName &&
          isCurrent == other.isCurrent &&
          lookupKey == other.lookupKey &&
          mapEquals(metadata, other.metadata) &&
          listEquals(packages, other.packages);

  @override
  int get hashCode =>
      Object.hash(id, displayName, isCurrent, lookupKey, packages.length);
}

@immutable
class AppActorPackage {
  final String id;
  final AppActorPackageType packageType;
  final String productId;
  final String? storeProductId;
  final AppActorProductType productType;
  final AppActorStore store;
  final String? basePlanId;
  final String? offerId;
  final String? localizedPriceString;
  final double? price;
  final String? currencyCode;
  final String? displayName;
  final String? productName;
  final String? productDescription;
  final Map<String, String>? metadata;
  final int? tokenAmount;
  final int? position;
  final String? serverId;
  final String? offeringId;

  const AppActorPackage({
    required this.id,
    this.packageType = AppActorPackageType.custom,
    required this.productId,
    this.storeProductId,
    this.productType = AppActorProductType.unknown,
    this.store = AppActorStore.unknown,
    this.basePlanId,
    this.offerId,
    this.localizedPriceString,
    this.price,
    this.currencyCode,
    this.displayName,
    this.productName,
    this.productDescription,
    this.metadata,
    this.tokenAmount,
    this.position,
    this.serverId,
    this.offeringId,
  });

  Map<String, dynamic> toPurchaseParams() => {
        'package_id': id,
        if (storeProductId != null) 'store_product_id': storeProductId,
        'product_id': productId,
        'product_type': productType.wireValue,
        'store': store.wireValue,
        if (basePlanId != null) 'base_plan_id': basePlanId,
        if (offerId != null) 'offer_id': offerId,
        if (offeringId != null) 'offering_id': offeringId,
      };

  @Deprecated('Use toPurchaseParams() instead')
  Map<String, dynamic> toJson() => toPurchaseParams();

  factory AppActorPackage.fromJson(Map<String, dynamic> json) {
    return AppActorPackage(
      id: json['id'] as String? ?? '',
      packageType: AppActorPackageType.fromString(
          json['package_type'] as String? ?? 'custom'),
      productId: json['product_id'] as String? ?? '',
      storeProductId: json['store_product_id'] as String?,
      productType: AppActorProductType.fromString(
          json['product_type'] as String? ?? 'unknown'),
      store: AppActorStore.fromString(json['store'] as String? ?? 'unknown'),
      basePlanId: json['base_plan_id'] as String?,
      offerId: json['offer_id'] as String?,
      localizedPriceString: json['localized_price_string'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      currencyCode: json['currency_code'] as String?,
      displayName: json['display_name'] as String?,
      productName: json['product_name'] as String?,
      productDescription: json['product_description'] as String?,
      metadata: json['metadata'] != null
          ? Map<String, String>.from(json['metadata'] as Map)
          : null,
      tokenAmount: (json['token_amount'] as num?)?.toInt(),
      position: (json['position'] as num?)?.toInt(),
      serverId: json['server_id'] as String?,
      offeringId: json['offering_id'] as String?,
    );
  }

  @override
  String toString() =>
      'AppActorPackage(id: $id, productId: $productId, '
      '${localizedPriceString ?? price}, store: $store)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppActorPackage &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          packageType == other.packageType &&
          productId == other.productId &&
          storeProductId == other.storeProductId &&
          productType == other.productType &&
          store == other.store &&
          basePlanId == other.basePlanId &&
          offerId == other.offerId &&
          localizedPriceString == other.localizedPriceString &&
          price == other.price &&
          currencyCode == other.currencyCode &&
          displayName == other.displayName &&
          productName == other.productName &&
          productDescription == other.productDescription &&
          mapEquals(metadata, other.metadata) &&
          tokenAmount == other.tokenAmount &&
          position == other.position &&
          serverId == other.serverId &&
          offeringId == other.offeringId;

  @override
  int get hashCode => Object.hashAll([
        id, packageType, productId, storeProductId, productType, store,
        basePlanId, offerId, localizedPriceString, price, currencyCode,
        displayName, productName, productDescription, metadata?.length,
        tokenAmount, position, serverId, offeringId,
      ]);
}
