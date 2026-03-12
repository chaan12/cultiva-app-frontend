import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/models/weather_snapshot.dart';
import '../../../shared/state/app_scope.dart';

class ClimaScreen extends StatefulWidget {
  const ClimaScreen({super.key});

  @override
  State<ClimaScreen> createState() => _ClimaScreenState();
}

class _ClimaScreenState extends State<ClimaScreen> {
  final Set<String> _favorites = <String>{'noaa_gfs', 'ecmwf'};
  final Set<String> _disabled = <String>{};

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final weather = store.weather;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4E0),
      body: RefreshIndicator(
        onRefresh: store.refreshWeather,
        child: ListView(
          children: [
            _buildHeader(
              weather,
              store.settings.locationName,
              lastWifiSyncAt: store.lastWifiSyncAt,
              hasWifiConnection: store.hasWifiConnection,
              isShowingCachedWeather: store.isShowingCachedWeather,
            ),
            if (weather == null)
              Padding(
                padding: const EdgeInsets.all(32),
                child: store.isBusy
                    ? const Center(child: CircularProgressIndicator())
                    : _buildEmptyState(store.hasWifiConnection),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildSyncStatusCard(
                      weather,
                      lastWifiSyncAt: store.lastWifiSyncAt,
                      hasWifiConnection: store.hasWifiConnection,
                      isShowingCachedWeather: store.isShowingCachedWeather,
                    ),
                    const SizedBox(height: 20),
                    _buildAlertSection(weather),
                    const SizedBox(height: 20),
                    _buildDailyForecastSection(weather),
                    const SizedBox(height: 20),
                    _buildChartCard(
                      'Temperatura NOAA GFS (24h)',
                      Icons.thermostat,
                      Colors.blue,
                      _temperatureChart(weather.hourly),
                    ),
                    const SizedBox(height: 20),
                    _buildChartCard(
                      'Precipitación NOAA GFS (24h)',
                      Icons.grain,
                      Colors.green,
                      _rainChart(weather.hourly),
                    ),
                    const SizedBox(height: 20),
                    _buildChartCard(
                      'Humedad relativa (24h)',
                      Icons.water_drop_outlined,
                      Colors.teal,
                      _humidityChart(weather.hourly),
                    ),
                    const SizedBox(height: 20),
                    _buildChartCard(
                      'Viento y UV (24h)',
                      Icons.air,
                      Colors.deepOrange,
                      _windUvChart(weather.hourly),
                    ),
                    const SizedBox(height: 20),
                    _buildSourcesList(weather),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    WeatherSnapshot? weather,
    String fallbackLocation, {
    required DateTime? lastWifiSyncAt,
    required bool hasWifiConnection,
    required bool isShowingCachedWeather,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Clima',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            weather?.locationLabel ?? fallbackLocation,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 10),
          _buildHeaderBadge(
            hasWifiConnection: hasWifiConnection,
            isShowingCachedWeather: isShowingCachedWeather,
            lastWifiSyncAt: lastWifiSyncAt,
          ),
          const SizedBox(height: 25),
          if (weather != null) _buildMainWeatherCard(weather),
        ],
      ),
    );
  }

  Widget _buildHeaderBadge({
    required bool hasWifiConnection,
    required bool isShowingCachedWeather,
    required DateTime? lastWifiSyncAt,
  }) {
    final label = hasWifiConnection
        ? 'Wi-Fi conectado'
        : isShowingCachedWeather
        ? 'Mostrando datos guardados'
        : 'Sin Wi-Fi';
    final subtitle = lastWifiSyncAt == null
        ? 'Aún no hay una sincronización local'
        : 'Última sincronización: ${_formatDateTime(lastWifiSyncAt)}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Icon(
            hasWifiConnection ? Icons.wifi : Icons.cloud_off,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainWeatherCard(WeatherSnapshot weather) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fuente principal: ${weather.primarySourceName}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    '${weather.temperatureC.toStringAsFixed(1)}°C',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    weather.description,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
              const Icon(Icons.cloud_outlined, color: Colors.white, size: 80),
            ],
          ),
          const Divider(color: Colors.white24, height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _headerInfo(
                Icons.air,
                '${weather.windSpeedKmh.toStringAsFixed(1)} km/h',
                'Viento',
              ),
              _headerInfo(
                Icons.water_drop_outlined,
                '${weather.humidity}%',
                'Humedad',
              ),
              _headerInfo(
                Icons.remove_red_eye,
                '${weather.visibilityKm.toStringAsFixed(1)} km',
                'Visibilidad',
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _headerInfo(
                Icons.umbrella_outlined,
                '${weather.rainProbability}%',
                'Lluvia',
              ),
              _headerInfo(
                Icons.sunny,
                weather.uvIndex.toStringAsFixed(1),
                'UV',
              ),
              _headerInfo(
                Icons.compress,
                '${weather.pressureHpa.toStringAsFixed(0)} hPa',
                'Presión',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerInfo(IconData icon, String val, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        Text(
          val,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildAlertSection(WeatherSnapshot weather) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text(
              'Alertas activas',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...weather.alerts
            .take(2)
            .map(
              (alert) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orangeAccent),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.orange,
                      child: Icon(Icons.priority_high, color: Colors.white),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        alert,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE65100),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildSyncStatusCard(
    WeatherSnapshot weather, {
    required DateTime? lastWifiSyncAt,
    required bool hasWifiConnection,
    required bool isShowingCachedWeather,
  }) {
    final forecastStart = weather.forecastStartDate;
    final forecastEnd = weather.forecastEndDate;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDCE6D2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasWifiConnection ? Icons.wifi : Icons.wifi_off,
                color: hasWifiConnection
                    ? const Color(0xFF1565C0)
                    : Colors.orange.shade700,
              ),
              const SizedBox(width: 8),
              const Text(
                'Sincronización offline',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _statusRow(
            'Última conexión por Wi-Fi',
            lastWifiSyncAt == null
                ? 'Aún no registrada'
                : _formatDateTime(lastWifiSyncAt),
          ),
          _statusRow(
            'Rango guardado local',
            forecastStart == null || forecastEnd == null
                ? 'Sin rango disponible'
                : '${_formatDate(forecastStart)} al ${_formatDate(forecastEnd)}',
          ),
          _statusRow(
            'Datos mostrados',
            isShowingCachedWeather
                ? 'Según lo sincronizado ese día'
                : 'Sincronización actual desde Wi-Fi',
          ),
          const SizedBox(height: 10),
          Text(
            isShowingCachedWeather
                ? 'La app está usando el pronóstico guardado localmente para mostrar lo que reportaba la API en la última sincronización.'
                : 'La app puede guardar hoy y los próximos 15 días para seguir mostrándolos si después te quedas sin Wi-Fi.',
            style: const TextStyle(color: Colors.black54, height: 1.35),
          ),
        ],
      ),
    );
  }

  Widget _statusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyForecastSection(WeatherSnapshot weather) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pronóstico guardado (hoy + 15 días)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 182,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: weather.daily.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final day = weather.daily[index];
              return Container(
                width: 150,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFDDE7D0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      day.label,
                      style: const TextStyle(
                        color: Color(0xFF0D5D33),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatDate(day.date),
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const Spacer(),
                    Text(
                      day.description,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${day.maxTempC.toStringAsFixed(0)}° / ${day.minTempC.toStringAsFixed(0)}°',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lluvia ${day.rainProbability}%',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                        ),
                      
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool hasWifiConnection) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDDE7D0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasWifiConnection ? Icons.cloud_sync : Icons.wifi_off,
            size: 42,
            color: const Color(0xFF1565C0),
          ),
          const SizedBox(height: 12),
          Text(
            hasWifiConnection
                ? 'Esperando la primera sincronización del clima'
                : 'Sin Wi-Fi y sin datos guardados todavía',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          const SizedBox(height: 8),
          Text(
            hasWifiConnection
                ? 'En cuanto la consulta termine, se guardará el pronóstico local para hoy y los próximos 15 días.'
                : 'Conéctate a Wi-Fi para descargar el pronóstico y dejarlo disponible offline.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54, height: 1.35),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(
    String title,
    IconData icon,
    Color color,
    Widget chart,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: color),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '24H',
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(height: 220, child: chart),
        ],
      ),
    );
  }

  Widget _temperatureChart(List<HourlyWeatherPoint> points) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.black12, strokeWidth: 1),
        ),
        titlesData: _titlesData(points),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: points
                .asMap()
                .entries
                .map(
                  (entry) =>
                      FlSpot(entry.key.toDouble(), entry.value.temperatureC),
                )
                .toList(),
            isCurved: true,
            color: Colors.blue,
            barWidth: 4,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rainChart(List<HourlyWeatherPoint> points) {
    final maxRain = points.fold<double>(
      0,
      (current, point) =>
          point.precipitationMm > current ? point.precipitationMm : current,
    );
    if (maxRain <= 0) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF7FAF3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green.withValues(alpha: 0.12)),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.water_drop_outlined, color: Colors.green, size: 34),
              SizedBox(height: 10),
              Text(
                'Sin lluvia prevista en las próximas 24 horas',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return BarChart(
      BarChartData(
        maxY: maxRain < 1 ? 1 : maxRain * 1.35,
        alignment: BarChartAlignment.spaceAround,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.green.withValues(alpha: 0.12),
            strokeWidth: 1,
          ),
        ),
        titlesData: _titlesData(points, showLeftTitles: true),
        borderData: FlBorderData(show: false),
        barGroups: points
            .asMap()
            .entries
            .map(
              (entry) => BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: entry.value.precipitationMm,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7BD389), Color(0xFF2E7D32)],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    width: 12,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _humidityChart(List<HourlyWeatherPoint> points) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false),
        titlesData: _titlesData(points),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: points
                .asMap()
                .entries
                .map(
                  (entry) => FlSpot(
                    entry.key.toDouble(),
                    entry.value.humidity.toDouble(),
                  ),
                )
                .toList(),
            isCurved: true,
            color: Colors.teal,
            barWidth: 3,
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }

  Widget _windUvChart(List<HourlyWeatherPoint> points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            _ChartLegendDot(color: Colors.deepOrange, label: 'Viento'),
            SizedBox(width: 16),
            _ChartLegendDot(color: Colors.amber, label: 'UV'),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true, drawVerticalLine: false),
              titlesData: _titlesData(points),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: points
                      .asMap()
                      .entries
                      .map(
                        (entry) => FlSpot(
                          entry.key.toDouble(),
                          entry.value.windSpeedKmh,
                        ),
                      )
                      .toList(),
                  isCurved: true,
                  color: Colors.deepOrange,
                  barWidth: 3,
                  dotData: FlDotData(show: false),
                ),
                LineChartBarData(
                  spots: points
                      .asMap()
                      .entries
                      .map(
                        (entry) => FlSpot(
                          entry.key.toDouble(),
                          entry.value.uvIndex * 4,
                        ),
                      )
                      .toList(),
                  isCurved: true,
                  color: Colors.amber,
                  barWidth: 2,
                  dotData: FlDotData(show: false),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  FlTitlesData _titlesData(
    List<HourlyWeatherPoint> points, {
    bool showLeftTitles = false,
  }) {
    return FlTitlesData(
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: showLeftTitles,
          reservedSize: showLeftTitles ? 34 : 0,
          interval: showLeftTitles ? 0.5 : null,
          getTitlesWidget: (value, meta) {
            if (!showLeftTitles) {
              return const SizedBox.shrink();
            }
            return Text(
              value.toStringAsFixed(value >= 1 ? 0 : 1),
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            );
          },
        ),
      ),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 26,
          interval: 6,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 ||
                index >= points.length ||
                value != index.toDouble()) {
              return const SizedBox.shrink();
            }
            return Text(
              points[index].label,
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSourcesList(WeatherSnapshot weather) {
    final sources = [...weather.providers]
      ..sort((a, b) {
        final aDisabled = _disabled.contains(a.id);
        final bDisabled = _disabled.contains(b.id);
        if (aDisabled != bDisabled) {
          return aDisabled ? 1 : -1;
        }
        final aFav = _favorites.contains(a.id);
        final bFav = _favorites.contains(b.id);
        if (aFav && !bFav) return -1;
        if (!aFav && bFav) return 1;
        return b.reliability.compareTo(a.reliability);
      });
    final activeCount = sources
        .where((provider) => !_disabled.contains(provider.id))
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Fuentes meteorológicas',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$activeCount activas',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        ...sources.map(_sourceCard),
      ],
    );
  }

  Widget _sourceCard(WeatherProviderSnapshot source) {
    if (_disabled.contains(source.id)) {
      return Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    source.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Fuente desactivada',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _disabled.remove(source.id);
                });
              },
              icon: const Icon(Icons.restart_alt),
              label: const Text('Activar'),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: _favorites.contains(source.id)
            ? Border.all(color: Colors.amber, width: 2)
            : Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _favorites.contains(source.id)
                  ? Colors.amber.withValues(alpha: 0.08)
                  : Colors.grey.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            source.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            source.description,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          if (_favorites.contains(source.id)) {
                            _favorites.remove(source.id);
                          } else {
                            _favorites.add(source.id);
                          }
                        });
                      },
                      icon: Icon(
                        _favorites.contains(source.id)
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: source.reliability / 100,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(10),
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation(
                          source.reliability >= 90
                              ? Colors.green
                              : source.reliability >= 80
                              ? Colors.orange
                              : Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${source.reliability}% confiable',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: source.available
                ? GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 0.9,
                    children: source.data.entries.map((entry) {
                      final meta = _metricMeta(entry.key);
                      return Container(
                        margin: const EdgeInsets.all(6),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: meta.color.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: meta.color.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(meta.icon, size: 22, color: meta.color),
                            const SizedBox(height: 6),
                            Text(
                              meta.label,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              entry.value,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: meta.color,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  )
                : const Text(
                    'Esta fuente no tiene cobertura disponible para la ubicación seleccionada.',
                    style: TextStyle(color: Colors.grey),
                  ),
          ),
          if (source.alerts.isNotEmpty)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: source.alerts.map((alert) {
                  return Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        size: 16,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          alert,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _disabled.contains(source.id)
                      ? 'Fuente desactivada'
                      : 'Fuente activa',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: !_disabled.contains(source.id),
                  onChanged: (value) {
                    setState(() {
                      if (value) {
                        _disabled.remove(source.id);
                      } else {
                        _disabled.add(source.id);
                      }
                    });
                  },
                  activeThumbColor: Colors.blue,
                  activeTrackColor: Colors.blue.withValues(alpha: 0.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _MetricMeta _metricMeta(String key) {
    switch (key) {
      case 'temperature':
        return const _MetricMeta(Icons.thermostat, Colors.blue, 'Temp');
      case 'humidity':
        return const _MetricMeta(Icons.water_drop, Colors.green, 'Humedad');
      case 'rainProbability':
        return const _MetricMeta(Icons.grain, Colors.blue, 'Lluvia');
      case 'windSpeed':
        return const _MetricMeta(Icons.air, Colors.teal, 'Viento');
      case 'uvIndex':
        return const _MetricMeta(Icons.wb_sunny, Colors.deepOrange, 'UV');
      case 'visibility':
        return const _MetricMeta(Icons.remove_red_eye, Colors.indigo, 'Visib.');
      case 'pressure':
        return const _MetricMeta(Icons.speed, Colors.purple, 'Presión');
      case 'cloudCover':
        return const _MetricMeta(Icons.cloud, Colors.blueGrey, 'Nubes');
      default:
        return const _MetricMeta(Icons.info, Colors.grey, 'Dato');
    }
  }

  String _formatDateTime(DateTime value) {
    return DateFormat('d MMM y, HH:mm', 'es_MX').format(value);
  }

  String _formatDate(DateTime value) {
    return DateFormat('d MMM', 'es_MX').format(value);
  }
}

class _ChartLegendDot extends StatelessWidget {
  const _ChartLegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class _MetricMeta {
  const _MetricMeta(this.icon, this.color, this.label);

  final IconData icon;
  final Color color;
  final String label;
}
