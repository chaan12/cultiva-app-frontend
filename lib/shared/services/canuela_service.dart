import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';
import '../models/canuela_forecast.dart';

class CanuelaService {
  static const String _archivePath = '/v1/archive';

  Future<CanuelaReport> fetchCanuelas({
    required double latitude,
    required double longitude,
    required String locationLabel,
    int? year,
  }) async {
    if (!_isValidCoordinate(latitude, min: -90, max: 90) ||
        !_isValidCoordinate(longitude, min: -180, max: 180)) {
      throw const CanuelaException(
        'Coordenadas inválidas para consultar cabañuelas.',
      );
    }

    final selectedYear = year ?? _defaultCanuelaYear(DateTime.now());
    final startDate = '$selectedYear-01-01';
    final endDate = '$selectedYear-01-12';
    final uri = Uri.https(AppConfig.historicalWeatherApiHost, _archivePath, {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'start_date': startDate,
      'end_date': endDate,
      'timezone': 'auto',
      'daily':
          'weather_code,temperature_2m_max,temperature_2m_min,temperature_2m_mean,precipitation_sum',
    });

    try {
      final response = await http.get(uri).timeout(AppConfig.requestTimeout);
      if (response.statusCode != 200) {
        throw CanuelaException(
          'La fuente histórica respondió con HTTP ${response.statusCode}.',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const CanuelaException(
          'La fuente histórica devolvió una respuesta inválida.',
        );
      }
      final json = decoded;
      if ((json['error'] as bool?) ?? false) {
        throw CanuelaException(
          (json['reason'] as String?) ??
              'No fue posible consultar las cabañuelas.',
        );
      }

      return _buildReport(
        json: json,
        locationLabel: locationLabel,
        selectedYear: selectedYear,
      );
    } on CanuelaException {
      rethrow;
    } catch (_) {
      throw const CanuelaException(
        'No fue posible consultar las cabañuelas en este momento.',
      );
    }
  }

  CanuelaReport _buildReport({
    required Map<String, dynamic> json,
    required String locationLabel,
    required int selectedYear,
  }) {
    final daily = json['daily'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final dates = (daily['time'] as List<dynamic>? ?? const <dynamic>[])
        .map((item) => item.toString())
        .toList();
    final maxTemps =
        (daily['temperature_2m_max'] as List<dynamic>? ?? const <dynamic>[])
            .map(_toDouble)
            .toList();
    final minTemps =
        (daily['temperature_2m_min'] as List<dynamic>? ?? const <dynamic>[])
            .map(_toDouble)
            .toList();
    final meanTemps =
        (daily['temperature_2m_mean'] as List<dynamic>? ?? const <dynamic>[])
            .map(_toDouble)
            .toList();
    final precipitation =
        (daily['precipitation_sum'] as List<dynamic>? ?? const <dynamic>[])
            .map(_toDouble)
            .toList();
    final weatherCodes =
        (daily['weather_code'] as List<dynamic>? ?? const <dynamic>[])
            .map(_toInt)
            .toList();

    if (dates.length < 12) {
      throw const CanuelaException(
        'La fuente histórica no devolvió los 12 días necesarios para calcular cabañuelas.',
      );
    }

    final months = <CanuelaMonthForecast>[];
    for (var index = 0; index < 12; index++) {
      final rain = _readAt(precipitation, index);
      final maxTemp = _readAt(maxTemps, index);
      final minTemp = _readAt(minTemps, index);
      final meanTemp = _readAt(
        meanTemps,
        index,
        fallback: (maxTemp + minTemp) / 2,
      );
      final code = _readIntAt(weatherCodes, index);
      months.add(
        CanuelaMonthForecast(
          monthIndex: index + 1,
          monthName: _monthName(index + 1),
          sourceDate: DateTime.parse(dates[index]),
          minTempC: minTemp,
          maxTempC: maxTemp,
          meanTempC: meanTemp,
          precipitationMm: rain,
          weatherCode: code,
          conditionLabel: _weatherDescription(code, rain),
          rainSignal: _rainSignal(rain),
          cropHint: _cropHint(
            rainMm: rain,
            maxTempC: maxTemp,
            minTempC: minTemp,
          ),
        ),
      );
    }

    return CanuelaReport(
      locationLabel: locationLabel,
      year: selectedYear,
      generatedAt: DateTime.now(),
      months: months,
    );
  }

  int _defaultCanuelaYear(DateTime now) {
    final januaryWindowClosed =
        now.month > 1 || (now.month == 1 && now.day > 12);
    return januaryWindowClosed ? now.year : now.year - 1;
  }

  double _readAt(List<double> values, int index, {double fallback = 0}) {
    return index < values.length ? values[index] : fallback;
  }

  int _readIntAt(List<int> values, int index, {int fallback = 0}) {
    return index < values.length ? values[index] : fallback;
  }

  double _toDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }

  int _toInt(Object? value) {
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  bool _isValidCoordinate(
    double value, {
    required double min,
    required double max,
  }) {
    return value.isFinite && value >= min && value <= max;
  }

  String _monthName(int month) {
    const months = <int, String>{
      1: 'Enero',
      2: 'Febrero',
      3: 'Marzo',
      4: 'Abril',
      5: 'Mayo',
      6: 'Junio',
      7: 'Julio',
      8: 'Agosto',
      9: 'Septiembre',
      10: 'Octubre',
      11: 'Noviembre',
      12: 'Diciembre',
    };
    return months[month] ?? '';
  }

  String _rainSignal(double rainMm) {
    if (rainMm >= 20) {
      return 'Lluvias abundantes';
    }
    if (rainMm >= 8) {
      return 'Lluvias frecuentes';
    }
    if (rainMm >= 1) {
      return 'Lluvias aisladas';
    }
    return 'Poca lluvia';
  }

  String _weatherDescription(int code, double rainMm) {
    if (rainMm >= 20) {
      return 'Lluvia marcada';
    }
    if (rainMm >= 8) {
      return 'Lluvioso';
    }
    switch (code) {
      case 0:
        return 'Despejado';
      case 1:
      case 2:
      case 3:
        return 'Variable';
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
        return 'Sin señal fuerte';
    }
  }

  String _cropHint({
    required double rainMm,
    required double maxTempC,
    required double minTempC,
  }) {
    if (rainMm >= 20) {
      return 'Conviene preparar salidas de agua y revisar que el cultivo no se quede encharcado.';
    }
    if (rainMm <= 0.2 && maxTempC >= 34) {
      return 'Puede ser un mes con poca lluvia y calor: planea riegos y protege el suelo del sol directo.';
    }
    if (maxTempC >= 35) {
      return 'Puede sentirse muy caluroso: cuida que las plantas no pasen sed en días fuertes.';
    }
    if (minTempC <= 8) {
      return 'Puede sentirse fresco: protege plantas delicadas durante las mañanas frías.';
    }
    if (rainMm >= 8) {
      return 'Puede haber buena lluvia: aprovecha para sembrar, pero vigila maleza y exceso de agua.';
    }
    return 'Se ve estable: mantén riegos normales y revisa el cultivo con frecuencia.';
  }
}

class CanuelaException implements Exception {
  const CanuelaException(this.message);

  final String message;
}
