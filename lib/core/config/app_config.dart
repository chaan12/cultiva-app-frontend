import 'env_service.dart';

enum AppEnvironment {
  development,
  staging,
  production;

  static AppEnvironment parse(String value) {
    return switch (value.trim().toLowerCase()) {
      'production' || 'prod' => AppEnvironment.production,
      'staging' || 'stage' => AppEnvironment.staging,
      _ => AppEnvironment.development,
    };
  }
}

class AppConfig {
  const AppConfig._();

  static final EnvService _env = EnvService.instance;

  static AppEnvironment get environment {
    return AppEnvironment.parse(_env.requiredString(_Keys.environment));
  }

  static bool get isProduction => environment == AppEnvironment.production;

  static String get weatherApiHost {
    return _sanitizeHost(
      _env.requiredString(_Keys.weatherApiHost),
      key: _Keys.weatherApiHost,
    );
  }

  static String get historicalWeatherApiHost {
    return _sanitizeHost(
      _env.requiredString(_Keys.historicalWeatherApiHost),
      key: _Keys.historicalWeatherApiHost,
    );
  }

  static Duration get requestTimeout {
    return Duration(
      seconds: _env
          .requiredInt(_Keys.httpTimeoutSeconds)
          .clamp(_Limits.minTimeoutSeconds, _Limits.maxTimeoutSeconds),
    );
  }

  static String weatherProviderEndpoint(String providerId) {
    final key = switch (providerId) {
      'noaa_gfs' => _Keys.weatherEndpointNoaaGfs,
      'ecmwf' => _Keys.weatherEndpointEcmwf,
      'gem' => _Keys.weatherEndpointGem,
      'meteofrance' => _Keys.weatherEndpointMeteoFrance,
      'jma' => _Keys.weatherEndpointJma,
      _ => throw EnvConfigException.invalid('CULTIVA_WEATHER_ENDPOINT'),
    };
    return _sanitizePath(_env.requiredString(key), key: key);
  }

  static String get canuelaArchivePath {
    return _sanitizePath(
      _env.requiredString(_Keys.canuelaArchivePath),
      key: _Keys.canuelaArchivePath,
    );
  }

  static String get mapsHost {
    return _sanitizeHost(
      _env.requiredString(_Keys.mapsHost),
      key: _Keys.mapsHost,
    );
  }

  static String get mapsSearchPath {
    return _sanitizePath(
      _env.requiredString(_Keys.mapsSearchPath),
      key: _Keys.mapsSearchPath,
    );
  }

  static String get mapsDirectionsPath {
    return _sanitizePath(
      _env.requiredString(_Keys.mapsDirectionsPath),
      key: _Keys.mapsDirectionsPath,
    );
  }

  static String? get weatherApiKey {
    return _sanitizeOptionalSecret(_env.optionalString(_Keys.weatherApiKey));
  }

  static String? get mapsApiKey {
    return _sanitizeOptionalSecret(_env.optionalString(_Keys.mapsApiKey));
  }

  static String? get analyticsKey {
    return _sanitizeOptionalSecret(_env.optionalString(_Keys.analyticsKey));
  }

  static List<String> validate() {
    final missingOrInvalid = <String>[];
    for (final key in _Keys.required) {
      try {
        _env.requiredString(key);
      } catch (_) {
        missingOrInvalid.add(key);
      }
    }

    final checks = <void Function()>[
      () => environment,
      () => weatherApiHost,
      () => historicalWeatherApiHost,
      () => requestTimeout,
      () => weatherProviderEndpoint('noaa_gfs'),
      () => weatherProviderEndpoint('ecmwf'),
      () => weatherProviderEndpoint('gem'),
      () => weatherProviderEndpoint('meteofrance'),
      () => weatherProviderEndpoint('jma'),
      () => canuelaArchivePath,
      () => mapsHost,
      () => mapsSearchPath,
      () => mapsDirectionsPath,
    ];

    for (final check in checks) {
      try {
        check();
      } catch (error) {
        final message = error.toString();
        final key = _Keys.required.firstWhere(
          message.contains,
          orElse: () => 'CONFIGURACION',
        );
        if (!missingOrInvalid.contains(key)) {
          missingOrInvalid.add(key);
        }
      }
    }

    return List<String>.unmodifiable(missingOrInvalid);
  }

