import 'package:flutter/foundation.dart';

@immutable
class AppActorAttributeValue {
  final Object? value;

  const AppActorAttributeValue.string(String this.value);

  const AppActorAttributeValue.number(num this.value);

  const AppActorAttributeValue.boolean(bool this.value);

  const AppActorAttributeValue.stringList(List<String> this.value);

  const AppActorAttributeValue.numberList(List<num> this.value);

  AppActorAttributeValue.dateTime(DateTime value)
    : value = value.toUtc().toIso8601String();

  Object toJson() => _normalizeAttributeValue(value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppActorAttributeValue &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'AppActorAttributeValue($value)';
}

enum AppActorIntegrationIdentifier {
  appsFlyerId,
  adjustId,
  branchId,
  firebaseAppInstanceId,
  amplitudeUserId,
  amplitudeDeviceId,
  mixpanelDistinctId,
  facebookAnonymousId,
  oneSignalPlayerId;

  String get wireValue => switch (this) {
    appsFlyerId => 'appsflyer_id',
    adjustId => 'adjust_adid',
    branchId => 'branch_id',
    firebaseAppInstanceId => 'firebase_app_instance_id',
    amplitudeUserId => 'amplitude_user_id',
    amplitudeDeviceId => 'amplitude_device_id',
    mixpanelDistinctId => 'mixpanel_distinct_id',
    facebookAnonymousId => 'fb_anon_id',
    oneSignalPlayerId => 'onesignal_id',
  };

  static AppActorIntegrationIdentifier? fromString(String? value) {
    if (value == null) return null;
    for (final e in values) {
      if (e.wireValue == value || e.name == value) return e;
    }
    return null;
  }
}

enum AppActorAttributionProvider {
  appleSearchAds,
  googleAds,
  meta,
  tiktok,
  snap,
  appsFlyer,
  adjust,
  branch,
  firebase,
  custom;

  String get wireValue => switch (this) {
    appleSearchAds => 'apple_search_ads',
    googleAds => 'google_ads',
    appsFlyer => 'appsflyer',
    _ => name,
  };

  static AppActorAttributionProvider? fromString(String? value) {
    if (value == null) return null;
    for (final e in values) {
      if (e.wireValue == value || e.name == value) return e;
    }
    return null;
  }
}

enum AppActorAttributionStatus {
  nonOrganic,
  organic,
  unattributed,
  unresolved,
  error,
  unknown;

  String get wireValue => switch (this) {
    nonOrganic => 'non_organic',
    _ => name,
  };

  static AppActorAttributionStatus? fromString(String? value) {
    if (value == null) return null;
    for (final e in values) {
      if (e.wireValue == value || e.name == value) return e;
    }
    return null;
  }
}

@immutable
class AppActorAttribution {
  final AppActorAttributionProvider provider;
  final AppActorAttributionStatus? status;
  final String? providerName;
  final String? campaignId;
  final String? campaignName;
  final String? adGroupId;
  final String? adGroupName;
  final String? adId;
  final String? adName;
  final String? creativeId;
  final String? creativeName;
  final String? keywordId;
  final String? keyword;
  final DateTime? attributedAt;
  final Map<String, Object> metadata;

  const AppActorAttribution({
    required this.provider,
    this.status,
    this.providerName,
    this.campaignId,
    this.campaignName,
    this.adGroupId,
    this.adGroupName,
    this.adId,
    this.adName,
    this.creativeId,
    this.creativeName,
    this.keywordId,
    this.keyword,
    this.attributedAt,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'provider': provider.wireValue,
      if (status != null) 'status': status!.wireValue,
      if (providerName != null) 'provider_name': providerName,
      if (campaignId != null) 'campaign_id': campaignId,
      if (campaignName != null) 'campaign_name': campaignName,
      if (adGroupId != null) 'ad_group_id': adGroupId,
      if (adGroupName != null) 'ad_group_name': adGroupName,
      if (adId != null) 'ad_id': adId,
      if (adName != null) 'ad_name': adName,
      if (creativeId != null) 'creative_id': creativeId,
      if (creativeName != null) 'creative_name': creativeName,
      if (keywordId != null) 'keyword_id': keywordId,
      if (keyword != null) 'keyword': keyword,
      if (attributedAt != null)
        'attributed_at': attributedAt!.toUtc().toIso8601String(),
      if (metadata.isNotEmpty)
        'metadata': metadata.map(
          (key, value) => MapEntry(
            key,
            _normalizeAttributeValue(value, name: 'metadata[$key]'),
          ),
        ),
    };
  }
}

Object _normalizeAttributeValue(Object? value, {String name = 'value'}) {
  if (value is AppActorAttributeValue) return value.toJson();
  if (value == null) {
    throw ArgumentError.value(value, name, 'Attribute values cannot be null.');
  }
  if (value is String || value is bool) return value;
  if (value is num) {
    if (!value.isFinite) {
      throw ArgumentError.value(
        value,
        name,
        'Attribute numbers must be finite.',
      );
    }
    return value;
  }
  if (value is DateTime) return value.toUtc().toIso8601String();
  if (value is Iterable) {
    final list = value.toList(growable: false);
    if (list.length > 20) {
      throw ArgumentError.value(
        value,
        name,
        'Attribute arrays can contain at most 20 items.',
      );
    }
    if (list.every((item) => item is String)) return list.cast<String>();
    if (list.every((item) => item is num && item.isFinite)) {
      return list.cast<num>();
    }
    throw ArgumentError.value(
      value,
      name,
      'Attribute arrays must contain only strings or finite numbers.',
    );
  }

  throw ArgumentError.value(
    value,
    name,
    'Expected a String, num, bool, DateTime, or AppActorAttributeValue.',
  );
}
