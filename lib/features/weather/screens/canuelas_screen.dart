import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/models/canuela_forecast.dart';
import '../../../shared/services/canuela_service.dart';
import '../../../shared/state/app_scope.dart';

class CanuelasScreen extends StatefulWidget {
  const CanuelasScreen({super.key});

  @override
  State<CanuelasScreen> createState() => _CanuelasScreenState();
}

class _CanuelasScreenState extends State<CanuelasScreen> {
  final CanuelaService _service = CanuelaService();
  Future<CanuelaReport>? _future;
  String? _locationLabel;
  double? _latitude;
  double? _longitude;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_future != null) {
      return;
    }
    final store = AppScope.of(context);
    _locationLabel = store.settings.locationName;
    _latitude = store.settings.latitude;
    _longitude = store.settings.longitude;
    _future = _load();
  }

  Future<CanuelaReport> _load() async {
    final latitude = _latitude;
    final longitude = _longitude;
    if (latitude == null || longitude == null) {
      throw const CanuelaException(
        'Configura una ubicación con coordenadas antes de consultar cabañuelas.',
      );
    }
    return _service.fetchCanuelas(
      latitude: latitude,
      longitude: longitude,
      locationLabel: _locationLabel ?? 'Ubicación actual',
    );
  }

  Future<void> _refresh() async {
    final future = _load();
    setState(() {
      _future = future;
    });
    try {
      await future;
    } catch (_) {
      // FutureBuilder renders the error state.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1E6),
      body: SafeArea(
        child: FutureBuilder<CanuelaReport>(
          future: _future,
          builder: (context, snapshot) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildHeader(snapshot.data),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
                    child: _buildBody(snapshot),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(CanuelaReport? report) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF174C35), Color(0xFF337C55), Color(0xFFD69A2D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(34)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                tooltip: 'Regresar',
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      report?.sourceName ?? CanuelaService.sourceName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Cabañuelas',
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            report == null
                ? _locationLabel ?? 'Ubicación seleccionada'
                : '${report.locationLabel} · ${report.year}',
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 20),
          const _DisclaimerCard(),
        ],
      ),
    );
  }

  Widget _buildBody(AsyncSnapshot<CanuelaReport> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Padding(
        padding: EdgeInsets.only(top: 56),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (snapshot.hasError) {
      return _ErrorState(
        message: _errorMessage(snapshot.error),
        onRetry: _refresh,
      );
    }

    final report = snapshot.data;
    if (report == null) {
      return _ErrorState(
        message: 'No hay datos de cañuelas disponibles.',
        onRetry: _refresh,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSummary(report),
        const SizedBox(height: 20),
        _YearSignalMap(report: report),
        const SizedBox(height: 20),
        const Text(
          'Detalle por mes',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
        const SizedBox(height: 4),
        const Text(
          'Una lectura sencilla de cómo podría verse cada mes.',
          style: TextStyle(color: Colors.black54, height: 1.35),
        ),
        const SizedBox(height: 12),
        ...report.months.map(
          (month) => _MonthCard(
            month: month,
            maxRainMm: _maxPrecipitation(report.months),
          ),
        ),
      ],
    );
  }

  double _maxPrecipitation(List<CanuelaMonthForecast> months) {
    if (months.isEmpty) {
      return 1;
    }
    final maxRain = months.fold<double>(
      0,
      (current, month) =>
          month.precipitationMm > current ? month.precipitationMm : current,
    );
    return maxRain <= 0 ? 1 : maxRain;
  }

  Widget _buildSummary(CanuelaReport report) {
    final wettest = report.wettestMonth;
    final driest = report.driestMonth;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE4DAC3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF5DF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.calendar_month,
                  color: Color(0xFF246B45),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Señales del año',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                    Text(
                      'Basado en el 1 al 12 de enero de ${report.year}.',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (wettest != null || driest != null) ...[
            Text(
              _summarySentence(wettest: wettest, driest: driest),
              style: const TextStyle(
                color: Color(0xFF3F392D),
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Expanded(
                child: _SummaryMetric(
                  icon: Icons.thermostat,
                  label: 'Sensación',
                  value: _temperaturePlainLabel(report.averageTemperatureC),
                  color: const Color(0xFF0068C7),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryMetric(
                  icon: Icons.water_drop,
                  label: 'Más lluvioso',
                  value: wettest?.monthName ?? 'N/D',
                  color: const Color(0xFF00897B),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryMetric(
                  icon: Icons.wb_sunny,
                  label: 'Menos lluvia',
                  value: driest?.monthName ?? 'N/D',
                  color: const Color(0xFFD77A00),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _summarySentence({
    required CanuelaMonthForecast? wettest,
    required CanuelaMonthForecast? driest,
  }) {
    if (wettest == null || driest == null) {
      return 'La lectura mensual todavía no tiene suficientes datos.';
    }
    return 'A simple vista, ${wettest.monthName} apunta a más lluvia y ${driest.monthName} a poca lluvia.';
  }

  String _temperaturePlainLabel(double temperatureC) {
    if (temperatureC >= 30) {
      return 'Caluroso';
    }
    if (temperatureC >= 24) {
      return 'Cálido';
    }
    if (temperatureC >= 18) {
      return 'Templado';
    }
    return 'Fresco';
  }

  String _errorMessage(Object? error) {
    if (error is CanuelaException) {
      return error.message;
    }
    return 'No fue posible consultar las cabañuelas en este momento.';
  }
}

class _DisclaimerCard extends StatelessWidget {
  const _DisclaimerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white24),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.white, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Las cabañuelas son un método tradicional de observación climática. Pueden variar mucho por zona y año, y no sustituyen un pronóstico meteorológico.',
              style: TextStyle(color: Colors.white, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 112),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 18),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _YearSignalMap extends StatelessWidget {
  const _YearSignalMap({required this.report});

  final CanuelaReport report;

  @override
  Widget build(BuildContext context) {
    final maxRain = report.months.fold<double>(
      0,
      (current, month) =>
          month.precipitationMm > current ? month.precipitationMm : current,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE4DAC3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.grid_view_rounded, color: Color(0xFF246B45)),
              SizedBox(width: 8),
              Text(
                'Mapa del año',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Cada cuadro resume si el mes se ve con poca o mucha lluvia.',
            style: TextStyle(color: Colors.black54, height: 1.35),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final tileWidth = constraints.maxWidth >= 520
                  ? (constraints.maxWidth - 30) / 4
                  : (constraints.maxWidth - 20) / 3;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: report.months
                    .map(
                      (month) => _MonthSignalTile(
                        month: month,
                        maxRainMm: maxRain <= 0 ? 1 : maxRain,
                        width: tileWidth,
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 16),
          const _SignalLegend(),
        ],
      ),
    );
  }
}

class _MonthSignalTile extends StatelessWidget {
  const _MonthSignalTile({
    required this.month,
    required this.maxRainMm,
    required this.width,
  });

  final CanuelaMonthForecast month;
  final double maxRainMm;
  final double width;

  @override
  Widget build(BuildContext context) {
    final color = _signalColor(month.precipitationMm);
    final intensity = (month.precipitationMm / maxRainMm).clamp(0.08, 1.0);

    return Container(
      width: width,
      constraints: const BoxConstraints(minHeight: 104),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08 + (intensity * 0.1)),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_signalIcon(month.precipitationMm), color: color, size: 18),
              const Spacer(),
              Text(
                month.monthName.substring(0, 3),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _rainPlainLabel(month.precipitationMm),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10.5),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: intensity,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.75),
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SignalLegend extends StatelessWidget {
  const _SignalLegend();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 10,
      runSpacing: 8,
      children: [
        _LegendPill(color: Color(0xFFD77A00), label: 'Poca lluvia'),
        _LegendPill(color: Color(0xFF6A8B2A), label: 'Lluvias aisladas'),
        _LegendPill(color: Color(0xFF00897B), label: 'Lluvias frecuentes'),
        _LegendPill(color: Color(0xFF0068C7), label: 'Lluvias abundantes'),
      ],
    );
  }
}

class _LegendPill extends StatelessWidget {
  const _LegendPill({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthCard extends StatelessWidget {
  const _MonthCard({required this.month, required this.maxRainMm});

  final CanuelaMonthForecast month;
  final double maxRainMm;

  @override
  Widget build(BuildContext context) {
    final sourceDate = DateFormat('d MMM', 'es_MX').format(month.sourceDate);
    final signalColor = _signalColor(month.precipitationMm);
    final rainRatio = (month.precipitationMm / maxRainMm).clamp(0.02, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2D7BF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: signalColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  _signalIcon(month.precipitationMm),
                  color: signalColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      month.monthName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Lectura tomada del $sourceDate',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: signalColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _rainPlainLabel(month.precipitationMm),
                  style: TextStyle(
                    color: signalColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _RainIntensityBar(
            value: rainRatio,
            color: signalColor,
            label: 'Intensidad de señal',
            amount: '',
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MiniMetric(
                  label: 'Ambiente',
                  value: _monthMood(month),
                  icon: Icons.cloud_outlined,
                ),
              ),
              Expanded(
                child: _MiniMetric(
                  label: 'Sensación',
                  value: _temperatureRangeLabel(month),
                  icon: Icons.device_thermostat,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: signalColor.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: signalColor.withValues(alpha: 0.12)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.eco_outlined, color: signalColor, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    month.cropHint,
                    style: const TextStyle(
                      color: Color(0xFF3F392D),
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RainIntensityBar extends StatelessWidget {
  const _RainIntensityBar({
    required this.value,
    required this.color,
    required this.label,
    required this.amount,
  });

  final double value;
  final Color color;
  final String label;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Text(
              amount,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 10,
            color: color,
            backgroundColor: const Color(0xFFEFE8D8),
          ),
        ),
      ],
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.black45, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.black54, fontSize: 11),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2D7BF)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, color: Color(0xFFD77A00), size: 42),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700, height: 1.35),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF246B45),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

Color _signalColor(double rainMm) {
  if (rainMm >= 20) {
    return const Color(0xFF0068C7);
  }
  if (rainMm >= 8) {
    return const Color(0xFF00897B);
  }
  if (rainMm >= 1) {
    return const Color(0xFF6A8B2A);
  }
  return const Color(0xFFD77A00);
}

IconData _signalIcon(double rainMm) {
  if (rainMm >= 8) {
    return Icons.water_drop;
  }
  if (rainMm >= 1) {
    return Icons.grain;
  }
  return Icons.wb_sunny;
}

String _rainPlainLabel(double rainMm) {
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

String _monthMood(CanuelaMonthForecast month) {
  if (month.precipitationMm >= 20) {
    return 'Mes muy lluvioso';
  }
  if (month.precipitationMm >= 8) {
    return 'Mes lluvioso';
  }
  if (month.precipitationMm >= 1) {
    return 'Lluvias aisladas';
  }
  if (month.meanTempC >= 28) {
    return 'Poca lluvia y calor';
  }
  return 'Poca lluvia';
}

String _temperatureRangeLabel(CanuelaMonthForecast month) {
  if (month.maxTempC >= 35) {
    return 'Muy caluroso';
  }
  if (month.meanTempC >= 28) {
    return 'Caluroso';
  }
  if (month.meanTempC >= 23) {
    return 'Cálido';
  }
  if (month.minTempC <= 10) {
    return 'Fresco';
  }
  return 'Templado';
}
