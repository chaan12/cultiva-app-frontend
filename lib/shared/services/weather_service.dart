import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/weather_snapshot.dart';

class WeatherService {
  static const List<_WeatherProviderConfig> _providers =
      <_WeatherProviderConfig>[
        _WeatherProviderConfig(
          id: 'noaa_gfs',
          name: 'NOAA GFS',
          description: 'Global Forecast System de NOAA',
          endpointPath: '/v1/gfs',
          reliability: 95,
        ),
        _WeatherProviderConfig(
          id: 'ecmwf',
          name: 'ECMWF',
          description: 'Centro Europeo de Pronóstico de Mediano Plazo',
          endpointPath: '/v1/ecmwf',
          reliability: 94,
        ),
        _WeatherProviderConfig(
          id: 'gem',
          name: 'GEM Canada',
          description: 'Modelo global del servicio meteorológico canadiense',
          endpointPath: '/v1/gem',
          reliability: 90,
        ),
        _WeatherProviderConfig(
          id: 'meteofrance',
          name: 'Meteo-France',
          description: 'Modelo global de Meteo-France',
          endpointPath: '/v1/meteofrance',
          reliability: 88,
        ),
        _WeatherProviderConfig(
          id: 'jma',
          name: 'JMA GSM',
          description: 'Modelo global de la Agencia Meteorológica de Japón',
          endpointPath: '/v1/jma',
          reliability: 84,
        ),
      ];

