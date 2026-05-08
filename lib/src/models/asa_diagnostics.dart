import 'package:flutter/foundation.dart';

@immutable
class AppActorAsaDiagnostics {
  final bool attributionCompleted;
  final int pendingPurchaseEventCount;
  final bool debugMode;
  final bool autoTrackPurchases;
  final bool trackInSandbox;

  const AppActorAsaDiagnostics({
    required this.attributionCompleted,
    required this.pendingPurchaseEventCount,
    required this.debugMode,
    required this.autoTrackPurchases,
    required this.trackInSandbox,
  });

  factory AppActorAsaDiagnostics.fromJson(Map<String, dynamic> json) {
    return AppActorAsaDiagnostics(
      attributionCompleted: json['attribution_completed'] as bool? ?? false,
      pendingPurchaseEventCount:
          (json['pending_purchase_event_count'] as num?)?.toInt() ?? 0,
      debugMode: json['debug_mode'] as bool? ?? false,
      autoTrackPurchases: json['auto_track_purchases'] as bool? ?? false,
      trackInSandbox: json['track_in_sandbox'] as bool? ?? false,
    );
  }

  @override
  String toString() =>
      'AppActorAsaDiagnostics(attributionCompleted: $attributionCompleted, '
      'pendingPurchaseEventCount: $pendingPurchaseEventCount)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppActorAsaDiagnostics &&
          runtimeType == other.runtimeType &&
          attributionCompleted == other.attributionCompleted &&
          pendingPurchaseEventCount == other.pendingPurchaseEventCount &&
          debugMode == other.debugMode &&
          autoTrackPurchases == other.autoTrackPurchases &&
          trackInSandbox == other.trackInSandbox;

  @override
  int get hashCode => Object.hash(
    attributionCompleted,
    pendingPurchaseEventCount,
    debugMode,
    autoTrackPurchases,
    trackInSandbox,
  );
}
