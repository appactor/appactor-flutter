import 'package:flutter/foundation.dart';

import 'enums.dart';

@immutable
class AppActorStorefront {
  final AppActorStore store;
  final String? countryCode;

  const AppActorStorefront({
    required this.store,
    this.countryCode,
  });

  factory AppActorStorefront.fromJson(Map<String, dynamic> json) {
    return AppActorStorefront(
      store: AppActorStore.fromString(json['store'] as String? ?? 'unknown'),
      countryCode: json['country_code'] as String?,
    );
  }

  @override
  String toString() =>
      'AppActorStorefront(store: $store, countryCode: $countryCode)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppActorStorefront &&
          runtimeType == other.runtimeType &&
          store == other.store &&
          countryCode == other.countryCode;

  @override
  int get hashCode => Object.hash(store, countryCode);
}
