import 'package:flutter/foundation.dart';

/// Deep equality for JSON-compatible dynamic values.
/// Handles Map, List, and primitives (String, num, bool, null).
bool jsonValueEquals(dynamic a, dynamic b) {
  if (identical(a, b)) return true;
  if (a is Map && b is Map) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || !jsonValueEquals(a[key], b[key])) return false;
    }
    return true;
  }
  if (a is List && b is List) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!jsonValueEquals(a[i], b[i])) return false;
    }
    return true;
  }
  return a == b;
}

/// Order-independent hashCode for JSON-compatible dynamic values.
int jsonValueHash(dynamic value) {
  if (value is Map) {
    var h = 0;
    for (final e in value.entries) {
      h ^= Object.hash(e.key.hashCode, jsonValueHash(e.value));
    }
    return Object.hash(value.length, h);
  }
  if (value is List) {
    return Object.hashAll(value.map(jsonValueHash));
  }
  return value.hashCode;
}

/// Deep equality for Map of Lists where V has operator ==.
bool mapOfListsEquals<K, V>(Map<K, List<V>> a, Map<K, List<V>> b) {
  if (a.length != b.length) return false;
  for (final key in a.keys) {
    if (!b.containsKey(key) || !listEquals(a[key], b[key])) return false;
  }
  return true;
}
