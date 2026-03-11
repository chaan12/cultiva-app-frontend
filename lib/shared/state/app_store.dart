import 'package:flutter/material.dart';

import '../../features/crops_catalog/models/crop_catalog_item.dart';
import '../../features/crops_catalog/services/crop_catalog_service.dart';
import '../../features/crop_tracking/services/crop_tracking_service.dart';
import '../models/app_location.dart';
import '../models/app_settings.dart';
import '../models/crop_record.dart';
import '../models/weather_snapshot.dart';
import '../services/local_database_service.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';

class AppStore extends ChangeNotifier {
  AppStore({
    LocalDatabaseService? databaseService,
    LocationService? locationService,
    WeatherService? weatherService,
  }) : _databaseService = databaseService ?? LocalDatabaseService(),
       _locationService = locationService ?? LocationService(),
       _weatherService = weatherService ?? WeatherService();

  final LocalDatabaseService _databaseService;
  final LocationService _locationService;
  final WeatherService _weatherService;

  AppSettings _settings = AppSettings.defaults();
  List<CropRecord> _crops = <CropRecord>[];
  WeatherSnapshot? _weather;
  bool _initialized = false;
  bool _isBusy = false;
  Future<void>? _initializationFuture;

  AppSettings get settings => _settings;
  List<CropRecord> get crops => List<CropRecord>.unmodifiable(_crops);
  WeatherSnapshot? get weather => _weather;
  bool get initialized => _initialized;
  bool get isBusy => _isBusy;

  int get activeCropsCount => _crops.length;

  double get totalHectares =>
      _crops.fold<double>(0, (sum, crop) => sum + crop.areaHa);

  int get upcomingEventsCount => _crops
      .where(
        (crop) => CropTrackingService.buildSummary(crop).status != 'normal',
      )
      .length;

  CropRecord? get nextHarvestCrop {
    if (_crops.isEmpty) {
      return null;
    }
    final sorted = [..._crops]
      ..sort((a, b) => a.daysToHarvest.compareTo(b.daysToHarvest));
    return sorted.first;
  }

  String get currentSeason {
    final month = DateTime.now().month;
    if (month >= 3 && month <= 8) {
      return 'Primavera - Verano';
    }
    return 'Otoño - Invierno';
  }

  CropCatalogItem get recommendedCropItem {
    return recommendedCropItems.first;
  }

  List<CropCatalogItem> get recommendedCropItems {
    final month = DateTime.now().month;
    final currentSeasonParts = currentSeason
        .split(' - ')
        .map((part) => part.trim().toLowerCase())
        .toList();
    final ranked = [...CropCatalogService.items]
      ..sort((a, b) {
        final scoreA = _recommendationScore(
          item: a,
          month: month,
          currentSeasonParts: currentSeasonParts,
        );
        final scoreB = _recommendationScore(
          item: b,
          month: month,
          currentSeasonParts: currentSeasonParts,
        );
        if (scoreA != scoreB) {
          return scoreB.compareTo(scoreA);
        }
        return a.cycleDays.compareTo(b.cycleDays);
      });
    return ranked;
  }

  Future<void> initialize() async {
    final existing = _initializationFuture;
    if (existing != null) {
      return existing;
    }
    final future = _initializeInternal();
    _initializationFuture = future;
    return future;
  }

  Future<void> _initializeInternal() async {
    if (_initialized) {
      return;
    }
    debugPrint('[AppStore] Inicialización iniciada');
    _setBusy(true);
    await _databaseService.init();
    debugPrint('[AppStore] Persistencia local inicializada');
    _settings = await _databaseService.loadSettings();
    _crops = await _databaseService.loadCrops();
    debugPrint(
      '[AppStore] Settings cargados: location=${_settings.locationName}, autoLocation=${_settings.autoLocation}, lat=${_settings.latitude}, lng=${_settings.longitude}',
    );
    debugPrint('[AppStore] Cultivos cargados: ${_crops.length}');
    _initialized = true;
    notifyListeners();
    try {
      if (_settings.autoLocation) {
        debugPrint('[AppStore] Intentando usar ubicación actual');
        final location = await _locationService.getCurrentLocation();
        _settings = _settings.copyWith(
          autoLocation: true,
          locationName: location.label,
          latitude: location.latitude,
          longitude: location.longitude,
        );
        await _databaseService.saveSettings(_settings);
        await _refreshWeatherInternal();
      } else if (_settings.latitude != null && _settings.longitude != null) {
        debugPrint('[AppStore] Usando coordenadas guardadas');
        await _refreshWeatherInternal();
      } else {
        debugPrint(
          '[AppStore] Sin coordenadas, geocodificando ${_settings.locationName}',
        );
        final fallback = await _locationService.geocode(_settings.locationName);
        _settings = _settings.copyWith(
          latitude: fallback.latitude,
          longitude: fallback.longitude,
        );
        await _databaseService.saveSettings(_settings);
        await _refreshWeatherInternal();
      }
    } catch (error) {
      debugPrint('[AppStore] Inicialización de ubicación/clima falló: $error');
    }
    _setBusy(false);
    debugPrint('[AppStore] Inicialización completada');
  }

