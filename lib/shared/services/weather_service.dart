import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/weather_snapshot.dart';

class WeatherService {
  Future<WeatherSnapshot> fetchWeather({
    required double latitude,
    required double longitude,
    required String locationLabel,
  }) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', <
      String,
      String
    >{
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'timezone': 'auto',
      'forecast_days': '7',
      'current':
          'temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m,precipitation_probability,uv_index,soil_temperature_0cm,soil_moisture_0_to_1cm',
      'daily':
          'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max',
    });

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw WeatherException(
        'No fue posible consultar el clima en este momento.',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final current =
        json['current'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final daily = json['daily'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final times = (daily['time'] as List<dynamic>? ?? const <dynamic>[])
        .map((value) => value.toString())
        .toList();
    final minTemps =
        (daily['temperature_2m_min'] as List<dynamic>? ?? const <dynamic>[])
            .map((value) => (value as num).toDouble())
            .toList();
    final maxTemps =
        (daily['temperature_2m_max'] as List<dynamic>? ?? const <dynamic>[])
            .map((value) => (value as num).toDouble())
            .toList();
    final rainValues =
        (daily['precipitation_probability_max'] as List<dynamic>? ??
                const <dynamic>[])
            .map((value) => (value as num).toInt())
            .toList();
    final codes = (daily['weather_code'] as List<dynamic>? ?? const <dynamic>[])
        .map((value) => (value as num).toInt())
        .toList();

    final forecast = <DailyWeatherPoint>[];
    for (var index = 0; index < times.length; index++) {
      forecast.add(
        DailyWeatherPoint(
          label: _weekdayLabel(DateTime.parse(times[index]).weekday),
          minTempC: index < minTemps.length ? minTemps[index] : 0,
          maxTempC: index < maxTemps.length ? maxTemps[index] : 0,
          rainProbability: index < rainValues.length ? rainValues[index] : 0,
          description: _weatherDescription(
            index < codes.length ? codes[index] : 0,
          ),
        ),
      );
    }

    final rainProbability =
        (current['precipitation_probability'] as num?)?.toInt() ??
        (forecast.isNotEmpty ? forecast.first.rainProbability : 0);
    final humidity = (current['relative_humidity_2m'] as num?)?.toInt() ?? 0;
    final windSpeed = (current['wind_speed_10m'] as num?)?.toDouble() ?? 0;
    final uvIndex = (current['uv_index'] as num?)?.toDouble() ?? 0;
    final soilTemperature =
        (current['soil_temperature_0cm'] as num?)?.toDouble() ?? 0;
    final soilMoisture =
        (((current['soil_moisture_0_to_1cm'] as num?)?.toDouble() ?? 0) * 100)
            .round();
    final description = _weatherDescription(
      (current['weather_code'] as num?)?.toInt() ?? 0,
    );

    return WeatherSnapshot(
      locationLabel: locationLabel,
      temperatureC: (current['temperature_2m'] as num?)?.toDouble() ?? 0,
      description: description,
      humidity: humidity,
      windSpeedKmh: windSpeed,
      rainProbability: rainProbability,
      uvIndex: uvIndex,
      soilMoisturePercent: soilMoisture,
      soilTemperatureC: soilTemperature,
      daily: forecast,
      alerts: _buildAlerts(
        rainProbability: rainProbability,
        uvIndex: uvIndex,
        soilMoisturePercent: soilMoisture,
      ),
      updatedAt: DateTime.now(),
    );
  }

  List<String> _buildAlerts({
    required int rainProbability,
    required double uvIndex,
    required int soilMoisturePercent,
  }) {
    final alerts = <String>[];
    if (rainProbability >= 70) {
      alerts.add('Alta probabilidad de lluvia en las próximas horas.');
    }
    if (uvIndex >= 8) {
      alerts.add('Índice UV alto; evita aplicaciones foliares al mediodía.');
    }
    if (soilMoisturePercent <= 20) {
      alerts.add('Humedad del suelo baja; considera revisar riego.');
    }
    if (alerts.isEmpty) {
      alerts.add(
        'Condiciones meteorológicas estables para monitoreo de campo.',
      );
    }
    return alerts;
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
      case 71:
      case 73:
      case 75:
        return 'Granizo o nieve';
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
