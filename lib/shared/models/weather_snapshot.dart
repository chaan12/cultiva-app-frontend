import '../security/input_sanitizer.dart';
import '../security/safe_json.dart';

class WeatherSnapshot {
  const WeatherSnapshot({
    required this.locationLabel,
    required this.primarySourceId,
    required this.primarySourceName,
    required this.temperatureC,
    required this.description,
    required this.humidity,
    required this.windSpeedKmh,
    required this.windGustKmh,
    required this.rainProbability,
    required this.precipitationMm,
    required this.uvIndex,
    required this.visibilityKm,
    required this.cloudCover,
    required this.pressureHpa,
    required this.apparentTemperatureC,
    required this.daily,
    required this.hourly,
    required this.alerts,
    required this.providers,
    required this.updatedAt,
    this.lastWifiSyncAt,
    this.isFromCache = false,
  });

  factory WeatherSnapshot.fromMap(
    Map<String, dynamic> map, {
    bool isFromCache = false,
  }) {
    DateTime readDateTime(Object? value) {
      if (value is String) {
        final parsed = DateTime.tryParse(value);
        if (parsed != null) {
          return parsed;
        }
      }
      throw const FormatException('Invalid weather timestamp');
    }

    return WeatherSnapshot(
      locationLabel: InputSanitizer.location(
        _readWeatherString(map['locationLabel']),
      ),
      primarySourceId: InputSanitizer.safeId(
        _readWeatherString(map['primarySourceId']),
      ),
      primarySourceName: InputSanitizer.text(
        _readWeatherString(map['primarySourceName']),
        maxLength: 80,
      ),
      temperatureC: _readWeatherDouble(map['temperatureC']),
      description: InputSanitizer.text(
        _readWeatherString(map['description']),
        maxLength: 80,
      ),
      humidity: _readWeatherInt(map['humidity']),
      windSpeedKmh: _readWeatherDouble(map['windSpeedKmh']),
      windGustKmh: _readWeatherDouble(map['windGustKmh']),
      rainProbability: _readWeatherInt(map['rainProbability']),
      precipitationMm: _readWeatherDouble(map['precipitationMm']),
      uvIndex: _readWeatherDouble(map['uvIndex']),
      visibilityKm: _readWeatherDouble(map['visibilityKm']),
      cloudCover: _readWeatherInt(map['cloudCover']),
      pressureHpa: _readWeatherDouble(map['pressureHpa']),
      apparentTemperatureC: _readWeatherDouble(map['apparentTemperatureC']),
      daily: SafeJson.listAt(map, 'daily')
          .whereType<Map>()
          .map(
            (item) => DailyWeatherPoint.fromMap(item.cast<String, dynamic>()),
          )
          .take(16)
          .toList(),
      hourly: SafeJson.listAt(map, 'hourly')
          .whereType<Map>()
          .map(
            (item) => HourlyWeatherPoint.fromMap(item.cast<String, dynamic>()),
          )
          .take(24)
          .toList(),
      alerts: SafeJson.listAt(map, 'alerts')
          .map((item) => InputSanitizer.text(item.toString(), maxLength: 160))
          .where((item) => item.isNotEmpty)
          .take(8)
          .toList(),
      providers: SafeJson.listAt(map, 'providers')
          .whereType<Map>()
          .map(
            (item) =>
                WeatherProviderSnapshot.fromMap(item.cast<String, dynamic>()),
          )
          .take(8)
          .toList(),
      updatedAt: readDateTime(map['updatedAt']),
      lastWifiSyncAt: _readNullableWeatherDateTime(map['lastWifiSyncAt']),
      isFromCache: isFromCache,
    );
  }

  final String locationLabel;
  final String primarySourceId;
  final String primarySourceName;
  final double temperatureC;
  final String description;
  final int humidity;
  final double windSpeedKmh;
  final double windGustKmh;
  final int rainProbability;
  final double precipitationMm;
  final double uvIndex;
  final double visibilityKm;
  final int cloudCover;
  final double pressureHpa;
  final double apparentTemperatureC;
  final List<DailyWeatherPoint> daily;
  final List<HourlyWeatherPoint> hourly;
  final List<String> alerts;
  final List<WeatherProviderSnapshot> providers;
  final DateTime updatedAt;
  final DateTime? lastWifiSyncAt;
  final bool isFromCache;

