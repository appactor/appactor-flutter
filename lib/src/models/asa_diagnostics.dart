import 'package:flutter/foundation.dart';

@immutable
class AppActorAsaDiagnostics {
  final bool attributionCompleted;
  final int pendingPurchaseEventCount;
  final bool hasPendingUserIdChange;
  final AppActorAsaPendingUserIdChange? pendingUserIdChange;
  final bool debugMode;
  final bool autoTrackPurchases;
  final bool trackInSandbox;

  const AppActorAsaDiagnostics({
    required this.attributionCompleted,
    required this.pendingPurchaseEventCount,
    required this.hasPendingUserIdChange,
    this.pendingUserIdChange,
    required this.debugMode,
    required this.autoTrackPurchases,
    required this.trackInSandbox,
  });

  factory AppActorAsaDiagnostics.fromJson(Map<String, dynamic> json) {
    return AppActorAsaDiagnostics(
      attributionCompleted: json['attribution_completed'] as bool? ?? false,
      pendingPurchaseEventCount: (json['pending_purchase_event_count'] as num?)?.toInt() ?? 0,
      hasPendingUserIdChange: json['has_pending_user_id_change'] as bool? ?? false,
      pendingUserIdChange: json['pending_user_id_change'] != null
          ? AppActorAsaPendingUserIdChange.fromJson(
              json['pending_user_id_change'] as Map<String, dynamic>)
          : null,
      debugMode: json['debug_mode'] as bool? ?? false,
      autoTrackPurchases: json['auto_track_purchases'] as bool? ?? false,
      trackInSandbox: json['track_in_sandbox'] as bool? ?? false,
    );
  }

  @override
  String toString() => 'AppActorAsaDiagnostics(attributionCompleted: $attributionCompleted, '
      'pendingPurchaseEventCount: $pendingPurchaseEventCount)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppActorAsaDiagnostics &&
          runtimeType == other.runtimeType &&
          attributionCompleted == other.attributionCompleted &&
          pendingPurchaseEventCount == other.pendingPurchaseEventCount &&
          hasPendingUserIdChange == other.hasPendingUserIdChange &&
          pendingUserIdChange == other.pendingUserIdChange &&
          debugMode == other.debugMode &&
          autoTrackPurchases == other.autoTrackPurchases &&
          trackInSandbox == other.trackInSandbox;

  @override
  int get hashCode => Object.hash(attributionCompleted, pendingPurchaseEventCount,
      hasPendingUserIdChange, pendingUserIdChange, debugMode, autoTrackPurchases, trackInSandbox);
}

@immutable
class AppActorAsaPendingUserIdChange {
  final String oldUserId;
  final String newUserId;

  const AppActorAsaPendingUserIdChange({
    required this.oldUserId,
    required this.newUserId,
  });

  factory AppActorAsaPendingUserIdChange.fromJson(Map<String, dynamic> json) {
    return AppActorAsaPendingUserIdChange(
      oldUserId: json['old_user_id'] as String? ?? '',
      newUserId: json['new_user_id'] as String? ?? '',
    );
  }

  @override
  String toString() =>
      'AppActorAsaPendingUserIdChange(oldUserId: $oldUserId, newUserId: $newUserId)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppActorAsaPendingUserIdChange &&
          runtimeType == other.runtimeType &&
          oldUserId == other.oldUserId &&
          newUserId == other.newUserId;

  @override
  int get hashCode => Object.hash(oldUserId, newUserId);
}
