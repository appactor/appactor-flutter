import 'package:flutter/foundation.dart';

@immutable
class AppActorReceiptPipelineEvent {
  static const typePostedOk = 'posted_ok';
  static const typeRetryScheduled = 'retry_scheduled';
  static const typePermanentlyRejected = 'permanently_rejected';
  static const typeDeadLettered = 'dead_lettered';
  static const typeDuplicateSkipped = 'duplicate_skipped';

  final String type;
  final String? transactionId;
  final String productId;
  final String appUserId;
  final int? retryCount;
  final String? nextAttemptAt;
  final String? errorCode;
  final String? key;

  const AppActorReceiptPipelineEvent({
    required this.type,
    this.transactionId,
    required this.productId,
    required this.appUserId,
    this.retryCount,
    this.nextAttemptAt,
    this.errorCode,
    this.key,
  });

  bool get isPostedOk => type == typePostedOk;
  bool get isRetryScheduled => type == typeRetryScheduled;
  bool get isPermanentlyRejected => type == typePermanentlyRejected;
  bool get isDeadLettered => type == typeDeadLettered;
  bool get isDuplicateSkipped => type == typeDuplicateSkipped;

  factory AppActorReceiptPipelineEvent.fromJson(Map<String, dynamic> json) {
    return AppActorReceiptPipelineEvent(
      type: json['type'] as String? ?? '',
      transactionId: json['transaction_id'] as String?,
      productId: json['product_id'] as String? ?? '',
      appUserId: json['app_user_id'] as String? ?? '',
      retryCount: (json['retry_count'] as num?)?.toInt(),
      nextAttemptAt: json['next_attempt_at'] as String?,
      errorCode: json['error_code'] as String?,
      key: json['key'] as String?,
    );
  }

  @override
  String toString() =>
      'AppActorReceiptPipelineEvent($type, '
      'productId: $productId, appUserId: $appUserId)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppActorReceiptPipelineEvent &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          transactionId == other.transactionId &&
          productId == other.productId &&
          appUserId == other.appUserId &&
          retryCount == other.retryCount &&
          nextAttemptAt == other.nextAttemptAt &&
          errorCode == other.errorCode &&
          key == other.key;

  @override
  int get hashCode => Object.hash(type, transactionId, productId, appUserId,
      retryCount, nextAttemptAt, errorCode, key);
}
