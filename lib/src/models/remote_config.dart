import 'package:flutter/foundation.dart';

import '../internal/deep_equals.dart';
import 'enums.dart';

@immutable
class AppActorRemoteConfigs {
  final List<AppActorRemoteConfigItem> items;

  const AppActorRemoteConfigs({this.items = const []});

  AppActorRemoteConfigItem? operator [](String key) {
    for (final item in items) {
      if (item.key == key) return item;
    }
    return null;
  }

  factory AppActorRemoteConfigs.fromJson(Map<String, dynamic> json) {
    return AppActorRemoteConfigs(
      items: json['items'] is List
          ? (json['items'] as List)
              .map((e) => AppActorRemoteConfigItem.fromJson(
                  e as Map<String, dynamic>))
              .toList()
          : const [],
    );
  }

  @override
  String toString() => 'AppActorRemoteConfigs(${items.length} items)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppActorRemoteConfigs &&
          runtimeType == other.runtimeType &&
          listEquals(items, other.items);

  @override
  int get hashCode => Object.hashAll(items);
}

@immutable
class AppActorRemoteConfigItem {
  final String key;
  final dynamic value;
  final AppActorConfigValueType valueType;

  const AppActorRemoteConfigItem({
    required this.key,
    required this.value,
    required this.valueType,
  });

  String? get stringValue => value is String ? value as String : null;
  bool? get boolValue => value is bool ? value as bool : null;
  num? get numberValue => value is num ? value as num : null;

  factory AppActorRemoteConfigItem.fromJson(Map<String, dynamic> json) {
    return AppActorRemoteConfigItem(
      key: json['key'] as String? ?? '',
      value: json['value'],
      valueType: AppActorConfigValueType.fromString(
          json['value_type'] as String? ?? 'string'),
    );
  }

  @override
  String toString() =>
      'AppActorRemoteConfigItem(key: $key, value: $value, '
      'valueType: $valueType)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppActorRemoteConfigItem &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          jsonValueEquals(value, other.value) &&
          valueType == other.valueType;

  @override
  int get hashCode => Object.hash(key, jsonValueHash(value), valueType);
}
