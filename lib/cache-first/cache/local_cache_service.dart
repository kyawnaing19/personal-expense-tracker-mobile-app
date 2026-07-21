import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalCacheService {
  LocalCacheService._internal();
  static final LocalCacheService instance = LocalCacheService._internal();

  static const String _keyPrefix = 'cache_';
  static const String _timestampSuffix = '_timestamp';
  static const String _keyIndex = '_cache_key_index';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  String _fullKey(String key) => '$_keyPrefix$key';
  Future<void> save(String key, dynamic data) async {
    final prefs = await _instance;
    final fullKey = _fullKey(key);
    await prefs.setString(fullKey, jsonEncode(data));
    await prefs.setString(
      '$fullKey$_timestampSuffix',
      DateTime.now().toIso8601String(),
    );
    await _registerKey(fullKey);
  }

  Future<dynamic> read(String key) async {
    final prefs = await _instance;
    final raw = prefs.getString(_fullKey(key));
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  Future<DateTime?> lastUpdated(String key) async {
    final prefs = await _instance;
    final raw = prefs.getString('${_fullKey(key)}$_timestampSuffix');
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<bool> hasCache(String key) async {
    final prefs = await _instance;
    return prefs.containsKey(_fullKey(key));
  }

  Future<void> clearKey(String key) async {
    final prefs = await _instance;
    final fullKey = _fullKey(key);
    await prefs.remove(fullKey);
    await prefs.remove('$fullKey$_timestampSuffix');
    await _unregisterKey(fullKey);
  }

  Future<void> clearAll() async {
    final prefs = await _instance;
    final keys = prefs.getStringList(_keyIndex) ?? [];
    for (final key in keys) {
      await prefs.remove(key);
      await prefs.remove('$key$_timestampSuffix');
    }
    await prefs.remove(_keyIndex);
  }

  Future<void> _registerKey(String fullKey) async {
    final prefs = await _instance;
    final keys = prefs.getStringList(_keyIndex) ?? [];
    if (!keys.contains(fullKey)) {
      keys.add(fullKey);
      await prefs.setStringList(_keyIndex, keys);
    }
  }

  Future<void> _unregisterKey(String fullKey) async {
    final prefs = await _instance;
    final keys = prefs.getStringList(_keyIndex) ?? [];
    keys.remove(fullKey);
    await prefs.setStringList(_keyIndex, keys);
  }
}