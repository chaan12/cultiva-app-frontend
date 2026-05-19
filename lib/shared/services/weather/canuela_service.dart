import 'package:http/http.dart' as http;
import '../../../core/config/app_config.dart';
import '../../models/canuela_forecast.dart';
import '../../security/safe_json.dart';

class CanuelaService {
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

    final selectedYear = (year ?? _defaultCanuelaYear(DateTime.now())).clamp(
      1940,
      DateTime.now().year,
    );
    final startDate = '$selectedYear-01-01';
    final endDate = '$selectedYear-01-12';
    try {
      final queryParameters = <String, String>{
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'start_date': startDate,
        'end_date': endDate,
        'timezone': 'auto',
        'daily':
            'weather_code,temperature_2m_max,temperature_2m_min,temperature_2m_mean,precipitation_sum',
      };
      final apiKey = AppConfig.weatherApiKey;
      if (apiKey != null) {
        queryParameters['apikey'] = apiKey;
      }
      final uri = Uri.https(
        AppConfig.historicalWeatherApiHost,
        AppConfig.canuelaArchivePath,
        queryParameters,
      );
      final response = await http.get(uri).timeout(AppConfig.requestTimeout);
      if (response.statusCode != 200) {
        throw const CanuelaException(
          'No fue posible consultar las cabañuelas en este momento.',
        );
      }

      final decoded = _decodeCanuelaResponse(response.body);
      if (decoded == null) {
        throw const CanuelaException(
          'La fuente histórica devolvió una respuesta inválida.',
        );
      }
      final json = decoded;
      if ((json['error'] as bool?) ?? false) {
        throw const CanuelaException(
          'No fue posible consultar las cabañuelas en este momento.',
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
    final daily = SafeJson.mapAt(json, 'daily') ?? <String, dynamic>{};
    final dates = SafeJson.listAt(
      daily,
      'time',
    ).map((item) => item.toString()).take(12).toList();
    final maxTemps = SafeJson.listAt(
      daily,
      'temperature_2m_max',
    ).map(_toDouble).take(12).toList();
    final minTemps = SafeJson.listAt(
      daily,
      'temperature_2m_min',
    ).map(_toDouble).take(12).toList();
    final meanTemps = SafeJson.listAt(
      daily,
      'temperature_2m_mean',
    ).map(_toDouble).take(12).toList();
    final precipitation = SafeJson.listAt(
      daily,
      'precipitation_sum',
    ).map(_toDouble).take(12).toList();
    final weatherCodes = SafeJson.listAt(
      daily,
      'weather_code',
    ).map(_toInt).take(12).toList();

    if (dates.length < 12) {
      throw const CanuelaException(
        'La fuente histórica no devolvió los 12 días necesarios para calcular cabañuelas.',
      );
    }

    final months = <CanuelaMonthForecast>[];
    final interpreter = _ClimateInterpreter();

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
      final sourceDate = DateTime.tryParse(dates[index]);
      if (sourceDate == null) {
        throw const CanuelaException(
          'La fuente histórica devolvió una respuesta inválida.',
        );
      }

      // Interpretar clima tradicional
      final analysis = interpreter.analyze(
        rainMm: rain,
        maxTemp: maxTemp,
        minTemp: minTemp,
        meanTemp: meanTemp,
        code: code,
      );

      months.add(
        CanuelaMonthForecast(
          monthIndex: index + 1,
          monthName: _monthName(index + 1),
          sourceDate: sourceDate,
          minTempC: minTemp,
          maxTempC: maxTemp,
          meanTempC: meanTemp,
          precipitationMm: rain,
          weatherCode: code,
          conditionLabel: analysis.condition,
          rainSignal: analysis.rainSignal,
          cropHint: analysis.cropHint,
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
    // Si estamos antes o durante el 12 de enero, usamos el año pasado
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
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
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

  Map<String, dynamic>? _decodeCanuelaResponse(String body) {
    try {
      return SafeJson.object(body, maxBytes: 256000);
    } catch (_) {
      return null;
    }
  }
}

/// Intérprete de señales climáticas tradicionales
class _ClimateInterpreter {
  _Interpretation analyze({
    required double rainMm,
    required double maxTemp,
    required double minTemp,
    required double meanTemp,
    required int code,
  }) {
    // 1. Scoring de humedad y lluvia
    double rainScore = rainMm * 0.5;
    if (code >= 51) rainScore += 2; // Señal de lluvia en el código
    if (code >= 95) rainScore += 3; // Tormentas

    // 2. Scoring de calor/frío
    bool isHot = maxTemp >= 30;
    bool isExtremeHot = maxTemp >= 35;
    bool isCool = minTemp <= 12;
    bool isCold = minTemp <= 6;

    // 3. Inferencia de ambiente (bochorno, seco, etc.)
    bool isMuggy = meanTemp > 24 && rainScore > 1.5;
    bool isDryHeat = isHot && rainScore < 0.5;
    bool isRestless =
        code >= 1 && code <= 3 || code >= 95; // Tiempo revuelto/inestable

    // 4. Determinar Señal de Agua
    String rainSignal;
    if (rainScore >= 8) {
      rainSignal = 'Agua buena para la tierra';
    } else if (rainScore >= 4) {
      rainSignal = 'Lluvias que entran y salen';
    } else if (rainScore >= 1) {
      rainSignal = 'Señales de agua pasajera';
    } else if (isRestless) {
      rainSignal = 'Cielo movido, poca agua';
    } else {
      rainSignal = 'Poca señal de agua';
    }

    // 5. Determinar Ambiente (Condition)
    String condition;
    if (isMuggy) {
      condition = 'Ambiente con bochorno';
    } else if (isDryHeat) {
      condition = 'Calor dominante y seco';
    } else if (isExtremeHot) {
      condition = 'Días de mucho calor';
    } else if (isCold) {
      condition = 'Mes de mucho frío y aire';
    } else if (isCool) {
      condition = 'Se espera un ambiente fresco';
    } else if (isRestless && rainScore < 2) {
      condition = 'Tiempo revuelto y variable';
    } else if (rainScore >= 5) {
      condition = 'Días húmedos y con nubes';
    } else {
      condition = 'Tiempo estable y tranquilo';
    }

    // 6. Generar Consejo (Crop Hint)
    String hint;
    if (rainScore >= 10) {
      hint =
          'Vienen lluvias fuertes: cuidado con los encharques y cuida que las raices no sufran por tanta humedad.';
    } else if (rainScore >= 4) {
      hint =
          'Mes de buena humedad: aprovecha para sembrar lo que necesita agua, pero cuidado con la maleza creciente.';
    } else if (isDryHeat || isExtremeHot) {
      hint =
          'Se esperan días con calor muy fuerte. Riega las plantas frecuentemente y vigila que no se marchiten.';
    } else if (isCold || isCool) {
      hint =
          'Días frescos: cuida las plantas más débiles y aquellas que necesitan calor.';
    } else if (isRestless) {
      hint =
          'El tiempo será muy variable, vigila el viento y otras señales meteorológicas.';
    } else if (rainScore < 1) {
      hint =
          'Mes sin muchas lluvias: es buen tiempo para preparar la tierra y limpiar, pero no descuides el riego.';
    } else {
      hint = 'Se ve buen tiempo para el campo: mantén tus labores normales.';
    }

    return _Interpretation(
      condition: condition,
      rainSignal: rainSignal,
      cropHint: hint,
    );
  }
}

class _Interpretation {
  const _Interpretation({
    required this.condition,
    required this.rainSignal,
    required this.cropHint,
  });

  final String condition;
  final String rainSignal;
  final String cropHint;
}

class CanuelaException implements Exception {
  const CanuelaException(this.message);
  final String message;
}
