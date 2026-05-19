import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvService {
  EnvService._();

  static const fileName = '.env';
  static final EnvService instance = EnvService._();

  bool _loaded = false;

  bool get isLoaded => _loaded;

  Future<void> load() async {
    if (_loaded) {
      return;
    }
    await dotenv.load(
      fileName: fileName,
      isOptional: true,
      mergeWith: _dartDefineOverrides,
    );
    _loaded = true;
  }

  String? optionalString(String key) {
    if (!_loaded || !dotenv.isInitialized) {
      return null;
    }
    final value = dotenv.maybeGet(key)?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  String requiredString(String key) {
    final value = optionalString(key);
    if (value == null) {
      throw EnvConfigException.missing(key);
    }
    return value;
  }

  int requiredInt(String key) {
    final value = requiredString(key);
    final parsed = int.tryParse(value);
    if (parsed == null) {
      throw EnvConfigException.invalid(key);
    }
    return parsed;
  }

  static Map<String, String> get _dartDefineOverrides {
    return <String, String>{
      for (final entry in _knownDartDefines.entries)
        if (entry.value.isNotEmpty) entry.key: entry.value,
    };
  }

  static const Map<String, String> _knownDartDefines = <String, String>{
    'CULTIVA_ENV': String.fromEnvironment('CULTIVA_ENV'),
    'CULTIVA_WEATHER_API_HOST': String.fromEnvironment(
      'CULTIVA_WEATHER_API_HOST',
    ),
    'CULTIVA_HISTORICAL_WEATHER_API_HOST': String.fromEnvironment(
      'CULTIVA_HISTORICAL_WEATHER_API_HOST',
    ),
    'CULTIVA_HTTP_TIMEOUT_SECONDS': String.fromEnvironment(
      'CULTIVA_HTTP_TIMEOUT_SECONDS',
    ),
    'CULTIVA_WEATHER_ENDPOINT_NOAA_GFS': String.fromEnvironment(
      'CULTIVA_WEATHER_ENDPOINT_NOAA_GFS',
    ),
    'CULTIVA_WEATHER_ENDPOINT_ECMWF': String.fromEnvironment(
      'CULTIVA_WEATHER_ENDPOINT_ECMWF',
    ),
    'CULTIVA_WEATHER_ENDPOINT_GEM': String.fromEnvironment(
      'CULTIVA_WEATHER_ENDPOINT_GEM',
    ),
    'CULTIVA_WEATHER_ENDPOINT_METEOFRANCE': String.fromEnvironment(
      'CULTIVA_WEATHER_ENDPOINT_METEOFRANCE',
    ),
    'CULTIVA_WEATHER_ENDPOINT_JMA': String.fromEnvironment(
      'CULTIVA_WEATHER_ENDPOINT_JMA',
    ),
    'CULTIVA_CANUELA_ARCHIVE_PATH': String.fromEnvironment(
      'CULTIVA_CANUELA_ARCHIVE_PATH',
    ),
    'CULTIVA_MAPS_HOST': String.fromEnvironment('CULTIVA_MAPS_HOST'),
    'CULTIVA_MAPS_SEARCH_PATH': String.fromEnvironment(
      'CULTIVA_MAPS_SEARCH_PATH',
    ),
    'CULTIVA_MAPS_DIRECTIONS_PATH': String.fromEnvironment(
      'CULTIVA_MAPS_DIRECTIONS_PATH',
    ),
    'CULTIVA_WEATHER_API_KEY': String.fromEnvironment(
      'CULTIVA_WEATHER_API_KEY',
    ),
    'CULTIVA_MAPS_API_KEY': String.fromEnvironment('CULTIVA_MAPS_API_KEY'),
    'CULTIVA_ANALYTICS_KEY': String.fromEnvironment('CULTIVA_ANALYTICS_KEY'),
  };
}

class EnvConfigException implements Exception {
  const EnvConfigException(this.message);

  factory EnvConfigException.missing(String key) {
    return EnvConfigException('Falta configurar la variable $key.');
  }

  factory EnvConfigException.invalid(String key) {
    return EnvConfigException('La variable $key tiene un formato inválido.');
  }

  final String message;

  @override
  String toString() => message;
}