  DateTime? get forecastStartDate {
    if (daily.isNotEmpty) {
      return _weatherDateOnly(daily.first.date);
    }
    if (hourly.isNotEmpty) {
      return _weatherDateOnly(hourly.first.time);
    }
    return null;
  }

  DateTime? get forecastEndDate {
    if (daily.isNotEmpty) {
      return _weatherDateOnly(daily.last.date);
    }
    if (hourly.isNotEmpty) {
      return _weatherDateOnly(hourly.last.time);
    }
    return null;
  }

  WeatherSnapshot copyWith({
    String? locationLabel,
    String? primarySourceId,
    String? primarySourceName,
    double? temperatureC,
    String? description,
    int? humidity,
    double? windSpeedKmh,
    double? windGustKmh,
    int? rainProbability,
    double? precipitationMm,
    double? uvIndex,
    double? visibilityKm,
    int? cloudCover,
    double? pressureHpa,
    double? apparentTemperatureC,
    List<DailyWeatherPoint>? daily,
    List<HourlyWeatherPoint>? hourly,
    List<String>? alerts,
    List<WeatherProviderSnapshot>? providers,
    DateTime? updatedAt,
    DateTime? lastWifiSyncAt,
    bool clearLastWifiSync = false,
    bool? isFromCache,
  }) {
    return WeatherSnapshot(
      locationLabel: locationLabel ?? this.locationLabel,
      primarySourceId: primarySourceId ?? this.primarySourceId,
      primarySourceName: primarySourceName ?? this.primarySourceName,
      temperatureC: temperatureC ?? this.temperatureC,
      description: description ?? this.description,
      humidity: humidity ?? this.humidity,
      windSpeedKmh: windSpeedKmh ?? this.windSpeedKmh,
      windGustKmh: windGustKmh ?? this.windGustKmh,
      rainProbability: rainProbability ?? this.rainProbability,
      precipitationMm: precipitationMm ?? this.precipitationMm,
      uvIndex: uvIndex ?? this.uvIndex,
      visibilityKm: visibilityKm ?? this.visibilityKm,
      cloudCover: cloudCover ?? this.cloudCover,
      pressureHpa: pressureHpa ?? this.pressureHpa,
      apparentTemperatureC: apparentTemperatureC ?? this.apparentTemperatureC,
      daily: daily ?? this.daily,
      hourly: hourly ?? this.hourly,
      alerts: alerts ?? this.alerts,
      providers: providers ?? this.providers,
      updatedAt: updatedAt ?? this.updatedAt,
      lastWifiSyncAt: clearLastWifiSync
          ? null
          : (lastWifiSyncAt ?? this.lastWifiSyncAt),
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'locationLabel': locationLabel,
      'primarySourceId': primarySourceId,
      'primarySourceName': primarySourceName,
      'temperatureC': temperatureC,
      'description': description,
      'humidity': humidity,
      'windSpeedKmh': windSpeedKmh,
      'windGustKmh': windGustKmh,
      'rainProbability': rainProbability,
      'precipitationMm': precipitationMm,
      'uvIndex': uvIndex,
      'visibilityKm': visibilityKm,
      'cloudCover': cloudCover,
      'pressureHpa': pressureHpa,
      'apparentTemperatureC': apparentTemperatureC,
      'daily': daily.map((item) => item.toMap()).toList(),
      'hourly': hourly.map((item) => item.toMap()).toList(),
      'alerts': alerts,
      'providers': providers.map((item) => item.toMap()).toList(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastWifiSyncAt': lastWifiSyncAt?.toIso8601String(),
    };
  }
}

class DailyWeatherPoint {
  const DailyWeatherPoint({
    required this.label,
    required this.date,
    required this.minTempC,
    required this.maxTempC,
    required this.rainProbability,
    required this.description,
  });

  factory DailyWeatherPoint.fromMap(Map<String, dynamic> map) {
    final date = _readWeatherDateTime(map['date']);
    return DailyWeatherPoint(
      label: InputSanitizer.text(
        _readWeatherString(map['label']),
        maxLength: 16,
      ),
      date: date,
      minTempC: _readWeatherDouble(map['minTempC']),
      maxTempC: _readWeatherDouble(map['maxTempC']),
      rainProbability: _readWeatherInt(map['rainProbability']),
      description: InputSanitizer.text(
        _readWeatherString(map['description']),
        maxLength: 80,
      ),
    );
  }

