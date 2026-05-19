import 'package:http/http.dart' as http;

import '../../../core/config/app_config.dart';
import '../../models/weather_snapshot.dart';
import '../../security/safe_json.dart';

class WeatherService {
  static const List<_WeatherProviderConfig> _providers =
      <_WeatherProviderConfig>[
        _WeatherProviderConfig(
          id: 'noaa_gfs',
          name: 'NOAA GFS',
          description: 'Global Forecast System de NOAA',
          reliability: 95,
        ),
        _WeatherProviderConfig(
          id: 'ecmwf',
          name: 'ECMWF',
          description: 'Centro Europeo de Pronóstico de Mediano Plazo',
          reliability: 94,
        ),
        _WeatherProviderConfig(
          id: 'gem',
          name: 'GEM Canada',
          description: 'Modelo global del servicio meteorológico canadiense',
          reliability: 90,
        ),
        _WeatherProviderConfig(
          id: 'meteofrance',
          name: 'Meteo-France',
          description: 'Modelo global de Meteo-France',
          reliability: 88,
        ),
        _WeatherProviderConfig(
          id: 'jma',
          name: 'JMA GSM',
          description: 'Modelo global de la Agencia Meteorológica de Japón',
          reliability: 84,
        ),
      ];

  Future<WeatherSnapshot> fetchWeather({
    required double latitude,
    required double longitude,
    required String locationLabel,
  }) async {
    if (!_isValidCoordinate(latitude, min: -90, max: 90) ||
        !_isValidCoordinate(longitude, min: -180, max: 180)) {
      throw const WeatherException(
        'Coordenadas inválidas para consultar clima.',
      );
    }

    final providerResponses = await Future.wait(
      _providers.map(
        (provider) => _fetchProvider(
          provider: provider,
          latitude: latitude,
          longitude: longitude,
        ),
      ),
    );

    final availableProviders = providerResponses
        .where((response) => response.snapshot != null)
        .toList();
    if (availableProviders.isEmpty) {
      throw WeatherException(
        'No fue posible consultar el clima en este momento.',
      );
    }

    final primary = availableProviders.firstWhere(
      (provider) => provider.config.id == 'noaa_gfs',
      orElse: () => availableProviders.first,
    );
    final primaryCurrent = primary.snapshot!;

    return WeatherSnapshot(
      locationLabel: locationLabel,
      primarySourceId: primary.config.id,
      primarySourceName: primary.config.name,
      temperatureC: primaryCurrent.temperatureC,
      description: primaryCurrent.description,
      humidity: primaryCurrent.humidity,
      windSpeedKmh: primaryCurrent.windSpeedKmh,
      windGustKmh: primaryCurrent.windGustKmh,
      rainProbability: primaryCurrent.rainProbability,
      precipitationMm: primaryCurrent.precipitationMm,
      uvIndex: primaryCurrent.uvIndex,
      visibilityKm: primaryCurrent.visibilityKm,
      cloudCover: primaryCurrent.cloudCover,
      pressureHpa: primaryCurrent.pressureHpa,
      apparentTemperatureC: primaryCurrent.apparentTemperatureC,
      daily: primaryCurrent.daily,
      hourly: primaryCurrent.hourly,
      alerts: _buildAlerts(primaryCurrent),
      providers: providerResponses
          .map(
            (provider) => WeatherProviderSnapshot(
              id: provider.config.id,
              name: provider.config.name,
              description: provider.config.description,
              reliability: provider.config.reliability,
              available: provider.snapshot != null,
              data: provider.snapshot == null
                  ? <String, String>{'status': 'No disponible'}
                  : _buildProviderData(provider.snapshot!),
              alerts: provider.snapshot == null
                  ? <String>[
                      provider.errorMessage ??
                          'Sin cobertura para esta ubicación.',
                    ]
                  : _buildAlerts(provider.snapshot!),
            ),
          )
          .toList(),
      updatedAt: DateTime.now(),
    );
  }

