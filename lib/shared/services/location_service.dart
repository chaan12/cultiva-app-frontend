import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../models/app_location.dart';

class LocationService {
  Future<AppLocation> getCurrentLocation() async {
    debugPrint('[LocationService] Iniciando lectura de ubicación actual');
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    debugPrint('[LocationService] GPS habilitado: $serviceEnabled');
    if (!serviceEnabled) {
      throw LocationException('Activa el GPS del dispositivo para continuar.');
    }

    var permission = await Geolocator.checkPermission();
    debugPrint('[LocationService] Permiso inicial: $permission');
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      debugPrint('[LocationService] Permiso tras solicitarlo: $permission');
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      debugPrint('[LocationService] Permiso rechazado: $permission');
      throw LocationException('No se otorgó permiso de ubicación.');
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    debugPrint(
      '[LocationService] Posición obtenida lat=${position.latitude}, lng=${position.longitude}',
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
      debugPrint('[LocationService] Reverse geocoding exitoso: $label');
    } catch (error) {
      debugPrint('[LocationService] Reverse geocoding falló: $error');
    }

    return AppLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      label: label,
    );
  }

  Future<AppLocation> geocode(String query) async {
    debugPrint('[LocationService] Geocodificando ubicación manual: $query');
    final locations = await locationFromAddress(query);
    if (locations.isEmpty) {
      debugPrint('[LocationService] Sin resultados para: $query');
      throw LocationException('No se encontró la ubicación indicada.');
    }
    final location = locations.first;
    debugPrint(
      '[LocationService] Geocoding manual exitoso lat=${location.latitude}, lng=${location.longitude}',
    );
    return AppLocation(
      latitude: location.latitude,
      longitude: location.longitude,
      label: query,
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
