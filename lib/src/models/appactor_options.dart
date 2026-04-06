import 'package:flutter/foundation.dart';

enum AppActorLogLevel {
  debug,
  verbose,
  info,
  warn,
  error;

  String get wireValue => name;

  static AppActorLogLevel fromString(String value) {
    return AppActorLogLevel.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AppActorLogLevel.info,
    );
  }
}

@immutable
class AppActorOptions {
  final AppActorLogLevel? logLevel;

  const AppActorOptions({
    this.logLevel,
  });

  Map<String, dynamic> toJson() {
    return {
      if (logLevel != null) 'log_level': logLevel!.wireValue,
    };
  }

  @override
  String toString() => 'AppActorOptions(logLevel: $logLevel)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppActorOptions &&
          runtimeType == other.runtimeType &&
          logLevel == other.logLevel;

  @override
  int get hashCode => logLevel.hashCode;
}

/// Configuration for Apple Search Ads attribution tracking.
@immutable
class AppActorAsaOptions {
  /// Automatically track purchases for ASA attribution linking.
  final bool autoTrackPurchases;

  /// Track purchase events in sandbox environments.
  final bool trackInSandbox;

  /// Enable verbose ASA-specific debug logging.
  final bool debugMode;

  const AppActorAsaOptions({
    this.autoTrackPurchases = true,
    this.trackInSandbox = false,
    this.debugMode = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'auto_track_purchases': autoTrackPurchases,
      'track_in_sandbox': trackInSandbox,
      'debug_mode': debugMode,
    };
  }

  @override
  String toString() => 'AppActorAsaOptions('
      'autoTrackPurchases: $autoTrackPurchases, '
      'trackInSandbox: $trackInSandbox, '
      'debugMode: $debugMode)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppActorAsaOptions &&
          runtimeType == other.runtimeType &&
          autoTrackPurchases == other.autoTrackPurchases &&
          trackInSandbox == other.trackInSandbox &&
          debugMode == other.debugMode;

  @override
  int get hashCode =>
      Object.hash(autoTrackPurchases, trackInSandbox, debugMode);
}
