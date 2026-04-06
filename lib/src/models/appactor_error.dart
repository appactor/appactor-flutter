import 'package:flutter/foundation.dart';

@immutable
class AppActorError implements Exception {
  final int code;
  final String message;
  final String? detail;
  final String? requestId;
  final String? scope;
  final double? retryAfterSeconds;

  const AppActorError({
    required this.code,
    required this.message,
    this.detail,
    this.requestId,
    this.scope,
    this.retryAfterSeconds,
  });

  bool get isPluginError => code >= 1000 && code < 2000;
  bool get isSdkError => code >= 2000;
  bool get isTransient => detail?.contains('transient=true') == true;

  // SDK error code constants
  static const codeNotConfigured = 2001;
  static const codeAlreadyConfigured = 2002;
  static const codeValidation = 2003;
  static const codeNotAvailable = 2004;
  static const codeNetwork = 2005;
  static const codeDecoding = 2006;
  static const codeServer = 2007;
  static const codeStoreProductsMissing = 2008;
  static const codeCustomerNotFound = 2009;
  static const codePurchaseFailed = 2010;
  static const codeReceiptPostFailed = 2011;
  static const codeReceiptQueuedForRetry = 2012;
  static const codePurchaseInProgress = 2013;
  static const codeProductNotAvailable = 2014;
  static const codeSignatureVerification = 2015;
  static const codeInvalidOffer = 2016;
  static const codePurchaseIneligible = 2017;
  static const codeUnknown = 2099;

  bool get isNotConfigured => code == codeNotConfigured;
  bool get isNetwork => code == codeNetwork;
  bool get isServer => code == codeServer;
  bool get isInvalidOffer => code == codeInvalidOffer;
  bool get isPurchaseIneligible => code == codePurchaseIneligible;
  bool get isPurchaseFailed => code == codePurchaseFailed;
  bool get isSignatureVerification => code == codeSignatureVerification;

  factory AppActorError.fromJson(Map<String, dynamic> json) {
    return AppActorError(
      code: (json['code'] as num?)?.toInt() ?? 0,
      message: json['message'] as String? ?? 'Unknown error',
      detail: json['detail'] as String?,
      requestId: json['request_id'] as String?,
      scope: json['scope'] as String?,
      retryAfterSeconds: (json['retry_after_seconds'] as num?)?.toDouble(),
    );
  }

  @override
  String toString() =>
      'AppActorError($code): $message${detail != null ? ' [$detail]' : ''}'
      '${requestId != null ? ' {requestId: $requestId}' : ''}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppActorError &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          message == other.message &&
          detail == other.detail &&
          requestId == other.requestId &&
          scope == other.scope &&
          retryAfterSeconds == other.retryAfterSeconds;

  @override
  int get hashCode =>
      Object.hash(code, message, detail, requestId, scope, retryAfterSeconds);
}