  Future<WeatherSnapshot> fetchWeather({
    required double latitude,
    required double longitude,
    required String locationLabel,
  }) async {
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
                  : <String, String>{
                      'temperature':
                          '${provider.snapshot!.temperatureC.toStringAsFixed(1)}°C',
                      'humidity': '${provider.snapshot!.humidity}%',
                      'rainProbability':
                          '${provider.snapshot!.rainProbability}%',
                      'windSpeed':
                          '${provider.snapshot!.windSpeedKmh.toStringAsFixed(1)} km/h',
                      'uvIndex': provider.snapshot!.uvIndex.toStringAsFixed(1),
                      'visibility':
                          '${provider.snapshot!.visibilityKm.toStringAsFixed(1)} km',
                      'pressure':
                          '${provider.snapshot!.pressureHpa.toStringAsFixed(0)} hPa',
                      'cloudCover': '${provider.snapshot!.cloudCover}%',
                    },
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
    final uri = Uri.https('api.open-meteo.com', provider.endpointPath, <
      String,
      String
    >{
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'timezone': 'auto',
      'forecast_days': '16',
      'current':
          'temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,cloud_cover,pressure_msl,wind_speed_10m,wind_gusts_10m,visibility,uv_index',
      'hourly':
          'temperature_2m,relative_humidity_2m,precipitation_probability,precipitation,wind_speed_10m,uv_index,visibility',
      'daily':
          'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max',
    });

    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        return _ProviderFetchResult(
          config: provider,
          errorMessage: 'HTTP ${response.statusCode}',
        );
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if ((json['error'] as bool?) ?? false) {
        return _ProviderFetchResult(
          config: provider,
          errorMessage: (json['reason'] as String?) ?? 'Sin datos',
        );
      }
      return _ProviderFetchResult(
        config: provider,
        snapshot: _parseProviderWeather(json),
      );
    } catch (error) {
      return _ProviderFetchResult(
        config: provider,
        errorMessage: error.toString(),
      );
    }
  }

  _ProviderWeather _parseProviderWeather(Map<String, dynamic> json) {
    final current =
        json['current'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final daily = json['daily'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final hourly =
        json['hourly'] as Map<String, dynamic>? ?? <String, dynamic>{};

    final dailyTime = (daily['time'] as List<dynamic>? ?? const <dynamic>[])
        .map((item) => item.toString())
        .toList();
    final dailyMin =
        (daily['temperature_2m_min'] as List<dynamic>? ?? const <dynamic>[])
            .map(_toDouble)
            .toList();
    final dailyMax =
        (daily['temperature_2m_max'] as List<dynamic>? ?? const <dynamic>[])
            .map(_toDouble)
            .toList();
    final dailyRain =
        (daily['precipitation_probability_max'] as List<dynamic>? ??
                const <dynamic>[])
            .map(_toInt)
            .toList();
    final dailyCode =
        (daily['weather_code'] as List<dynamic>? ?? const <dynamic>[])
            .map(_toInt)
            .toList();

    final dailyPoints = <DailyWeatherPoint>[];
    for (var index = 0; index < dailyTime.length; index++) {
      dailyPoints.add(
        DailyWeatherPoint(
          label: _weekdayLabel(DateTime.parse(dailyTime[index]).weekday),
          date: DateTime.parse(dailyTime[index]),
          minTempC: index < dailyMin.length ? dailyMin[index] : 0,
          maxTempC: index < dailyMax.length ? dailyMax[index] : 0,
          rainProbability: index < dailyRain.length ? dailyRain[index] : 0,
          description: _weatherDescription(
            index < dailyCode.length ? dailyCode[index] : 0,
          ),
        ),
      );
    }

    final hourlyTime = (hourly['time'] as List<dynamic>? ?? const <dynamic>[])
        .map((item) => item.toString())
        .toList();
    final hourlyTemp =
        (hourly['temperature_2m'] as List<dynamic>? ?? const <dynamic>[])
            .map(_toDouble)
            .toList();
    final hourlyHumidity =
        (hourly['relative_humidity_2m'] as List<dynamic>? ?? const <dynamic>[])
            .map(_toInt)
            .toList();
    final hourlyRainProbability =
        (hourly['precipitation_probability'] as List<dynamic>? ??
                const <dynamic>[])
            .map(_toInt)
            .toList();
    final hourlyRain =
        (hourly['precipitation'] as List<dynamic>? ?? const <dynamic>[])
            .map(_toDouble)
            .toList();
    final hourlyWind =
        (hourly['wind_speed_10m'] as List<dynamic>? ?? const <dynamic>[])
            .map(_toDouble)
            .toList();
    final hourlyUv = (hourly['uv_index'] as List<dynamic>? ?? const <dynamic>[])
        .map(_toDouble)
        .toList();
    final hourlyVisibility =
        (hourly['visibility'] as List<dynamic>? ?? const <dynamic>[])
            .map((value) => _toDouble(value) / 1000)
            .toList();

    final hourlyPoints = <HourlyWeatherPoint>[];
    for (var index = 0; index < hourlyTime.length && index < 24; index++) {
      final time = DateTime.parse(hourlyTime[index]);
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

    return _ProviderWeather(
      temperatureC: _toDouble(current['temperature_2m']),
      description: _weatherDescription(_toInt(current['weather_code'])),
      humidity: _toInt(current['relative_humidity_2m']),
      windSpeedKmh: _toDouble(current['wind_speed_10m']),
      windGustKmh: _toDouble(current['wind_gusts_10m']),
      rainProbability: hourlyPoints.isNotEmpty
          ? hourlyPoints.first.rainProbability
          : 0,
      precipitationMm: _toDouble(current['precipitation']),
      uvIndex: _toDouble(current['uv_index']),
      visibilityKm: _toDouble(current['visibility']) / 1000,
      cloudCover: _toInt(current['cloud_cover']),
      pressureHpa: _toDouble(current['pressure_msl']),
      apparentTemperatureC: _toDouble(current['apparent_temperature']),
      daily: dailyPoints,
      hourly: hourlyPoints,
    );
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
      return value.toDouble();
    }
    return 0;
  }

  int _toInt(Object? value) {
    if (value is num) {
      return value.toInt();
    }
    return 0;
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
    required this.endpointPath,
    required this.reliability,
  });

  final String id;
  final String name;
  final String description;
  final String endpointPath;
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
}
