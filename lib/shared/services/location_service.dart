import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../models/app_location.dart';

class LocationService {
  Future<AppLocation> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationException('Activa el GPS del dispositivo para continuar.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw LocationException('No se otorgó permiso de ubicación.');
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    var label = 'Ubicación actual';
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      final placemark = placemarks.isNotEmpty ? placemarks.first : null;
      final city =
          _firstNonEmpty(<String?>[
            placemark?.locality,
            placemark?.subAdministrativeArea,
            placemark?.subLocality,
            placemark?.name,
          ]) ??
          'Ubicación actual';
      final state = _firstNonEmpty(<String?>[
        placemark?.administrativeArea,
        placemark?.subAdministrativeArea,
      ]);
      final pieces = <String>[city, if (state != null && state != city) state];
      label = pieces.isEmpty ? label : pieces.join(', ');
    } catch (_) {
      label = 'Ubicación actual';
    }

    return AppLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      label: label,
    );
  }

  Future<AppLocation> geocode(String query) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) {
      throw LocationException('Ingresa una ubicación válida.');
    }

    final List<Location> locations;
    try {
      locations = await locationFromAddress(normalizedQuery);
    } catch (_) {
      throw LocationException('No se pudo validar la ubicación indicada.');
    }
    if (locations.isEmpty) {
      throw LocationException('No se encontró la ubicación indicada.');
    }
    final location = locations.first;
    return AppLocation(
      latitude: location.latitude,
      longitude: location.longitude,
      label: normalizedQuery,
    );
  }

  String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      final trimmed = value?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return null;
  }
}

class LocationException implements Exception {
  const LocationException(this.message);

  final String message;
}
