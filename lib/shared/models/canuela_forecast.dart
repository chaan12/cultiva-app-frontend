class CanuelaReport {
  const CanuelaReport({
    required this.locationLabel,
    required this.year,
    required this.generatedAt,
    required this.months,
  });

  final String locationLabel;
  final int year;
  final DateTime generatedAt;
  final List<CanuelaMonthForecast> months;

  double get averageTemperatureC {
    if (months.isEmpty) {
      return 0;
    }
    final total = months.fold<double>(0, (sum, month) => sum + month.meanTempC);
    return total / months.length;
  }

  CanuelaMonthForecast? get wettestMonth {
    if (months.isEmpty) {
      return null;
    }
    return months.reduce(
      (current, next) =>
          next.precipitationMm > current.precipitationMm ? next : current,
    );
  }

  CanuelaMonthForecast? get driestMonth {
    if (months.isEmpty) {
      return null;
    }
    return months.reduce(
      (current, next) =>
          next.precipitationMm < current.precipitationMm ? next : current,
    );
  }
}

class CanuelaMonthForecast {
  const CanuelaMonthForecast({
    required this.monthIndex,
    required this.monthName,
    required this.sourceDate,
    required this.minTempC,
    required this.maxTempC,
    required this.meanTempC,
    required this.precipitationMm,
    required this.weatherCode,
    required this.conditionLabel,
    required this.rainSignal,
    required this.cropHint,
  });

  final int monthIndex;
  final String monthName;
  final DateTime sourceDate;
  final double minTempC;
  final double maxTempC;
  final double meanTempC;
  final double precipitationMm;
  final int weatherCode;
  final String conditionLabel;
  final String rainSignal;
  final String cropHint;
}
