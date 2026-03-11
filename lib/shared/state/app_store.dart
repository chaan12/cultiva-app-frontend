import 'package:flutter/material.dart';

import '../../features/crops_catalog/models/crop_catalog_item.dart';
import '../../features/crops_catalog/services/crop_catalog_service.dart';
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

  int get upcomingEventsCount =>
      _crops.where((crop) => crop.status != 'normal').length;

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
    for (final item in CropCatalogService.items) {
      if (item.season.contains('Todo el año') ||
          item.season.contains(currentSeason.split(' - ').first)) {
        return item;
      }
    }
    return CropCatalogService.items.first;
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
}
