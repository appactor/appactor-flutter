import 'dart:convert';

import '../appactor.dart';
import '../appactor_platform.dart';
import '../internal/attribution_helper_state.dart';
import '../internal/method_names.dart';
import '../models/attributes.dart';

extension AppActorAttributes on AppActor {
  Future<void> setAttributes(Map<String, Object> attributes) async {
    await AppActorPlatform.execute(MethodNames.setAttributes, {
      'attributes': _normalizeAttributes(attributes),
    });
  }

  Future<void> setAttribute(String key, Object value) async {
    _validateCustomKey(key);
    await AppActorPlatform.execute(MethodNames.setAttribute, {
      'key': key,
      'value': _normalizeAttributeValue(value),
    });
  }

  Future<void> unsetAttribute(String key) async {
    _validateCustomKey(key);
    await AppActorPlatform.execute(MethodNames.unsetAttribute, {'key': key});
  }

  Future<void> setEmail(String? email) async {
    if (email != null) _validateEmail(email);
    await AppActorPlatform.execute(MethodNames.setEmail, {'email': email});
  }

  Future<void> setDisplayName(String? displayName) async {
    await AppActorPlatform.execute(MethodNames.setDisplayName, {
      'display_name': displayName,
    });
  }

  Future<void> setPhoneNumber(String? phoneNumber) async {
    if (phoneNumber != null) _validatePhoneNumber(phoneNumber);
    await AppActorPlatform.execute(MethodNames.setPhoneNumber, {
      'phone_number': phoneNumber,
    });
  }

  Future<void> setPushToken(String? pushToken) async {
    await AppActorPlatform.execute(MethodNames.setPushToken, {
      'push_token': pushToken,
    });
  }

  Future<void> collectDeviceIdentifiers() async {
    await AppActorPlatform.execute(MethodNames.collectDeviceIdentifiers);
  }

  Future<void> setIntegrationIdentifier(
    AppActorIntegrationIdentifier type,
    String value,
  ) async {
    await setCustomIntegrationIdentifier(type.wireValue, value);
  }

  Future<void> setCustomIntegrationIdentifier(String type, String value) async {
    _validateIntegrationIdentifierType(type);
    _validateIntegrationIdentifierValue(value);
    await AppActorPlatform.execute(MethodNames.setIntegrationIdentifier, {
      'type': type,
      'value': value,
    });
  }

  Future<void> setAppsflyerID(String appsflyerID) => setIntegrationIdentifier(
    AppActorIntegrationIdentifier.appsFlyerId,
    appsflyerID,
  );

  Future<void> setAppsFlyerID(String appsFlyerID) =>
      setAppsflyerID(appsFlyerID);

  Future<void> setAdjustID(String adjustID) => setIntegrationIdentifier(
    AppActorIntegrationIdentifier.adjustId,
    adjustID,
  );

  Future<void> setBranchID(String branchID) => setIntegrationIdentifier(
    AppActorIntegrationIdentifier.branchId,
    branchID,
  );

  Future<void> setFirebaseAppInstanceID(String firebaseAppInstanceID) =>
      setIntegrationIdentifier(
        AppActorIntegrationIdentifier.firebaseAppInstanceId,
        firebaseAppInstanceID,
      );

  Future<void> setOneSignalID(String oneSignalID) => setIntegrationIdentifier(
    AppActorIntegrationIdentifier.oneSignalPlayerId,
    oneSignalID,
  );

  Future<void> updateAttribution(AppActorAttribution attribution) async {
    final payload = attribution.toJson();
    rememberCustomAttributionSnapshot(attribution);
    await AppActorPlatform.execute(MethodNames.updateAttribution, payload);
  }

  Future<void> setMediaSource(String mediaSource) async {
    await AppActorPlatform.execute(MethodNames.setMediaSource, {
      'value': mediaSource,
    });
  }

  Future<void> setCampaign(String campaign) async {
    await AppActorPlatform.execute(MethodNames.setCampaign, {
      'value': campaign,
    });
  }

