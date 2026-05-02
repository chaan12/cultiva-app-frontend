import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';
import '../models/crop_record.dart';
import '../models/weather_snapshot.dart';

class LocalDatabaseService {
  static const _cropsKey = 'cultiva_crops';
  static const _settingsKey = 'cultiva_settings';
  static const _weatherKey = 'cultiva_weather';

  SharedPreferencesAsync? _preferences;

  Future<void> init() async {
    if (_preferences != null) {
      return;
    }
    _preferences = SharedPreferencesAsync();
  }

  SharedPreferencesAsync get _prefs {
    final preferences = _preferences;
    if (preferences == null) {
      throw StateError('Storage not initialized');
    }
    return preferences;
  }

  Future<List<CropRecord>> loadCrops() async {
    final raw = await _prefs.getString(_cropsKey);
    if (raw == null || raw.isEmpty) {
      return <CropRecord>[];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List<dynamic>) {
        await _prefs.remove(_cropsKey);
        return <CropRecord>[];
      }
      final crops = decoded
          .whereType<Map<String, dynamic>>()
          .map(CropRecord.fromMap)
          .toList();
      crops.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return crops;
    } catch (_) {
      await _prefs.remove(_cropsKey);
      return <CropRecord>[];
    }
  }

  Future<void> saveCrop(CropRecord crop) async {
    final crops = await loadCrops();
    final index = crops.indexWhere((item) => item.id == crop.id);
    if (index == -1) {
      crops.add(crop);
    } else {
      crops[index] = crop;
    }
    await _prefs.setString(
      _cropsKey,
      jsonEncode(crops.map((item) => item.toMap()).toList()),
    );
  }

  Future<void> deleteCrop(String cropId) async {
    final crops = await loadCrops();
    crops.removeWhere((item) => item.id == cropId);
    await _prefs.setString(
      _cropsKey,
      jsonEncode(crops.map((item) => item.toMap()).toList()),
    );
  }

  Future<AppSettings> loadSettings() async {
    final raw = await _prefs.getString(_settingsKey);
    if (raw == null || raw.isEmpty) {
      return AppSettings.defaults();
    }
    try {
      final values = jsonDecode(raw);
      if (values is! Map<String, dynamic>) {
        await _prefs.remove(_settingsKey);
        return AppSettings.defaults();
      }
      return AppSettings.fromMap(values);
    } catch (_) {
      await _prefs.remove(_settingsKey);
      return AppSettings.defaults();
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _prefs.setString(_settingsKey, jsonEncode(settings.toMap()));
  }

  Future<WeatherSnapshot?> loadWeather() async {
    final raw = await _prefs.getString(_weatherKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        await _prefs.remove(_weatherKey);
        return null;
      }
      return WeatherSnapshot.fromMap(decoded, isFromCache: true);
    } catch (_) {
      await _prefs.remove(_weatherKey);
      return null;
    }
  }

  Future<void> saveWeather(WeatherSnapshot weather) async {
    await _prefs.setString(_weatherKey, jsonEncode(weather.toMap()));
  }
}
