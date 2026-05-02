import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/models/canuela_forecast.dart';
import '../../../shared/services/canuela_service.dart';
import '../../../shared/state/app_scope.dart';

const Color _pageColor = Color(0xFFF1F4E0);
const Color _surfaceColor = Colors.white;
const Color _softSurfaceColor = Color(0xFFF7FAF3);
const Color _borderColor = Color(0xFFDDE7D0);
const Color _textColor = Color(0xFF233323);
const Color _mutedTextColor = Colors.black54;

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
  int _selectedMonthIndex = DateTime.now().month - 1;

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
    setState(() => _future = future);
    try {
      await future;
    } catch (_) {
      // FutureBuilder renders the error state.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageColor,
      body: SafeArea(
        child: FutureBuilder<CanuelaReport>(
          future: _future,
          builder: (context, snapshot) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  if (snapshot.hasData)
                    _buildContent(snapshot.data!)
                  else if (snapshot.hasError)
                    _buildError(snapshot.error)
                  else
                    _buildLoading(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(CanuelaReport report) {
    final months = report.months.map(_MonthClimateData.fromForecast).toList();
    if (months.isEmpty) {
      return _buildError(const CanuelaException('No hay datos disponibles.'));
    }

    final summary = _AnnualClimateSummary.fromMonths(months);
    final selectedIndex = _selectedMonthIndex.clamp(0, months.length - 1);
    final selectedMonth = months[selectedIndex];
    final currentIndex = (DateTime.now().month - 1).clamp(0, months.length - 1);
    final currentMonth = months[currentIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SummaryHeader(
          report: report,
          summary: summary,
          locationLabel: report.locationLabel,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CurrentMonthCard(month: currentMonth),
              const SizedBox(height: 20),
              _SelectedMonthFocus(month: selectedMonth),
              const SizedBox(height: 20),
              _YearQuickGrid(
                months: months,
                selectedIndex: selectedIndex,
                onSelected: (index) {
                  setState(() => _selectedMonthIndex = index);
                },
              ),
              const SizedBox(height: 20),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: _MonthDetailPanel(
                  key: ValueKey<int>(selectedMonth.monthIndex),
                  month: selectedMonth,
                ),
              ),
              const SizedBox(height: 20),
              const _DisclaimerBanner(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return Column(
      children: [
        _LoadingHeader(
          locationLabel: _locationLabel ?? 'Ubicación seleccionada',
        ),
        const Padding(
          padding: EdgeInsets.only(top: 56),
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }

  Widget _buildError(Object? error) {
    return Column(
      children: [
        _LoadingHeader(
          locationLabel: _locationLabel ?? 'Ubicación seleccionada',
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: _ErrorState(message: _errorMessage(error), onRetry: _refresh),
        ),
      ],
    );
  }

  String _errorMessage(Object? error) {
    if (error is CanuelaException) {
      return error.message;
    }
    return 'No fue posible consultar las cabañuelas en este momento.';
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({
    required this.report,
    required this.summary,
    required this.locationLabel,
  });

  final CanuelaReport report;
  final _AnnualClimateSummary summary;
  final String locationLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: const BoxDecoration(
        color: AppColors.greenDark,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
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
              _SourceBadge(label: report.sourceName),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cabañuelas ${report.year}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      summary.tendency,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      locationLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              _HeaderWeatherMark(summary: summary),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _HeaderIndicator(
                  icon: Icons.water_drop,
                  label: 'Lluvia',
                  value: '${summary.averageRainProbability}%',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeaderIndicator(
                  icon: Icons.wb_sunny,
                  label: 'Secos',
                  value: '${summary.dryMonthPercent}%',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeaderIndicator(
                  icon: Icons.thunderstorm,
                  label: 'Lluviosos',
                  value: '${summary.rainyMonthPercent}%',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoadingHeader extends StatelessWidget {
  const _LoadingHeader({required this.locationLabel});

  final String locationLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: const BoxDecoration(
        color: AppColors.greenDark,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            tooltip: 'Regresar',
          ),
          const SizedBox(height: 20),
          const Text(
            'Cabañuelas',
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(locationLabel, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

class _HeaderWeatherMark extends StatelessWidget {
  const _HeaderWeatherMark({required this.summary});

  final _AnnualClimateSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 108,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white24),
      ),
      child: Stack(
        children: [
          Center(child: Icon(summary.icon, color: summary.color, size: 58)),
          Positioned(
            right: 16,
            bottom: 16,
            child: Container(
              width: 13,
              height: 13,
              decoration: BoxDecoration(
                color: summary.color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIndicator extends StatelessWidget {
  const _HeaderIndicator({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 92),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _SourceBadge extends StatelessWidget {
  const _SourceBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentMonthCard extends StatelessWidget {
  const _CurrentMonthCard({required this.month});

  final _MonthClimateData month;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.greenDark,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 70,
            height: 86,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white24),
            ),
            child: Icon(month.icon, color: month.color, size: 40),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mes actual',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  month.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _WhiteInfoPill(
                      icon: month.icon,
                      label: month.weatherType,
                      color: month.color,
                    ),
                    _WhiteInfoPill(
                      icon: Icons.water_drop_outlined,
                      label: '${month.rainProbability}% lluvia',
                      color: AppColors.blue,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  month.shortDescription,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedMonthFocus extends StatelessWidget {
  const _SelectedMonthFocus({required this.month});

  final _MonthClimateData month;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(radius: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mes seleccionado',
            style: TextStyle(color: _mutedTextColor, fontSize: 12),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 92,
                height: 112,
                decoration: BoxDecoration(
                  color: month.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: month.color.withValues(alpha: 0.18),
                  ),
                ),
                child: Icon(month.icon, color: month.color, size: 54),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      month.name,
                      style: const TextStyle(
                        color: _textColor,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _StatePill(month: month),
                    const SizedBox(height: 12),
                    Text(
                      month.shortDescription,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _textColor,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _ClimateGauge(
                  icon: Icons.water_drop,
                  label: 'Lluvia',
                  value: '${month.rainProbability}%',
                  progress: month.rainProbability / 100,
                  color: month.color,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ClimateGauge(
                  icon: Icons.air,
                  label: 'Viento',
                  value: month.windLevel,
                  progress: month.windScore,
                  color: AppColors.blue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ClimateGauge(
                  icon: Icons.opacity,
                  label: month.moistureLabel,
                  value: '${month.moisturePercent}%',
                  progress: month.moisturePercent / 100,
                  color: AppColors.greenDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _YearQuickGrid extends StatelessWidget {
  const _YearQuickGrid({
    required this.months,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<_MonthClimateData> months;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(shadow: false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Vista rápida del año',
            subtitle: 'Toca un mes para ver su detalle climático.',
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth >= 520
                  ? (constraints.maxWidth - 30) / 4
                  : (constraints.maxWidth - 20) / 3;

              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (var index = 0; index < months.length; index++)
                    _QuickMonthCard(
                      month: months[index],
                      selected: index == selectedIndex,
                      width: itemWidth,
                      onTap: () => onSelected(index),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QuickMonthCard extends StatelessWidget {
  const _QuickMonthCard({
    required this.month,
    required this.selected,
    required this.width,
    required this.onTap,
  });

  final _MonthClimateData month;
  final bool selected;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: width,
        constraints: const BoxConstraints(minHeight: 106),
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: selected
              ? month.color.withValues(alpha: 0.12)
              : _softSurfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? month.color : _borderColor,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(month.icon, color: month.color, size: 22),
                const Spacer(),
                Text(
                  month.shortName,
                  style: TextStyle(
                    color: month.color,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              month.weatherType,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _textColor,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${month.rainProbability}% lluvia',
              style: const TextStyle(color: _mutedTextColor, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthDetailPanel extends StatelessWidget {
  const _MonthDetailPanel({super.key, required this.month});

  final _MonthClimateData month;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(radius: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: 'Detalle de ${month.name}',
            subtitle: 'Lectura visual derivada de las señales tradicionales.',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _DetailStatCard(
                  icon: Icons.water_drop_outlined,
                  label: 'Probabilidad de lluvia',
                  value: '${month.rainProbability}%',
                  color: month.color,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DetailStatCard(
                  icon: Icons.cloud_outlined,
                  label: 'Clima dominante',
                  value: month.weatherType,
                  color: month.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _DetailStatCard(
                  icon: Icons.calendar_view_month_outlined,
                  label: 'Días secos / húmedos',
                  value: '${month.dryDays} / ${month.wetDays}',
                  color: AppColors.orange,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DetailStatCard(
                  icon: Icons.air,
                  label: 'Viento estimado',
                  value: month.windLevel,
                  color: AppColors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: month.color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: month.color.withValues(alpha: 0.14)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.eco_outlined, color: month.color, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    month.detailDescription,
                    style: const TextStyle(
                      color: _textColor,
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

class _DisclaimerBanner extends StatelessWidget {
  const _DisclaimerBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8D8A6)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Color(0xFF856404), size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Las cabañuelas son un método tradicional. No sustituyen pronósticos meteorológicos oficiales; por el cambio climático su precisión puede variar. Úsalas como referencia general.',
              style: TextStyle(
                color: Color(0xFF5F4B16),
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatePill extends StatelessWidget {
  const _StatePill({required this.month});

  final _MonthClimateData month;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: month.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: month.color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(month.icon, color: month.color, size: 15),
          const SizedBox(width: 6),
          Text(
            month.weatherType,
            style: TextStyle(
              color: month.color,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _WhiteInfoPill extends StatelessWidget {
  const _WhiteInfoPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClimateGauge extends StatelessWidget {
  const _ClimateGauge({
    required this.icon,
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 126),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _softSurfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 14),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: _mutedTextColor, fontSize: 11),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 7,
              color: color,
              backgroundColor: color.withValues(alpha: 0.14),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailStatCard extends StatelessWidget {
  const _DetailStatCard({
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
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: _softSurfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 16),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: _mutedTextColor, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _textColor,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(color: _mutedTextColor, height: 1.3),
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
      decoration: _cardDecoration(),
      child: Column(
        children: [
          const Icon(Icons.cloud_off, color: AppColors.orange, size: 44),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _textColor,
              fontWeight: FontWeight.w800,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.greenDark,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthClimateData {
  const _MonthClimateData({
    required this.monthIndex,
    required this.name,
    required this.shortName,
    required this.rainProbability,
    required this.windLevel,
    required this.windScore,
    required this.moistureLabel,
    required this.moisturePercent,
    required this.weatherType,
    required this.dryDays,
    required this.wetDays,
    required this.shortDescription,
    required this.detailDescription,
    required this.icon,
    required this.color,
  });

  factory _MonthClimateData.fromForecast(CanuelaMonthForecast forecast) {
    final rainProbability = _rainProbabilityFrom(forecast);
    final wetDays = ((rainProbability / 100) * 30).round().clamp(0, 30);
    final dryDays = 30 - wetDays;
    final wind = _windFrom(forecast.weatherCode, rainProbability);
    final moisture = _moistureFrom(rainProbability, forecast.meanTempC);
    final profile = _profileFrom(forecast, rainProbability);

    return _MonthClimateData(
      monthIndex: forecast.monthIndex,
      name: forecast.monthName,
      shortName: forecast.monthName.substring(0, 3),
      rainProbability: rainProbability,
      windLevel: wind.label,
      windScore: wind.score,
      moistureLabel: moisture.label,
      moisturePercent: moisture.percent,
      weatherType: profile.weatherType,
      dryDays: dryDays,
      wetDays: wetDays,
      shortDescription: profile.shortDescription,
      detailDescription: profile.detailDescription,
      icon: profile.icon,
      color: profile.color,
    );
  }

  final int monthIndex;
  final String name;
  final String shortName;
  final int rainProbability;
  final String windLevel;
  final double windScore;
  final String moistureLabel;
  final int moisturePercent;
  final String weatherType;
  final int dryDays;
  final int wetDays;
  final String shortDescription;
  final String detailDescription;
  final IconData icon;
  final Color color;
}

class _AnnualClimateSummary {
  const _AnnualClimateSummary({
    required this.averageRainProbability,
    required this.dryMonthPercent,
    required this.rainyMonthPercent,
    required this.tendency,
    required this.icon,
    required this.color,
  });

  factory _AnnualClimateSummary.fromMonths(List<_MonthClimateData> months) {
    final averageRain = months.isEmpty
        ? 0
        : (months.fold<int>(0, (sum, month) => sum + month.rainProbability) /
                  months.length)
              .round();
    final dryMonths = months
        .where((month) => month.rainProbability <= 35)
        .length;
    final rainyMonths = months
        .where((month) => month.rainProbability >= 60)
        .length;
    final dryPercent = months.isEmpty
        ? 0
        : ((dryMonths / months.length) * 100).round();
    final rainyPercent = months.isEmpty
        ? 0
        : ((rainyMonths / months.length) * 100).round();

    if (dryMonths >= 6) {
      return _AnnualClimateSummary(
        averageRainProbability: averageRain,
        dryMonthPercent: dryPercent,
        rainyMonthPercent: rainyPercent,
        tendency: 'Tendencia general: año seco',
        icon: Icons.wb_sunny,
        color: AppColors.gold,
      );
    }
    if (rainyMonths >= 6) {
      return _AnnualClimateSummary(
        averageRainProbability: averageRain,
        dryMonthPercent: dryPercent,
        rainyMonthPercent: rainyPercent,
        tendency: 'Tendencia general: año lluvioso',
        icon: Icons.thunderstorm,
        color: AppColors.blue,
      );
    }
    return _AnnualClimateSummary(
      averageRainProbability: averageRain,
      dryMonthPercent: dryPercent,
      rainyMonthPercent: rainyPercent,
      tendency: 'Tendencia general: año variable',
      icon: Icons.cloud_queue,
      color: AppColors.greenPrimary,
    );
  }

  final int averageRainProbability;
  final int dryMonthPercent;
  final int rainyMonthPercent;
  final String tendency;
  final IconData icon;
  final Color color;
}

class _WindData {
  const _WindData(this.label, this.score);

  final String label;
  final double score;
}

class _MoistureData {
  const _MoistureData(this.label, this.percent);

  final String label;
  final int percent;
}

class _ClimateProfile {
  const _ClimateProfile({
    required this.weatherType,
    required this.shortDescription,
    required this.detailDescription,
    required this.icon,
    required this.color,
  });

  final String weatherType;
  final String shortDescription;
  final String detailDescription;
  final IconData icon;
  final Color color;
}

int _rainProbabilityFrom(CanuelaMonthForecast forecast) {
  final rain = forecast.precipitationMm;
  if (rain >= 20) {
    return 88;
  }
  if (rain >= 8) {
    return 68;
  }
  if (rain >= 1) {
    return 44;
  }
  if (forecast.meanTempC >= 28) {
    return 18;
  }
  return 26;
}

_WindData _windFrom(int weatherCode, int rainProbability) {
  if (weatherCode >= 95 || rainProbability >= 80) {
    return const _WindData('Alto', 0.86);
  }
  if (rainProbability >= 45) {
    return const _WindData('Medio', 0.56);
  }
  return const _WindData('Bajo', 0.25);
}

_MoistureData _moistureFrom(int rainProbability, double meanTempC) {
  if (rainProbability >= 70) {
    return const _MoistureData('Humedad', 82);
  }
  if (rainProbability >= 45) {
    return const _MoistureData('Humedad', 58);
  }
  if (meanTempC >= 28) {
    return const _MoistureData('Sequía', 72);
  }
  return const _MoistureData('Sequía', 48);
}

_ClimateProfile _profileFrom(
  CanuelaMonthForecast forecast,
  int rainProbability,
) {
  if (rainProbability >= 80) {
    return const _ClimateProfile(
      weatherType: 'Mayormente lluvioso',
      shortDescription: 'Señales fuertes de lluvia y humedad durante el mes.',
      detailDescription:
          'La lectura tradicional sugiere un mes húmedo, con más días propensos a lluvia y menor estabilidad para labores sensibles al exceso de agua.',
      icon: Icons.thunderstorm,
      color: AppColors.blue,
    );
  }
  if (rainProbability >= 60) {
    return const _ClimateProfile(
      weatherType: 'Lluvioso',
      shortDescription: 'Ambiente húmedo con lluvias frecuentes.',
      detailDescription:
          'Se interpreta como un mes con humedad presente y lluvia recurrente. Conviene considerar drenaje, maleza y ventanas cortas de trabajo.',
      icon: Icons.water_drop,
      color: Color(0xFF00897B),
    );
  }
  if (rainProbability >= 38) {
    return const _ClimateProfile(
      weatherType: 'Variable',
      shortDescription: 'Días secos combinados con lluvias aisladas.',
      detailDescription:
          'La señal apunta a cambios moderados: puede alternar periodos secos con eventos de lluvia. Es útil monitorear riegos y humedad del suelo.',
      icon: Icons.cloud_queue,
      color: Color(0xFF6A8B2A),
    );
  }
  if (forecast.meanTempC >= 28) {
    return const _ClimateProfile(
      weatherType: 'Mayormente seco',
      shortDescription: 'Poca lluvia con sensación cálida.',
      detailDescription:
          'La lectura sugiere baja lluvia y calor. Puede requerir mayor cuidado de riego, cobertura de suelo y vigilancia de estrés hídrico.',
      icon: Icons.wb_sunny,
      color: AppColors.orange,
    );
  }
  return const _ClimateProfile(
    weatherType: 'Seco estable',
    shortDescription: 'Poca lluvia y condiciones moderadas.',
    detailDescription:
        'La señal tradicional indica un mes estable, con baja lluvia y menor variación. Puede favorecer labores planificadas con riego controlado.',
    icon: Icons.wb_sunny_outlined,
    color: AppColors.gold,
  );
}

BoxDecoration _cardDecoration({double radius = 26, bool shadow = true}) {
  return BoxDecoration(
    color: _surfaceColor,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: _borderColor),
    boxShadow: shadow
        ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ]
        : null,
  );
}
