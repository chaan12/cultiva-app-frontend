class WeatherSnapshot {
  const WeatherSnapshot({
    required this.locationLabel,
    required this.temperatureC,
    required this.description,
    required this.humidity,
    required this.windSpeedKmh,
    required this.rainProbability,
    required this.uvIndex,
    required this.soilMoisturePercent,
    required this.soilTemperatureC,
    required this.daily,
    required this.alerts,
    required this.updatedAt,
  });

  final String locationLabel;
  final double temperatureC;
  final String description;
  final int humidity;
  final double windSpeedKmh;
  final int rainProbability;
  final double uvIndex;
  final int soilMoisturePercent;
  final double soilTemperatureC;
  final List<DailyWeatherPoint> daily;
  final List<String> alerts;
  final DateTime updatedAt;
}

class DailyWeatherPoint {
  const DailyWeatherPoint({
    required this.label,
    required this.minTempC,
    required this.maxTempC,
    required this.rainProbability,
    required this.description,
  });

  final String label;
  final double minTempC;
  final double maxTempC;
  final int rainProbability;
  final String description;
}
