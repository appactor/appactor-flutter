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
        json['value_type'] as String? ?? 'string',
      ),
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
  int get hashCode => Object.hash(
    experimentId,
    experimentKey,
    variantId,
    variantKey,
    jsonValueHash(payload),
    valueType,
    assignedAt,
  );
}

/// A user's standing in one experiment — always returned, also when the user
/// is not in it, so callers never null-check. Use `AppActor.instance.getExperiment`
/// to get one (examples there).
@immutable
class AppActorExperiment {
  /// The developer-defined experiment key this was resolved for.
  final String experimentKey;

  /// The raw assignment; `null` when the user is not in the experiment (not
  /// targeted, not running, …).
  final AppActorExperimentAssignment? assignment;

  const AppActorExperiment({required this.experimentKey, this.assignment});

  /// `true` when the user has a variant in this experiment.
  bool get isEnrolled => assignment != null;

  /// The assigned variant's key (e.g. `'control'`), or `null` when not enrolled.
  String? get variantKey => assignment?.variantKey;

  /// The variant's payload, or `null` when not enrolled.
  dynamic get payload => assignment?.payload;

  /// `true` when the user is enrolled in the variant with this key.
  bool isVariant(String variantKey) => assignment?.variantKey == variantKey;

  /// The payload as a `bool`, or [defaultValue] when not enrolled or not a boolean.
  bool boolValue({required bool defaultValue}) {
    final value = payload;
    return value is bool ? value : defaultValue;
  }

  /// The payload as a `String`, or [defaultValue] when not enrolled or not a string.
  String stringValue({required String defaultValue}) {
    final value = payload;
    return value is String ? value : defaultValue;
  }

  /// The payload as an `int`, or [defaultValue] when not enrolled or not a whole number.
  int intValue({required int defaultValue}) {
    final value = payload;
    return value is num && value.isFinite && value == value.roundToDouble()
        ? value.toInt()
        : defaultValue;
  }

  /// The payload as a `double`, or [defaultValue] when not enrolled or not a number.
  double doubleValue({required double defaultValue}) {
    final value = payload;
    return value is num ? value.toDouble() : defaultValue;
  }

  /// A key of a JSON payload: `experiment['title'] as String? ?? 'Welcome'`.
  dynamic operator [](String key) {
    final value = payload;
    return value is Map ? value[key] : null;
  }

  @override
  String toString() =>
      'AppActorExperiment(experimentKey: $experimentKey, '
      'isEnrolled: $isEnrolled, variantKey: $variantKey)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppActorExperiment &&
          runtimeType == other.runtimeType &&
          experimentKey == other.experimentKey &&
          assignment == other.assignment;

  @override
  int get hashCode => Object.hash(experimentKey, assignment);
}