  Future<_ProviderFetchResult> _fetchProvider({
    required _WeatherProviderConfig provider,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final queryParameters = <String, String>{
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'timezone': 'auto',
        'forecast_days': '16',
        'current':
            'temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,cloud_cover,pressure_msl,wind_speed_10m,wind_gusts_10m,visibility,uv_index',
        'hourly':
            'temperature_2m,relative_humidity_2m,apparent_temperature,precipitation_probability,precipitation,wind_speed_10m,wind_gusts_10m,uv_index,visibility,weather_code,cloud_cover,pressure_msl',
        'daily':
            'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max',
      };
      final apiKey = AppConfig.weatherApiKey;
      if (apiKey != null) {
        queryParameters['apikey'] = apiKey;
      }
      final uri = Uri.https(
        AppConfig.weatherApiHost,
        AppConfig.weatherProviderEndpoint(provider.id),
        queryParameters,
      );
      final response = await http.get(uri).timeout(AppConfig.requestTimeout);
      if (response.statusCode != 200) {
        return _ProviderFetchResult(
          config: provider,
          errorMessage: 'No disponible',
        );
      }

      final decoded = _decodeWeatherResponse(response.body);
      if (decoded == null) {
        return _ProviderFetchResult(
          config: provider,
          errorMessage: 'Respuesta inválida',
        );
      }
      final json = decoded;
      if ((json['error'] as bool?) ?? false) {
        return _ProviderFetchResult(
          config: provider,
          errorMessage: 'Sin cobertura para esta ubicación.',
        );
      }
      return _ProviderFetchResult(
        config: provider,
        snapshot: _parseProviderWeather(json),
      );
    } catch (_) {
      return _ProviderFetchResult(
        config: provider,
        errorMessage: 'No disponible',
      );
    }
  }

