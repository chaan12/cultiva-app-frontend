class AppSettings {
  const AppSettings({
    required this.weatherAlerts,
    required this.cropAlerts,
    required this.silentMode,
    required this.rainAlerts,
    required this.cycloneAlerts,
    required this.droughtAlerts,
    required this.heatAlerts,
    required this.autoLocation,
    required this.locationName,
    this.latitude,
    this.longitude,
  });

  factory AppSettings.defaults() {
    return const AppSettings(
      weatherAlerts: true,
      cropAlerts: true,
      silentMode: false,
      rainAlerts: true,
      cycloneAlerts: true,
      droughtAlerts: true,
      heatAlerts: false,
      autoLocation: true,
      locationName: 'Mérida, Yucatán',
    );
  }

  factory AppSettings.fromMap(Map<String, Object?> map) {
    final defaults = AppSettings.defaults();
    bool readBool(String key, bool fallback) {
      final value = map[key];
      if (value is bool) {
        return value;
      }
      if (value is int) {
        return value == 1;
      }
      if (value is String) {
        return value == 'true' || value == '1';
      }
      return fallback;
    }

    double? readDouble(String key) {
      final value = map[key];
      if (value is double) {
        return value;
      }
      if (value is int) {
        return value.toDouble();
      }
      if (value is String) {
        return double.tryParse(value);
      }
      return null;
    }

    return AppSettings(
      weatherAlerts: readBool('weatherAlerts', defaults.weatherAlerts),
      cropAlerts: readBool('cropAlerts', defaults.cropAlerts),
      silentMode: readBool('silentMode', defaults.silentMode),
      rainAlerts: readBool('rainAlerts', defaults.rainAlerts),
      cycloneAlerts: readBool('cycloneAlerts', defaults.cycloneAlerts),
      droughtAlerts: readBool('droughtAlerts', defaults.droughtAlerts),
      heatAlerts: readBool('heatAlerts', defaults.heatAlerts),
      autoLocation: readBool('autoLocation', defaults.autoLocation),
      locationName: (map['locationName'] as String?) ?? defaults.locationName,
      latitude: readDouble('latitude'),
      longitude: readDouble('longitude'),
    );
  }

  final bool weatherAlerts;
  final bool cropAlerts;
  final bool silentMode;
  final bool rainAlerts;
  final bool cycloneAlerts;
  final bool droughtAlerts;
  final bool heatAlerts;
  final bool autoLocation;
  final String locationName;
  final double? latitude;
  final double? longitude;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'weatherAlerts': weatherAlerts,
      'cropAlerts': cropAlerts,
      'silentMode': silentMode,
      'rainAlerts': rainAlerts,
      'cycloneAlerts': cycloneAlerts,
      'droughtAlerts': droughtAlerts,
      'heatAlerts': heatAlerts,
      'autoLocation': autoLocation,
      'locationName': locationName,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  AppSettings copyWith({
    bool? weatherAlerts,
    bool? cropAlerts,
    bool? silentMode,
    bool? rainAlerts,
    bool? cycloneAlerts,
    bool? droughtAlerts,
    bool? heatAlerts,
    bool? autoLocation,
    String? locationName,
    double? latitude,
    double? longitude,
    bool clearCoordinates = false,
  }) {
    return AppSettings(
      weatherAlerts: weatherAlerts ?? this.weatherAlerts,
      cropAlerts: cropAlerts ?? this.cropAlerts,
      silentMode: silentMode ?? this.silentMode,
      rainAlerts: rainAlerts ?? this.rainAlerts,
      cycloneAlerts: cycloneAlerts ?? this.cycloneAlerts,
      droughtAlerts: droughtAlerts ?? this.droughtAlerts,
      heatAlerts: heatAlerts ?? this.heatAlerts,
      autoLocation: autoLocation ?? this.autoLocation,
      locationName: locationName ?? this.locationName,
      latitude: clearCoordinates ? null : (latitude ?? this.latitude),
      longitude: clearCoordinates ? null : (longitude ?? this.longitude),
    );
  }
}
