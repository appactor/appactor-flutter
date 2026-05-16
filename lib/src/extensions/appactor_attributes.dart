import '../appactor.dart';
import '../appactor_platform.dart';
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
    await AppActorPlatform.execute(MethodNames.setEmail, {'email': email});
  }

  Future<void> setDisplayName(String? displayName) async {
    await AppActorPlatform.execute(MethodNames.setDisplayName, {
      'display_name': displayName,
    });
  }

  Future<void> setPhoneNumber(String? phoneNumber) async {
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
    await AppActorPlatform.execute(MethodNames.setIntegrationIdentifier, {
      'type': type.wireValue,
      'value': value,
    });
  }

  Future<void> updateAttribution(AppActorAttribution attribution) async {
    await AppActorPlatform.execute(
      MethodNames.updateAttribution,
      attribution.toJson(),
    );
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
    'Expected a String, num, bool, DateTime, string/number array, or AppActorAttributeValue.',
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
