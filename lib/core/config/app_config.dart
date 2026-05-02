class AppConfig {
  const AppConfig._();

  static const weatherApiHost = String.fromEnvironment(
    'CULTIVA_WEATHER_API_HOST',
    defaultValue: 'api.open-meteo.com',
  );

  static const historicalWeatherApiHost = String.fromEnvironment(
    'CULTIVA_HISTORICAL_WEATHER_API_HOST',
    defaultValue: 'archive-api.open-meteo.com',
  );

  static const requestTimeout = Duration(
    seconds: int.fromEnvironment(
      'CULTIVA_HTTP_TIMEOUT_SECONDS',
      defaultValue: 12,
    ),
  );
}