  _ProviderWeather _parseProviderWeather(Map<String, dynamic> json) {
    final current = SafeJson.mapAt(json, 'current') ?? <String, dynamic>{};
    final daily = SafeJson.mapAt(json, 'daily') ?? <String, dynamic>{};
    final hourly = SafeJson.mapAt(json, 'hourly') ?? <String, dynamic>{};

    final dailyTime = SafeJson.listAt(
      daily,
      'time',
    ).map((item) => item.toString()).take(16).toList();
    final dailyMin = SafeJson.listAt(
      daily,
      'temperature_2m_min',
    ).map(_toDouble).take(16).toList();
    final dailyMax = SafeJson.listAt(
      daily,
      'temperature_2m_max',
    ).map(_toDouble).take(16).toList();
    final dailyRain = SafeJson.listAt(
      daily,
      'precipitation_probability_max',
    ).map(_toInt).take(16).toList();
    final dailyCode = SafeJson.listAt(
      daily,
      'weather_code',
    ).map(_toInt).take(16).toList();

    final dailyPoints = <DailyWeatherPoint>[];
    for (var index = 0; index < dailyTime.length; index++) {
      final date = DateTime.tryParse(dailyTime[index]);
      if (date == null) {
        continue;
      }
      dailyPoints.add(
        DailyWeatherPoint(
          label: _weekdayLabel(date.weekday),
          date: date,
          minTempC: index < dailyMin.length ? dailyMin[index] : 0,
          maxTempC: index < dailyMax.length ? dailyMax[index] : 0,
          rainProbability: index < dailyRain.length ? dailyRain[index] : 0,
          description: _weatherDescription(
            index < dailyCode.length ? dailyCode[index] : 0,
          ),
        ),
      );
    }

    final hourlyTime = SafeJson.listAt(
      hourly,
      'time',
    ).map((item) => item.toString()).take(48).toList();
    final hourlyTemp = SafeJson.listAt(
      hourly,
      'temperature_2m',
    ).map(_toDouble).take(48).toList();
    final hourlyHumidity = SafeJson.listAt(
      hourly,
      'relative_humidity_2m',
    ).map(_toInt).take(48).toList();
    final hourlyRainProbability = SafeJson.listAt(
      hourly,
      'precipitation_probability',
    ).map(_toInt).take(48).toList();
    final hourlyRain = SafeJson.listAt(
      hourly,
      'precipitation',
    ).map(_toDouble).take(48).toList();
    final hourlyWind = SafeJson.listAt(
      hourly,
      'wind_speed_10m',
    ).map(_toDouble).take(48).toList();
    final hourlyWindGustRaw = SafeJson.listAt(hourly, 'wind_gusts_10m');
    final hourlyWindGust = hourlyWindGustRaw.map(_toDouble).toList();
    final hourlyUvRaw = SafeJson.listAt(hourly, 'uv_index');
    final hourlyUv = hourlyUvRaw.map(_toDouble).toList();
    final hourlyVisibilityRaw = SafeJson.listAt(hourly, 'visibility');
    final hourlyVisibility = hourlyVisibilityRaw
        .map((value) => _toDouble(value) / 1000)
        .take(48)
        .toList();
    final hourlyCode = SafeJson.listAt(
      hourly,
      'weather_code',
    ).map(_toInt).take(48).toList();
    final hourlyCloudCover = SafeJson.listAt(
      hourly,
      'cloud_cover',
    ).map(_toInt).take(48).toList();
    final hourlyPressure = SafeJson.listAt(
      hourly,
      'pressure_msl',
    ).map(_toDouble).take(48).toList();
    final hourlyApparent = SafeJson.listAt(
      hourly,
      'apparent_temperature',
    ).map(_toDouble).take(48).toList();
    final currentHourlyIndex = _nearestHourlyIndex(
      hourlyTime,
      currentTime: current['time']?.toString(),
    );

    final hourlyPoints = <HourlyWeatherPoint>[];
    for (var index = 0; index < hourlyTime.length && index < 24; index++) {
      final time = DateTime.tryParse(hourlyTime[index]);
      if (time == null) {
        continue;
      }
      hourlyPoints.add(
        HourlyWeatherPoint(
          label: '${time.hour.toString().padLeft(2, '0')}:00',
          time: time,
          temperatureC: index < hourlyTemp.length ? hourlyTemp[index] : 0,
          humidity: index < hourlyHumidity.length ? hourlyHumidity[index] : 0,
          rainProbability: index < hourlyRainProbability.length
              ? hourlyRainProbability[index]
              : 0,
          precipitationMm: index < hourlyRain.length ? hourlyRain[index] : 0,
          windSpeedKmh: index < hourlyWind.length ? hourlyWind[index] : 0,
          uvIndex: index < hourlyUv.length ? hourlyUv[index] : 0,
          visibilityKm: index < hourlyVisibility.length
              ? hourlyVisibility[index]
              : 0,
        ),
      );
    }

    final temperatureC = _readCurrentDouble(
      current,
      'temperature_2m',
      hourlyTemp,
      currentHourlyIndex,
    );
    final humidity = _readCurrentInt(
      current,
      'relative_humidity_2m',
      hourlyHumidity,
      currentHourlyIndex,
    );
    final windSpeedKmh = _readCurrentDouble(
      current,
      'wind_speed_10m',
      hourlyWind,
      currentHourlyIndex,
    );
    final windGustKmh = _readCurrentDouble(
      current,
      'wind_gusts_10m',
      hourlyWindGust,
      currentHourlyIndex,
    );
    final rainProbability =
        currentHourlyIndex >= 0 &&
            currentHourlyIndex < hourlyRainProbability.length
        ? hourlyRainProbability[currentHourlyIndex]
        : (hourlyPoints.isNotEmpty ? hourlyPoints.first.rainProbability : 0);
    final precipitationMm = _readCurrentDouble(
      current,
      'precipitation',
      hourlyRain,
      currentHourlyIndex,
    );
    final uvIndex = _readCurrentDouble(
      current,
      'uv_index',
      hourlyUv,
      currentHourlyIndex,
    );
    final visibilityKm = _readCurrentDouble(
      current,
      'visibility',
      hourlyVisibility,
      currentHourlyIndex,
      currentScale: 1 / 1000,
    );
    final weatherCode = _readCurrentInt(
      current,
      'weather_code',
      hourlyCode,
      currentHourlyIndex,
      fallback: dailyCode.isNotEmpty ? dailyCode.first : 0,
    );
    final cloudCover = _readCurrentInt(
      current,
      'cloud_cover',
      hourlyCloudCover,
      currentHourlyIndex,
    );
    final pressureHpa = _readCurrentDouble(
      current,
      'pressure_msl',
      hourlyPressure,
      currentHourlyIndex,
    );
    final apparentTemperatureC = _readCurrentDouble(
      current,
      'apparent_temperature',
      hourlyApparent,
      currentHourlyIndex,
      fallback: temperatureC,
    );
    final unavailableMetrics = <String>{
      if (!_hasCurrentValue(current, 'uv_index') &&
          _isUnavailableSeries(hourlyUvRaw))
        'uvIndex',
      if (!_hasCurrentValue(current, 'visibility') &&
          _isUnavailableSeries(hourlyVisibilityRaw))
        'visibility',
    };

    return _ProviderWeather(
      temperatureC: temperatureC,
      description: _weatherDescription(weatherCode),
      humidity: humidity,
      windSpeedKmh: windSpeedKmh,
      windGustKmh: windGustKmh,
      rainProbability: rainProbability,
      precipitationMm: precipitationMm,
      uvIndex: uvIndex,
      visibilityKm: visibilityKm,
      cloudCover: cloudCover,
      pressureHpa: pressureHpa,
      apparentTemperatureC: apparentTemperatureC,
      daily: dailyPoints,
      hourly: hourlyPoints,
      unavailableMetrics: unavailableMetrics,
    );
  }

