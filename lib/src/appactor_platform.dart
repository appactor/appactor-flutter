import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'models/appactor_error.dart';

class AppActorPlatform {
  static const _channel = MethodChannel('appactor_flutter');

  static final _customerInfoController =
      StreamController<Map<String, dynamic>>.broadcast();
  static final _receiptEventController =
      StreamController<Map<String, dynamic>>.broadcast();
  // Sync, so delivery stops the moment a listener cancels (`.first`): whatever
  // it hasn't been handed stays in `_pendingPurchaseIntents` for the next one.
  static final _purchaseIntentController =
      StreamController<Map<String, dynamic>>.broadcast(
    sync: true,
    onListen: () => scheduleMicrotask(_deliverPendingPurchaseIntents),
  );
  static final _deferredPurchaseController =
      StreamController<Map<String, dynamic>>.broadcast();

  static Stream<Map<String, dynamic>> get customerInfoEvents =>
      _customerInfoController.stream;
  static Stream<Map<String, dynamic>> get receiptPipelineEvents =>
      _receiptEventController.stream;
  static Stream<Map<String, dynamic>> get purchaseIntentEvents =>
      _purchaseIntentController.stream;
  static Stream<Map<String, dynamic>> get deferredPurchaseEvents =>
      _deferredPurchaseController.stream;

  // The App Store hands an intent over once, and a broadcast stream drops events
  // no one listens to: an app that subscribes only on its paywall would lose the
  // intent a promoted purchase launched it with. They wait for a listener, under
  // the native store's limits: 10 of them, each good for 5 minutes.
  static final _pendingPurchaseIntents =
      <({DateTime receivedAt, Map<String, dynamic> json})>[];
  static const _maxPendingPurchaseIntents = 10;
  static const _purchaseIntentTtl = Duration(minutes: 5);

  @visibleForTesting
  static DateTime Function() now = DateTime.now;

  static bool _initialized = false;

  static void ensureInitialized() {
    if (_initialized) return;
    _initialized = true;
    _channel.setMethodCallHandler(_handleNativeEvent);
  }

  static void resetState() {
    _initialized = false;
    _pendingPurchaseIntents.clear();
  }

  static void _holdPurchaseIntent(Map<String, dynamic> json) {
    if (_pendingPurchaseIntents.length == _maxPendingPurchaseIntents) {
      _pendingPurchaseIntents.removeAt(0);
    }
    _pendingPurchaseIntents.add((receivedAt: now(), json: json));
    _deliverPendingPurchaseIntents();
  }

  static void _deliverPendingPurchaseIntents() {
    while (_pendingPurchaseIntents.isNotEmpty &&
        _purchaseIntentController.hasListener) {
      final intent = _pendingPurchaseIntents.removeAt(0);
      if (now().difference(intent.receivedAt) < _purchaseIntentTtl) {
        _purchaseIntentController.add(intent.json);
      }
    }
  }

  static Future<dynamic> _handleNativeEvent(MethodCall call) async {
    if (call.method != 'event') return;
    try {
      final args = Map<String, dynamic>.from(call.arguments as Map);
      final name = args['name'] as String;
      if (name == 'sdk_log') {
        if (kDebugMode) {
          final data = jsonDecode(args['json'] as String) as Map<String, dynamic>;
          final level = (data['level'] as String? ?? 'info').toUpperCase();
          final category = data['category'] as String? ?? '';
          final message = data['message'] as String? ?? '';
          debugPrint('[AppActor/$level] $category: $message');
        }
        return;
      }
      final data = jsonDecode(args['json'] as String) as Map<String, dynamic>;
      switch (name) {
        case 'customer_info_updated':
          _customerInfoController.add(data);
        case 'receipt_pipeline_event':
          _receiptEventController.add(data);
        case 'purchase_intent_received':
          _holdPurchaseIntent(data);
        case 'deferred_purchase_resolved':
          _deferredPurchaseController.add(data);
      }
    } catch (e, st) {
      // Drop malformed native events to avoid crashing the isolate,
      // but log in debug mode so problems are not invisible.
      debugPrint('AppActor: failed to handle native event: $e\n$st');
    }
  }

  static Future<Map<String, dynamic>> execute(
    String method, [
    Map<String, dynamic>? params,
  ]) async {
    final json = params != null ? jsonEncode(params) : '{}';
    final response = await _channel.invokeMethod<String>('execute', {
      'method': method,
      'json': json,
    });
    if (response == null) {
      throw const AppActorError(
          code: 1001, message: 'Null response from native');
    }
    final Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(response) as Map<String, dynamic>;
    } on FormatException catch (e) {
      throw AppActorError(
          code: 1002,
          message: 'Invalid JSON from native',
          detail: e.message);
    }
    if (decoded.containsKey('error')) {
      throw AppActorError.fromJson(decoded['error'] as Map<String, dynamic>);
    }
    final success = decoded['success'];
    if (success is Map) {
      return success as Map<String, dynamic>;
    }
    return {'value': success};
  }
}
