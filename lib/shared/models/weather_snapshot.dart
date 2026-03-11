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
  });

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

class HourlyWeatherPoint {
  const HourlyWeatherPoint({
    required this.label,
    required this.temperatureC,
    required this.humidity,
    required this.rainProbability,
    required this.precipitationMm,
    required this.windSpeedKmh,
    required this.uvIndex,
    required this.visibilityKm,
  });

  final String label;
  final double temperatureC;
  final int humidity;
  final int rainProbability;
  final double precipitationMm;
  final double windSpeedKmh;
  final double uvIndex;
  final double visibilityKm;
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

  final String id;
  final String name;
  final String description;
  final int reliability;
  final bool available;
  final Map<String, String> data;
  final List<String> alerts;
}
