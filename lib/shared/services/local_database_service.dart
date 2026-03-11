import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';
import '../models/crop_record.dart';

class LocalDatabaseService {
  static const _cropsKey = 'cultiva_crops';
  static const _settingsKey = 'cultiva_settings';

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
    final decoded = jsonDecode(raw) as List<dynamic>;
    final crops = decoded
        .map((item) => CropRecord.fromMap(item as Map<String, dynamic>))
        .toList();
    crops.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return crops;
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
    final values = jsonDecode(raw) as Map<String, dynamic>;
    return AppSettings.fromMap(values);
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _prefs.setString(_settingsKey, jsonEncode(settings.toMap()));
  }
}
