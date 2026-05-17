import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import '../../features/crops_catalog/models/crop_catalog_item.dart';
import '../../features/crop_tracking/services/crop_tracking_service.dart';
import '../models/app_location.dart';
import '../models/app_settings.dart';
import '../models/crop_record.dart';
import '../models/weather_snapshot.dart';
import '../services/crops/crop_recommendation_service.dart';
import '../services/crops/crop_record_service.dart';
import '../services/storage/local_database_service.dart';
import '../services/location/location_settings_service.dart';
import '../services/location/location_service.dart';
import '../services/weather/weather_service.dart';

class AppStore extends ChangeNotifier {
  AppStore({
    LocalDatabaseService? databaseService,
    LocationService? locationService,
    WeatherService? weatherService,
  }) : _databaseService = databaseService ?? LocalDatabaseService(),
       _locationService = locationService ?? LocationService(),
       _weatherService = weatherService ?? WeatherService() {
    _cropRecordService = CropRecordService(_databaseService);
    _locationSettingsService = LocationSettingsService(
      databaseService: _databaseService,
      locationService: _locationService,
    );
  }

  final LocalDatabaseService _databaseService;
  final LocationService _locationService;
  final WeatherService _weatherService;
  late final CropRecordService _cropRecordService;
  late final LocationSettingsService _locationSettingsService;

  AppSettings _settings = AppSettings.defaults();
  List<CropRecord> _crops = <CropRecord>[];
  WeatherSnapshot? _weather;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  List<ConnectivityResult> _connectivityResults = const <ConnectivityResult>[];
  bool _initialized = false;
  bool _isBusy = false;
  bool _isRefreshingWeather = false;
  String? _lastError;
  Future<void>? _initializationFuture;

  AppSettings get settings => _settings;
  List<CropRecord> get crops =>
      List<CropRecord>.unmodifiable(_crops.where((crop) => !crop.isCompleted));
  List<CropRecord> get cropHistory {
    final history = _crops.where((crop) => crop.isCompleted).toList()
      ..sort((a, b) {
        final dateA = a.completedAt ?? a.createdAt;
        final dateB = b.completedAt ?? b.createdAt;
        return dateB.compareTo(dateA);
      });
    return List<CropRecord>.unmodifiable(history);
  }

  WeatherSnapshot? get weather => _weather;
  DateTime? get lastWifiSyncAt => _weather?.lastWifiSyncAt;
  bool get hasNetworkConnection {
    return _connectivityResults.any((result) {
      if (result == ConnectivityResult.none) {
        return false;
      }
      if (result == ConnectivityResult.mobile) {
        return _settings.allowMobileData;
      }
      return true;
    });
  }

  bool get hasWifiConnection => hasNetworkConnection;
  bool get isShowingCachedWeather => _weather?.isFromCache ?? false;
  bool get initialized => _initialized;
  bool get isBusy => _isBusy;
  String? get lastError => _lastError;

  int get activeCropsCount => crops.length;

  double get totalHectares =>
      crops.fold<double>(0, (sum, crop) => sum + crop.areaHa);

  int get upcomingEventsCount => crops.fold<int>(
    0,
    (sum, crop) =>
        sum +
        CropTrackingService.buildPlan(crop).upcomingEvents.where((event) {
          return !event.completed && event.daysUntil >= 0;
        }).length,
  );

  CropRecord? get nextHarvestCrop {
    if (crops.isEmpty) {
      return null;
    }
    final sorted = [...crops]
      ..sort((a, b) => a.daysToHarvest.compareTo(b.daysToHarvest));
    return sorted.first;
  }

  CropRecord? get nextPendingEventCrop {
    if (crops.isEmpty) {
      return null;
    }
    final sorted = [...crops]
      ..sort((a, b) {
        final summaryA = CropTrackingService.buildSummary(a);
        final summaryB = CropTrackingService.buildSummary(b);
        final compareDays = summaryA.nextEventDays.compareTo(
          summaryB.nextEventDays,
        );
        if (compareDays != 0) {
          return compareDays;
        }
        return a.createdAt.compareTo(b.createdAt);
      });
    return sorted.first;
  }

  String get currentSeason {
    return CropRecommendationService.currentSeason();
  }

  CropCatalogItem get recommendedCropItem {
    return CropRecommendationService.recommendedCropItem();
  }

  List<CropCatalogItem> get recommendedCropItems {
    return CropRecommendationService.recommendedCropItems();
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
    _setBusy(true);
    try {
      await _databaseService.init();
      _settings = await _databaseService.loadSettings();
      _crops = await _databaseService.loadCrops();
      _weather = await _databaseService.loadWeather();
      await _initializeConnectivity();
      _initialized = true;
      notifyListeners();
      try {
        await _ensureLocationCoordinates(
          forceCurrentLocation: _settings.autoLocation,
          allowGeocoding: hasNetworkConnection,
        );
        if (hasNetworkConnection) {
          await _refreshWeatherInternal(syncTriggeredByWifi: true);
        } else if (_weather != null) {
          _weather = _weather!.copyWith(isFromCache: true);
          notifyListeners();
        }
      } catch (_) {
        _lastError = 'No se pudo actualizar ubicación o clima.';
      }
    } finally {
      _setBusy(false);
    }
  }

  Future<void> addCrop(CropRecord crop) async {
    await initialize();
    _crops = await _cropRecordService.saveCrop(crop);
    notifyListeners();
  }

  Future<void> updateCrop(CropRecord crop) async {
    await initialize();
    _crops = await _cropRecordService.saveCrop(crop);
    notifyListeners();
  }

  Future<CropRecord?> markCropEventCompleted(
    String cropId,
    String eventId,
  ) async {
    await initialize();
    final result = await _cropRecordService.markEventCompleted(cropId, eventId);
    _crops = result.crops;
    notifyListeners();
    return result.updatedCrop;
  }