  Future<void> addCrop(CropRecord crop) async {
    await initialize();
    await _databaseService.saveCrop(crop);
    _crops = await _databaseService.loadCrops();
    notifyListeners();
  }

  Future<void> updateSettings(AppSettings settings) async {
    await initialize();
    debugPrint(
      '[AppStore] Guardando settings: autoLocation=${settings.autoLocation}, location=${settings.locationName}',
    );
    _settings = settings;
    await _databaseService.saveSettings(settings);
    notifyListeners();
  }

  Future<void> refreshCurrentLocation({bool silent = false}) async {
    await initialize();
    try {
      _setBusy(true);
      debugPrint('[AppStore] refreshCurrentLocation()');
      final location = await _locationService.getCurrentLocation();
      _settings = _settings.copyWith(
        autoLocation: true,
        locationName: location.label,
        latitude: location.latitude,
        longitude: location.longitude,
      );
      await _databaseService.saveSettings(_settings);
      debugPrint(
        '[AppStore] Ubicación actual guardada: ${location.label} (${location.latitude}, ${location.longitude})',
      );
      await _refreshWeatherInternal();
    } finally {
      _setBusy(false);
      if (!silent) {
        notifyListeners();
      }
    }
  }

  Future<void> saveManualLocation(String query) async {
    await initialize();
    _setBusy(true);
    try {
      debugPrint('[AppStore] saveManualLocation($query)');
      final location = await _locationService.geocode(query);
      _settings = _settings.copyWith(
        autoLocation: false,
        locationName: query,
        latitude: location.latitude,
        longitude: location.longitude,
      );
      await _databaseService.saveSettings(_settings);
      debugPrint(
        '[AppStore] Ubicación manual guardada: ${location.label} (${location.latitude}, ${location.longitude})',
      );
      await _refreshWeatherInternal();
    } finally {
      _setBusy(false);
      notifyListeners();
    }
  }

  Future<void> savePresetLocation(AppLocation location) async {
    await initialize();
    _setBusy(true);
    try {
      debugPrint('[AppStore] savePresetLocation(${location.label})');
      _settings = _settings.copyWith(
        autoLocation: false,
        locationName: location.label,
        latitude: location.latitude,
        longitude: location.longitude,
      );
      await _databaseService.saveSettings(_settings);
      debugPrint(
        '[AppStore] Ubicación predefinida guardada: ${location.label} (${location.latitude}, ${location.longitude})',
      );
      await _refreshWeatherInternal();
    } finally {
      _setBusy(false);
      notifyListeners();
    }
  }

  Future<void> refreshWeather() async {
    await initialize();
    await _refreshWeatherInternal();
  }

  Future<void> _refreshWeatherInternal() async {
    final latitude = _settings.latitude;
    final longitude = _settings.longitude;
    if (latitude == null || longitude == null) {
      debugPrint('[AppStore] No hay coordenadas para consultar clima');
      return;
    }
    debugPrint(
      '[AppStore] Consultando clima para ${_settings.locationName} ($latitude, $longitude)',
    );
    _weather = await _weatherService.fetchWeather(
      latitude: latitude,
      longitude: longitude,
      locationLabel: _settings.locationName,
    );
    debugPrint(
      '[AppStore] Clima actualizado: ${_weather?.temperatureC}°C ${_weather?.description}',
    );
    notifyListeners();
  }

  void _setBusy(bool value) {
    _isBusy = value;
    if (hasListeners) {
      notifyListeners();
    }
  }

  int _recommendationScore({
    required CropCatalogItem item,
    required int month,
    required List<String> currentSeasonParts,
  }) {
    final season = item.season.toLowerCase();
    final sowingWindow = item.sowingWindow.toLowerCase();
    var score = 0;

    if (season.contains('todo el año') ||
        sowingWindow.contains('todo el año')) {
      score += 40;
    }
    if (_windowContainsMonth(sowingWindow, month)) {
      score += 70;
    }
    if (currentSeasonParts.every(season.contains)) {
      score += 50;
    } else {
      for (final part in currentSeasonParts) {
        if (season.contains(part)) {
          score += 20;
        }
      }
    }
    score += (160 - item.cycleDays).clamp(0, 60);
    return score;
  }

  bool _windowContainsMonth(String window, int month) {
    final monthNames = <String, int>{
      'enero': 1,
      'febrero': 2,
      'marzo': 3,
      'abril': 4,
      'mayo': 5,
      'junio': 6,
      'julio': 7,
      'agosto': 8,
      'septiembre': 9,
      'setiembre': 9,
      'octubre': 10,
      'noviembre': 11,
      'diciembre': 12,
    };
    for (final entry in monthNames.entries) {
      if (window.contains(entry.key) && entry.value == month) {
        return true;
      }
    }
    return false;
  }
}