  final String label;
  final DateTime date;
  final double minTempC;
  final double maxTempC;
  final int rainProbability;
  final String description;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'label': label,
      'date': date.toIso8601String(),
      'minTempC': minTempC,
      'maxTempC': maxTempC,
      'rainProbability': rainProbability,
      'description': description,
    };
  }
}

class HourlyWeatherPoint {
  const HourlyWeatherPoint({
    required this.label,
    required this.time,
    required this.temperatureC,
    required this.humidity,
    required this.rainProbability,
    required this.precipitationMm,
    required this.windSpeedKmh,
    required this.uvIndex,
    required this.visibilityKm,
  });

  factory HourlyWeatherPoint.fromMap(Map<String, dynamic> map) {
    final time = _readWeatherDateTime(map['time']);
    return HourlyWeatherPoint(
      label: InputSanitizer.text(
        _readWeatherString(map['label']),
        maxLength: 16,
      ),
      time: time,
      temperatureC: _readWeatherDouble(map['temperatureC']),
      humidity: _readWeatherInt(map['humidity']),
      rainProbability: _readWeatherInt(map['rainProbability']),
      precipitationMm: _readWeatherDouble(map['precipitationMm']),
      windSpeedKmh: _readWeatherDouble(map['windSpeedKmh']),
      uvIndex: _readWeatherDouble(map['uvIndex']),
      visibilityKm: _readWeatherDouble(map['visibilityKm']),
    );
  }

  final String label;
  final DateTime time;
  final double temperatureC;
  final int humidity;
  final int rainProbability;
  final double precipitationMm;
  final double windSpeedKmh;
  final double uvIndex;
  final double visibilityKm;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'label': label,
      'time': time.toIso8601String(),
      'temperatureC': temperatureC,
      'humidity': humidity,
      'rainProbability': rainProbability,
      'precipitationMm': precipitationMm,
      'windSpeedKmh': windSpeedKmh,
      'uvIndex': uvIndex,
      'visibilityKm': visibilityKm,
    };
  }
}

class WeatherProviderSnapshot {
  const WeatherProviderSnapshot({
    required this.id,
    required this.name,
    required this.description,
    required this.reliability,
    required this.available,
    required this.data,
    required this.alerts,
  });

  factory WeatherProviderSnapshot.fromMap(Map<String, dynamic> map) {
    return WeatherProviderSnapshot(
      id: InputSanitizer.safeId(_readWeatherString(map['id'])),
      name: InputSanitizer.text(_readWeatherString(map['name']), maxLength: 80),
      description: InputSanitizer.text(
        _readWeatherString(map['description']),
        maxLength: 160,
      ),
      reliability: _readWeatherInt(map['reliability']),
      available: map['available'] as bool? ?? false,
      data: (SafeJson.mapAt(map, 'data') ?? <String, dynamic>{}).map(
        (key, value) => MapEntry(
          InputSanitizer.safeId(key, maxLength: 40),
          InputSanitizer.text(value.toString(), maxLength: 80),
        ),
      )..removeWhere((key, value) => key.isEmpty),
      alerts: SafeJson.listAt(map, 'alerts')
          .map((item) => InputSanitizer.text(item.toString(), maxLength: 160))
          .where((item) => item.isNotEmpty)
          .take(8)
          .toList(),
    );
  }

  final String id;
  final String name;
  final String description;
  final int reliability;
  final bool available;
  final Map<String, String> data;
  final List<String> alerts;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'name': name,
      'description': description,
      'reliability': reliability,
      'available': available,
      'data': data,
      'alerts': alerts,
    };
  }
}

double _readWeatherDouble(Object? value) {
  if (value is num) {
    final parsed = value.toDouble();
    return parsed.isFinite ? parsed : 0;
  }
  if (value is String) {
    final parsed = double.tryParse(value);
    return parsed != null && parsed.isFinite ? parsed : 0;
  }
  return 0;
}

int _readWeatherInt(Object? value) {
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value) ?? 0;
  }
  return 0;
}

DateTime? _readNullableWeatherDateTime(Object? value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}

DateTime _readWeatherDateTime(Object? value) {
  if (value is String) {
    final parsed = DateTime.tryParse(value);
    if (parsed != null) {
      return parsed;
    }
  }
  throw const FormatException('Invalid weather timestamp');
}

String _readWeatherString(Object? value) {
  return value is String ? value : '';
}

DateTime _weatherDateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