  Future<CropRecord?> unmarkCropEventCompleted(
    String cropId,
    String eventId,
  ) async {
    await initialize();
    final result = await _cropRecordService.unmarkEventCompleted(
      cropId,
      eventId,
    );
    _crops = result.crops;
    notifyListeners();
    return result.updatedCrop;
  }

  Future<void> completeCrop(String cropId) async {
    await initialize();
    _crops = await _cropRecordService.completeCrop(cropId);
    notifyListeners();
  }

  Future<void> deleteCrop(String cropId) async {
    await initialize();
    _crops = await _cropRecordService.deleteCrop(cropId);
    notifyListeners();
  }

  Future<void> updateSettings(AppSettings settings) async {
    await initialize();
    _settings = settings;
    await _databaseService.saveSettings(settings);
    notifyListeners();
  }

  Future<void> refreshCurrentLocation({bool silent = false}) async {
    await initialize();
    try {
      _setBusy(true);
      _settings = await _locationSettingsService.refreshCurrentLocation(
        _settings,
      );
      _lastError = null;
      if (hasNetworkConnection) {
        await _refreshWeatherInternal(syncTriggeredByWifi: true);
      } else {
        _clearWeatherIfOutdated();
      }
    } finally {
      _setBusy(false);
      if (!silent) {
        notifyListeners();
      }
    }
  }

  Future<void> saveManualLocation(String query) async {
    await initialize();
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) {
      throw const LocationException('Ingresa una ubicación válida.');
    }
    _setBusy(true);
    try {
      _settings = await _locationSettingsService.saveManualLocation(
        _settings,
        normalizedQuery,
      );
      _lastError = null;
      if (hasNetworkConnection) {
        await _refreshWeatherInternal(syncTriggeredByWifi: true);
      } else {
        _clearWeatherIfOutdated();
      }
    } finally {
      _setBusy(false);
      notifyListeners();
    }
  }

  Future<void> savePresetLocation(AppLocation location) async {
    await initialize();
    _setBusy(true);
    try {
      _settings = await _locationSettingsService.savePresetLocation(
        _settings,
        location,
      );
      _lastError = null;
      if (hasNetworkConnection) {
        await _refreshWeatherInternal(syncTriggeredByWifi: true);
      } else {
        _clearWeatherIfOutdated();
      }
    } finally {
      _setBusy(false);
      notifyListeners();
    }
  }

  Future<void> refreshWeather() async {
    await initialize();
    await _ensureLocationCoordinates(
      forceCurrentLocation: _settings.autoLocation,
      allowGeocoding: hasNetworkConnection,
    );
    if (!hasNetworkConnection) {
      if (_weather != null) {
        _weather = _weather!.copyWith(isFromCache: true);
        notifyListeners();
      }
      return;
    }
    await _refreshWeatherInternal(syncTriggeredByWifi: true);
  }

  Future<void> _refreshWeatherInternal({
    required bool syncTriggeredByWifi,
  }) async {
    final latitude = _settings.latitude;
    final longitude = _settings.longitude;
    if (latitude == null || longitude == null || _isRefreshingWeather) {
      return;
    }
    _isRefreshingWeather = true;
    try {
      final snapshot = await _weatherService.fetchWeather(
        latitude: latitude,
        longitude: longitude,
        locationLabel: _settings.locationName,
      );
      final persistedSnapshot = snapshot.copyWith(
        lastWifiSyncAt: syncTriggeredByWifi
            ? DateTime.now()
            : _weather?.lastWifiSyncAt,
        isFromCache: false,
      );
      _weather = persistedSnapshot;
      await _databaseService.saveWeather(persistedSnapshot);
      _lastError = null;
    } catch (_) {
      _lastError =
          'No se pudo actualizar el clima. Se mostrará información guardada si existe.';
      if (_weather != null) {
        _weather = _weather!.copyWith(isFromCache: true);
      } else {
        _weather = await _databaseService.loadWeather();
      }
    } finally {
      _isRefreshingWeather = false;
      notifyListeners();
    }
  }

  Future<void> _initializeConnectivity() async {
    await _connectivitySubscription?.cancel();
    final connectivity = Connectivity();
    _connectivityResults = await connectivity.checkConnectivity();
    _connectivitySubscription = connectivity.onConnectivityChanged.listen((
      results,
    ) {
      unawaited(_handleConnectivityChange(results));
    });
  }

  Future<void> _handleConnectivityChange(
    List<ConnectivityResult> results,
  ) async {
    final hadNetwork = hasNetworkConnection;
    _connectivityResults = results;
    if (!hadNetwork && hasNetworkConnection) {
      await _ensureLocationCoordinates(
        forceCurrentLocation: _settings.autoLocation,
        allowGeocoding: true,
      );
      await _refreshWeatherInternal(syncTriggeredByWifi: true);
      return;
    }
    if (hadNetwork && !hasNetworkConnection && _weather != null) {
      _weather = _weather!.copyWith(isFromCache: true);
    }
    notifyListeners();
  }

  Future<void> _ensureLocationCoordinates({
    bool forceCurrentLocation = false,
    bool allowGeocoding = true,
  }) async {
    _settings = await _locationSettingsService.ensureCoordinates(
      _settings,
      forceCurrentLocation: forceCurrentLocation,
      allowGeocoding: allowGeocoding,
    );
  }

  void _clearWeatherIfOutdated() {
    if (_weather == null) {
      return;
    }
    if (_weather!.locationLabel != _settings.locationName) {
      _weather = null;
      return;
    }
    _weather = _weather!.copyWith(isFromCache: true);
  }

  void _setBusy(bool value) {
    _isBusy = value;
    if (hasListeners) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