  Map<String, String> _buildProviderData(_ProviderWeather weather) {
    String unavailableAware(String key, String value) {
      return weather.unavailableMetrics.contains(key) ? 'N/D' : value;
    }

    return <String, String>{
      'temperature': '${weather.temperatureC.toStringAsFixed(1)}°C',
      'humidity': '${weather.humidity}%',
      'rainProbability': '${weather.rainProbability}%',
      'windSpeed': '${weather.windSpeedKmh.toStringAsFixed(1)} km/h',
      'uvIndex': unavailableAware(
        'uvIndex',
        weather.uvIndex.toStringAsFixed(1),
      ),
      'visibility': unavailableAware(
        'visibility',
        '${weather.visibilityKm.toStringAsFixed(1)} km',
      ),
      'pressure': '${weather.pressureHpa.toStringAsFixed(0)} hPa',
      'cloudCover': '${weather.cloudCover}%',
    };
  }

  List<String> _buildAlerts(_ProviderWeather weather) {
    final alerts = <String>[];
    if (weather.rainProbability >= 70) {
      alerts.add('Probabilidad alta de lluvia en las próximas horas.');
    }
    if (weather.windGustKmh >= 30) {
      alerts.add('Ráfagas elevadas; protege labores de aplicación.');
    }
    if (weather.uvIndex >= 8) {
      alerts.add('Radiación UV alta; evita trabajo prolongado al mediodía.');
    }
    if (weather.visibilityKm > 0 && weather.visibilityKm <= 4) {
      alerts.add('Visibilidad reducida; extrema precaución en campo.');
    }
    if (alerts.isEmpty) {
      alerts.add('Condiciones estables para monitoreo y labores preventivas.');
    }
    return alerts;
  }