  Future<void> setAdGroup(String adGroup) async {
    await AppActorPlatform.execute(MethodNames.setAdGroup, {'value': adGroup});
  }

  Future<void> setAd(String ad) async {
    await AppActorPlatform.execute(MethodNames.setAd, {'value': ad});
  }

  Future<void> setKeyword(String keyword) async {
    await AppActorPlatform.execute(MethodNames.setKeyword, {'value': keyword});
  }

  Future<void> setCreative(String creative) async {
    await AppActorPlatform.execute(MethodNames.setCreative, {
      'value': creative,
    });
  }
}

void _validateCustomKey(String key) {
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
}

void _validateEmail(String email) {
  if (email.trim() != email || email.isEmpty) {
    throw ArgumentError.value(
      email,
      'email',
      'Email must not be empty or padded with whitespace.',
    );
  }
  if (utf8.encode(email).length > 320 ||
      !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
    throw ArgumentError.value(email, 'email', 'Email must be valid.');
  }
}

void _validatePhoneNumber(String phoneNumber) {
  if (phoneNumber.trim() != phoneNumber || phoneNumber.isEmpty) {
    throw ArgumentError.value(
      phoneNumber,
      'phoneNumber',
      'Phone number must not be empty or padded with whitespace.',
    );
  }
  final digitCount = RegExp(r'\d').allMatches(phoneNumber).length;
  if (utf8.encode(phoneNumber).length > 64 ||
      digitCount < 3 ||
      !RegExp(r'^[+0-9().\-\s]+$').hasMatch(phoneNumber)) {
    throw ArgumentError.value(
      phoneNumber,
      'phoneNumber',
      'Phone number must be valid.',
    );
  }
}

void _validateIntegrationIdentifierValue(String value) {
  if (value.trim() != value || value.isEmpty) {
    throw ArgumentError.value(
      value,
      'value',
      'Integration identifier value must not be empty or padded with whitespace.',
    );
  }
  if (utf8.encode(value).length > 1024) {
    throw ArgumentError.value(
      value,
      'value',
      'Integration identifier value must be at most 1024 bytes.',
    );
  }
}

void _validateIntegrationIdentifierType(String value) {
  if (value.trim() != value || value.isEmpty) {
    throw ArgumentError.value(
      value,
      'type',
      'Integration identifier type must not be empty or padded with whitespace.',
    );
  }
  if (value.length > 64) {
    throw ArgumentError.value(
      value,
      'type',
      'Integration identifier type can contain at most 64 characters.',
    );
  }
  if (!RegExp(r'^[A-Za-z0-9_.:-]+$').hasMatch(value)) {
    throw ArgumentError.value(
      value,
      'type',
      'Integration identifier type may only contain letters, numbers, underscore, dot, colon, or dash.',
    );
  }
  if (value.startsWith(r'$')) {
    throw ArgumentError.value(
      value,
      'type',
      'Integration identifier type cannot start with "\$".',
    );
  }
  if (value.toLowerCase().startsWith('appactor.')) {
    throw ArgumentError.value(
      value,
      'type',
      'Integration identifier type cannot start with "appactor.".',
    );
  }
}

Object _normalizeAttributeValue(Object? value, {String name = 'value'}) {
  if (value is AppActorAttributeValue) return value.toJson();
  if (value == null) {
    throw ArgumentError.value(
      value,
      name,
      'Attribute values cannot be null. Use unsetAttribute(key) to remove an attribute.',
    );
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
    'Expected a String, num, bool, DateTime, string/number/bool array, or AppActorAttributeValue.',
  );
}

Map<String, Object> _normalizeAttributes(Map<String, Object> attributes) {
  return attributes.map((key, value) {
    _validateCustomKey(key);
    return MapEntry(
      key,
      _normalizeAttributeValue(value, name: 'attributes[$key]'),
    );
  });
}
