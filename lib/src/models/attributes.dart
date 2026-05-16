import 'dart:convert';

import 'package:flutter/foundation.dart';

@immutable
class AppActorAttributeValue {
  final Object? value;
  final String? valueType;

  const AppActorAttributeValue.string(String this.value) : valueType = null;

  const AppActorAttributeValue.number(num this.value) : valueType = null;

  const AppActorAttributeValue.boolean(bool this.value) : valueType = null;

  const AppActorAttributeValue.stringList(List<String> this.value)
    : valueType = null;

  const AppActorAttributeValue.numberList(List<num> this.value)
    : valueType = null;

  const AppActorAttributeValue.boolList(List<bool> this.value)
    : valueType = null;

  AppActorAttributeValue.dateTime(DateTime value)
    : value = value.toUtc().toIso8601String(),
      valueType = 'date';

  Object toJson() {
    if (valueType != null) {
      return {'value': value, 'valueType': valueType};
    }
    return _normalizeAttributeValue(value);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppActorAttributeValue &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          valueType == other.valueType;

  @override
  int get hashCode => Object.hash(value, valueType);

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
  final String? network;
  final String? source;
  final String? medium;
  final String? campaign;
  final String? adGroup;
  final String? ad;
  final String? creative;
  final String? clickId;
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
    this.network,
    this.source,
    this.medium,
    this.campaign,
    this.adGroup,
    this.ad,
    this.creative,
    this.clickId,
    this.attributedAt,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    _validateAttributionString('provider_name', providerName);
    _validateAttributionString('campaign_id', campaignId);
    _validateAttributionString('campaign_name', campaignName);
    _validateAttributionString('ad_group_id', adGroupId);
    _validateAttributionString('ad_group_name', adGroupName);
    _validateAttributionString('ad_id', adId);
    _validateAttributionString('ad_name', adName);
    _validateAttributionString('creative_id', creativeId);
    _validateAttributionString('creative_name', creativeName);
    _validateAttributionString('keyword_id', keywordId);
    _validateAttributionString('keyword', keyword);
    _validateAttributionString('network', network);
    _validateAttributionString('source', source);
    _validateAttributionString('medium', medium);
    _validateAttributionString('campaign', campaign);
    _validateAttributionString('ad_group', adGroup);
    _validateAttributionString('ad', ad);
    _validateAttributionString('creative', creative);
    _validateAttributionString('click_id', clickId);
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
      if (network != null) 'network': network,
      if (source != null) 'source': source,
      if (medium != null) 'medium': medium,
      if (campaign != null) 'campaign': campaign,
      if (adGroup != null) 'ad_group': adGroup,
      if (ad != null) 'ad': ad,
      if (creative != null) 'creative': creative,
      if (clickId != null) 'click_id': clickId,
      if (attributedAt != null)
        'attributed_at': attributedAt!.toUtc().toIso8601String(),
      if (metadata.isNotEmpty)
        'metadata': metadata.map(
          (key, value) => MapEntry(
            _validateMetadataKey(key),
            _normalizeAttributeValue(value, name: 'metadata[$key]'),
          ),
        ),
    };
  }
}

String _validateMetadataKey(String key) {
  if (key.isEmpty) {
    throw ArgumentError.value(key, 'key', 'Attribute key cannot be empty.');
  }
  if (key.length > 64) {
    throw ArgumentError.value(
      key,
      'key',
      'Attribute keys can contain at most 64 characters.',
    );
  }
  if (!RegExp(r'^[A-Za-z0-9_.:-]+$').hasMatch(key)) {
    throw ArgumentError.value(
      key,
      'key',
      'Attribute keys may only contain letters, numbers, underscore, dot, colon, or dash.',
    );
  }
  if (key.startsWith(r'$')) {
    throw ArgumentError.value(
      key,
      'key',
      'Custom attribute keys cannot start with "\$".',
    );
  }
  if (key.toLowerCase().startsWith('appactor.')) {
    throw ArgumentError.value(
      key,
      'key',
      'Custom attribute keys cannot start with "appactor.".',
    );
  }
  return key;
}

void _validateAttributionString(String field, String? value) {
  if (value == null) return;
  if (value.trim() != value || value.isEmpty) {
    throw ArgumentError.value(
      value,
      field,
      'Attribution field "$field" must not be empty or padded with whitespace.',
    );
  }
  if (utf8.encode(value).length > 1024) {
    throw ArgumentError.value(
      value,
      field,
      'Attribution field "$field" must be at most 1024 bytes.',
    );
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
  if (value is DateTime) {
    return {'value': value.toUtc().toIso8601String(), 'valueType': 'date'};
  }
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
    if (list.every((item) => item is bool)) return list.cast<bool>();
    throw ArgumentError.value(
      value,
      name,
      'Attribute arrays must contain only strings, finite numbers, or booleans.',
    );
  }

  throw ArgumentError.value(
    value,
    name,
    'Expected a String, num, bool, DateTime, or AppActorAttributeValue.',
  );
}