  double _toDouble(Object? value) {
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

  int _toInt(Object? value) {
    if (value is num) {
      return value.toInt();
    }
    return 0;
  }

  Map<String, dynamic>? _decodeWeatherResponse(String body) {
    try {
      return SafeJson.object(body, maxBytes: 512000);
    } catch (_) {
      return null;
    }
  }

  bool _isValidCoordinate(
    double value, {
    required double min,
    required double max,
  }) {
    return value.isFinite && value >= min && value <= max;
  }

  bool _hasCurrentValue(Map<String, dynamic> current, String key) {
    return current.containsKey(key) && current[key] != null;
  }

  bool _isUnavailableSeries(List<dynamic> values) {
    return values.isEmpty || values.every((value) => value == null);
  }

  int _nearestHourlyIndex(List<String> hourlyTime, {String? currentTime}) {
    if (hourlyTime.isEmpty) {
      return -1;
    }
    final target = currentTime == null || currentTime.isEmpty
        ? DateTime.now()
        : DateTime.tryParse(currentTime) ?? DateTime.now();
    var bestIndex = 0;
    var bestDifference = Duration(days: 9999);
    for (var index = 0; index < hourlyTime.length; index++) {
      final parsed = DateTime.tryParse(hourlyTime[index]);
      if (parsed == null) {
        continue;
      }
      final difference = parsed.difference(target).abs();
      if (difference < bestDifference) {
        bestDifference = difference;
        bestIndex = index;
      }
    }
    return bestIndex;
  }

  double _readCurrentDouble(
    Map<String, dynamic> current,
    String key,
    List<double> hourlyValues,
    int hourlyIndex, {
    double fallback = 0,
    double currentScale = 1,
  }) {
    if (_hasCurrentValue(current, key)) {
      return _toDouble(current[key]) * currentScale;
    }
    if (hourlyIndex >= 0 && hourlyIndex < hourlyValues.length) {
      return hourlyValues[hourlyIndex];
    }
    return fallback;
  }

  int _readCurrentInt(
    Map<String, dynamic> current,
    String key,
    List<int> hourlyValues,
    int hourlyIndex, {
    int fallback = 0,
  }) {
    if (_hasCurrentValue(current, key)) {
      return _toInt(current[key]);
    }
    if (hourlyIndex >= 0 && hourlyIndex < hourlyValues.length) {
      return hourlyValues[hourlyIndex];
    }
    return fallback;
  }

  String _weatherDescription(int code) {
    switch (code) {
      case 0:
        return 'Despejado';
      case 1:
      case 2:
      case 3:
        return 'Parcialmente nublado';
      case 45:
      case 48:
        return 'Neblina';
      case 51:
      case 53:
      case 55:
      case 61:
      case 63:
      case 65:
      case 80:
      case 81:
      case 82:
        return 'Lluvia';
      case 95:
      case 96:
      case 99:
        return 'Tormenta';
      default:
        return 'Condiciones variables';
    }
  }

  String _weekdayLabel(int weekday) {
    const labels = <int, String>{
      DateTime.monday: 'Lun',
      DateTime.tuesday: 'Mar',
      DateTime.wednesday: 'Mié',
      DateTime.thursday: 'Jue',
      DateTime.friday: 'Vie',
      DateTime.saturday: 'Sáb',
      DateTime.sunday: 'Dom',
    };
    return labels[weekday] ?? '';
  }
}

class WeatherException implements Exception {
  const WeatherException(this.message);

  final String message;
}

class _WeatherProviderConfig {
  const _WeatherProviderConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.reliability,
  });

  final String id;
  final String name;
  final String description;
  final int reliability;
}

class _ProviderFetchResult {
  const _ProviderFetchResult({
    required this.config,
    this.snapshot,
    this.errorMessage,
  });

  final _WeatherProviderConfig config;
  final _ProviderWeather? snapshot;
  final String? errorMessage;
}

class _ProviderWeather {
  const _ProviderWeather({
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
    required this.unavailableMetrics,
  });

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
  final Set<String> unavailableMetrics;
}
