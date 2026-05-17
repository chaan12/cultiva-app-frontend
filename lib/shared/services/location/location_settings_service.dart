import '../../models/app_location.dart';
import '../../models/app_settings.dart';
import '../storage/local_database_service.dart';
import 'location_service.dart';

class LocationSettingsService {
  const LocationSettingsService({
    required LocalDatabaseService databaseService,
    required LocationService locationService,
  }) : _databaseService = databaseService,
       _locationService = locationService;

  final LocalDatabaseService _databaseService;
  final LocationService _locationService;

  Future<AppSettings> refreshCurrentLocation(AppSettings settings) async {
    final location = await _locationService.getCurrentLocation();
    final updatedSettings = settings.copyWith(
      autoLocation: true,
      locationName: location.label,
      latitude: location.latitude,
      longitude: location.longitude,
    );
    await _databaseService.saveSettings(updatedSettings);
    return updatedSettings;
  }

  Future<AppSettings> saveManualLocation(
    AppSettings settings,
    String query,
  ) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) {
      throw const LocationException('Ingresa una ubicación válida.');
    }

    final location = await _locationService.geocode(normalizedQuery);
    final updatedSettings = settings.copyWith(
      autoLocation: false,
      locationName: normalizedQuery,
      latitude: location.latitude,
      longitude: location.longitude,
    );
    await _databaseService.saveSettings(updatedSettings);
    return updatedSettings;
  }

  Future<AppSettings> savePresetLocation(
    AppSettings settings,
    AppLocation location,
  ) async {
    final updatedSettings = settings.copyWith(
      autoLocation: false,
      locationName: location.label,
      latitude: location.latitude,
      longitude: location.longitude,
    );
    await _databaseService.saveSettings(updatedSettings);
    return updatedSettings;
  }

  Future<AppSettings> ensureCoordinates(
    AppSettings settings, {
    bool forceCurrentLocation = false,
    bool allowGeocoding = true,
  }) async {
    if (settings.autoLocation) {
      if (!forceCurrentLocation &&
          settings.latitude != null &&
          settings.longitude != null) {
        return settings;
      }
      return refreshCurrentLocation(settings);
    }

    if (settings.latitude != null && settings.longitude != null) {
      return settings;
    }

    if (!allowGeocoding) {
      return settings;
    }

    final fallback = await _locationService.geocode(settings.locationName);
    final updatedSettings = settings.copyWith(
      latitude: fallback.latitude,
      longitude: fallback.longitude,
    );
    await _databaseService.saveSettings(updatedSettings);
    return updatedSettings;
  }
}