  static String _sanitizeHost(String value, {required String key}) {
    final trimmed = value.trim().toLowerCase();
    if (_isSafeHost(trimmed)) {
      return trimmed;
    }
    throw EnvConfigException.invalid(key);
  }

  static String _sanitizePath(String value, {required String key}) {
    final trimmed = value.trim();
    if (trimmed.startsWith('/') &&
        !trimmed.contains('..') &&
        !trimmed.contains('\\') &&
        trimmed.length <= _Limits.maxPathLength) {
      return trimmed;
    }
    throw EnvConfigException.invalid(key);
  }

  static String? _sanitizeOptionalSecret(String? value) {
    if (value == null) {
      return null;
    }
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.length > _Limits.maxSecretLength) {
      return null;
    }
    return trimmed;
  }

  static bool _isSafeHost(String value) {
    if (value.isEmpty ||
        !value.contains('.') ||
        value.startsWith('.') ||
        value.endsWith('.') ||
        value.contains('..') ||
        value.length > _Limits.maxHostLength) {
      return false;
    }
    for (var index = 0; index < value.length; index++) {
      final code = value.codeUnitAt(index);
      final isLowercaseLetter = code >= 97 && code <= 122;
      final isDigit = code >= 48 && code <= 57;
      final isSeparator = code == 45 || code == 46;
      if (!isLowercaseLetter && !isDigit && !isSeparator) {
        return false;
      }
    }
    return true;
  }
}

class _Keys {
  const _Keys._();

  static const environment = 'CULTIVA_ENV';
  static const weatherApiHost = 'CULTIVA_WEATHER_API_HOST';
  static const historicalWeatherApiHost = 'CULTIVA_HISTORICAL_WEATHER_API_HOST';
  static const httpTimeoutSeconds = 'CULTIVA_HTTP_TIMEOUT_SECONDS';
  static const weatherEndpointNoaaGfs = 'CULTIVA_WEATHER_ENDPOINT_NOAA_GFS';
  static const weatherEndpointEcmwf = 'CULTIVA_WEATHER_ENDPOINT_ECMWF';
  static const weatherEndpointGem = 'CULTIVA_WEATHER_ENDPOINT_GEM';
  static const weatherEndpointMeteoFrance =
      'CULTIVA_WEATHER_ENDPOINT_METEOFRANCE';
  static const weatherEndpointJma = 'CULTIVA_WEATHER_ENDPOINT_JMA';
  static const canuelaArchivePath = 'CULTIVA_CANUELA_ARCHIVE_PATH';
  static const mapsHost = 'CULTIVA_MAPS_HOST';
  static const mapsSearchPath = 'CULTIVA_MAPS_SEARCH_PATH';
  static const mapsDirectionsPath = 'CULTIVA_MAPS_DIRECTIONS_PATH';
  static const weatherApiKey = 'CULTIVA_WEATHER_API_KEY';
  static const mapsApiKey = 'CULTIVA_MAPS_API_KEY';
  static const analyticsKey = 'CULTIVA_ANALYTICS_KEY';

  static const required = <String>[
    environment,
    weatherApiHost,
    historicalWeatherApiHost,
    httpTimeoutSeconds,
    weatherEndpointNoaaGfs,
    weatherEndpointEcmwf,
    weatherEndpointGem,
    weatherEndpointMeteoFrance,
    weatherEndpointJma,
    canuelaArchivePath,
    mapsHost,
    mapsSearchPath,
    mapsDirectionsPath,
  ];
}

class _Limits {
  const _Limits._();

  static const minTimeoutSeconds = 3;
  static const maxTimeoutSeconds = 30;
  static const maxHostLength = 120;
  static const maxPathLength = 120;
  static const maxSecretLength = 512;
}
