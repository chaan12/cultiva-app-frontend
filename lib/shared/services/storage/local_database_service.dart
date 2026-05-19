import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/app_settings.dart';
import '../../models/crop_record.dart';
import '../../models/weather_snapshot.dart';
import '../../security/safe_json.dart';

class LocalDatabaseService {
  static const _cropsKey = 'cultiva_crops';
  static const _settingsKey = 'cultiva_settings';
  static const _weatherKey = 'cultiva_weather';
  static const _maxCropsJsonBytes = 512000;
  static const _maxSettingsJsonBytes = 32000;
  static const _maxWeatherJsonBytes = 768000;
  static const _maxStoredCrops = 500;

  SharedPreferencesAsync? _preferences;
  FlutterSecureStorage? _secureStorage;

  Future<void> init() async {
    if (_preferences != null) {
      return;
    }
    _preferences = SharedPreferencesAsync();
    _secureStorage = const FlutterSecureStorage();
  }

  SharedPreferencesAsync get _prefs {
    final preferences = _preferences;
    if (preferences == null) {
      throw StateError('Almacenamiento no inicializado.');
    }
    return preferences;
  }

  FlutterSecureStorage get _secure {
    final storage = _secureStorage;
    if (storage == null) {
      throw StateError('Almacenamiento seguro no inicializado.');
    }
    return storage;
  }

  Future<List<CropRecord>> loadCrops() async {
    final raw = await _readString(_cropsKey);
    if (raw == null || raw.isEmpty) {
      return <CropRecord>[];
    }
    try {
      final decoded = SafeJson.list(raw, maxBytes: _maxCropsJsonBytes);
      final crops = decoded
          .take(_maxStoredCrops)
          .whereType<Map>()
          .map((item) => _tryReadCrop(item.cast<String, Object?>()))
          .nonNulls
          .toList();
      crops.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return crops;
    } catch (_) {
      await _removeString(_cropsKey);
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
    await _writeString(
      _cropsKey,
      SafeJsonEncode.list(crops.map((item) => item.toMap()).toList()),
    );
  }

  Future<void> deleteCrop(String cropId) async {
    final crops = await loadCrops();
    crops.removeWhere((item) => item.id == cropId);
    await _writeString(
      _cropsKey,
      SafeJsonEncode.list(crops.map((item) => item.toMap()).toList()),
    );
  }

  Future<AppSettings> loadSettings() async {
    final raw = await _readString(_settingsKey);
    if (raw == null || raw.isEmpty) {
      return AppSettings.defaults();
    }
    try {
      final values = SafeJson.object(raw, maxBytes: _maxSettingsJsonBytes);
      return AppSettings.fromMap(values);
    } catch (_) {
      await _removeString(_settingsKey);
      return AppSettings.defaults();
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _writeString(_settingsKey, SafeJsonEncode.object(settings.toMap()));
  }

  Future<WeatherSnapshot?> loadWeather() async {
    final raw = await _readString(_weatherKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final decoded = SafeJson.object(raw, maxBytes: _maxWeatherJsonBytes);
      return WeatherSnapshot.fromMap(decoded, isFromCache: true);
    } catch (_) {
      await _removeString(_weatherKey);
      return null;
    }
  }

  Future<void> saveWeather(WeatherSnapshot weather) async {
    await _writeString(_weatherKey, SafeJsonEncode.object(weather.toMap()));
  }

  CropRecord? _tryReadCrop(Map<String, Object?> map) {
    try {
      return CropRecord.fromMap(map);
    } catch (_) {
      return null;
    }
  }

  Future<String?> _readString(String key) async {
    try {
      final secureValue = await _secure.read(key: key);
      if (secureValue != null) {
        return secureValue;
      }
      final legacyValue = await _prefs.getString(key);
      if (legacyValue != null) {
        await _writeString(key, legacyValue);
        await _prefs.remove(key);
      }
      return legacyValue;
    } catch (_) {
      return _prefs.getString(key);
    }
  }

  Future<void> _writeString(String key, String value) async {
    try {
      await _secure.write(key: key, value: value);
      await _prefs.remove(key);
    } catch (_) {
      await _prefs.setString(key, value);
    }
  }

  Future<void> _removeString(String key) async {
    try {
      await _secure.delete(key: key);
    } catch (_) {
      await _prefs.remove(key);
      return;
    }
    await _prefs.remove(key);
  }
}
