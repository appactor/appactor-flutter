import 'package:flutter/foundation.dart';

import '../internal/deep_equals.dart';
import 'enums.dart';

@immutable
class AppActorExperimentAssignment {
  final String experimentId;
  final String experimentKey;
  final String variantId;
  final String variantKey;
  final dynamic payload;
  final AppActorConfigValueType valueType;
  final String assignedAt;

  const AppActorExperimentAssignment({
    required this.experimentId,
    required this.experimentKey,
    required this.variantId,
    required this.variantKey,
    this.payload,
    required this.valueType,
    required this.assignedAt,
  });

  factory AppActorExperimentAssignment.fromJson(Map<String, dynamic> json) {
    return AppActorExperimentAssignment(
      experimentId: json['experiment_id'] as String? ?? '',
      experimentKey: json['experiment_key'] as String? ?? '',
      variantId: json['variant_id'] as String? ?? '',
      variantKey: json['variant_key'] as String? ?? '',
      payload: json['payload'],
      valueType: AppActorConfigValueType.fromString(
          json['value_type'] as String? ?? 'string'),
      assignedAt: json['assigned_at'] as String? ?? '',
    );
  }

  @override
  String toString() =>
      'AppActorExperimentAssignment(experimentKey: $experimentKey, '
      'variantKey: $variantKey, valueType: $valueType)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppActorExperimentAssignment &&
          runtimeType == other.runtimeType &&
          experimentId == other.experimentId &&
          experimentKey == other.experimentKey &&
          variantId == other.variantId &&
          variantKey == other.variantKey &&
          jsonValueEquals(payload, other.payload) &&
          valueType == other.valueType &&
          assignedAt == other.assignedAt;

  @override
  int get hashCode => Object.hash(experimentId, experimentKey, variantId,
      variantKey, jsonValueHash(payload), valueType, assignedAt);
}
