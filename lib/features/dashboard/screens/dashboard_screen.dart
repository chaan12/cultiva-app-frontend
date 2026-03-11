import 'package:flutter/material.dart';

import '../../../core/routes/main_navigation.dart';
import '../../../shared/state/app_scope.dart';
import '../../crops_catalog/models/crop_catalog_item.dart';
import '../../crop_details/screens/crop_details_screen.dart';
import '../../crop_tracking/services/crop_tracking_service.dart';
import '../widgets/dashboard_summary_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final weather = store.weather;
    final recommended = store.recommendedCropItems;
    final featuredRecommended = recommended.take(3).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4E0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context, store),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  DashboardSummaryCard(
                    title: 'Temporada actual',
                    subtitle: 'Recomendación dinámica',
                    icon: Icons.eco_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          store.currentSeason,
                          style: const TextStyle(
                            color: Color(0xFF0D5D33),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FBF0),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E9D8)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ranking sugerido para sembrar ahora',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...featuredRecommended.asMap().entries.map(
                                (entry) => _recommendedCropTile(
                                  context,
                                  entry.value,
                                  rank: entry.key + 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CropDetailsScreen(
                                        id: featuredRecommended.first.id,
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00A344),
                                  minimumSize: const Size.fromHeight(50),
                                ),
                                child: const Text(
                                  'Ver mejor opción',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton(
                              onPressed: () =>
                                  _showAllRecommendations(context, recommended),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF0D5D33),
                                side: const BorderSide(
                                  color: Color(0xFF0D5D33),
                                ),
                                minimumSize: const Size(132, 50),
                              ),
                              child: const Text('Ver todos'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      MainNavigation.of(context)?.goToTab(1);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00C853), Color(0xFF00A344)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.list_alt,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Mis Cultivos',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  '${store.activeCropsCount} activos • ${store.upcomingEventsCount} eventos',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DashboardSummaryCard(
                    title: 'Clima actual',
                    subtitle:
                        weather?.locationLabel ?? store.settings.locationName,
                    icon: Icons.cloud_queue,
                    child: weather == null
                        ? Row(
                            children: [
                              Expanded(
                                child: Text(
                                  store.isBusy
                                      ? 'Obteniendo temperatura de tu ubicación actual...'
                                      : 'No se pudo cargar el clima todavía.',
                                ),
                              ),
                              IconButton(
                                onPressed: store.refreshWeather,
                                icon: const Icon(Icons.refresh),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    weather.description,
                                    style: const TextStyle(
                                      color: Color(0xFF1565C0),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    weather.primarySourceName,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  Text(
                                    '${weather.temperatureC.toStringAsFixed(0)}°C',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Lluvia ${weather.rainProbability}% • Humedad ${weather.humidity}%',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE3F2FD),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.wb_cloudy_outlined,
                                  color: Color(0xFF1565C0),
                                  size: 48,
                                ),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 16),
                  DashboardSummaryCard(
                    title: 'Resumen de cultivos',
                    subtitle: 'Datos reales guardados localmente',
                    icon: Icons.analytics_outlined,
                    child: Column(
                      children: [
                        _metricRow(
                          'Cultivos activos',
                          store.activeCropsCount.toString(),
                        ),
                        _metricRow(
                          'Superficie total',
                          '${store.totalHectares.toStringAsFixed(1)} ha',
                        ),
                        _metricRow(
                          'Eventos próximos',
                          store.upcomingEventsCount.toString(),
                        ),
                        if (store.nextHarvestCrop != null)
                          _metricRow(
                            'Próximo hito',
                            '${store.nextHarvestCrop!.name}: ${CropTrackingService.buildSummary(store.nextHarvestCrop!).nextEventLabel}',
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (weather != null)
                    DashboardSummaryCard(
                      title: 'Alerta climática',
                      subtitle: 'Basada en API real',
                      icon: Icons.warning_amber_rounded,
                      backgroundColor: const Color(0xFFFFFDE7),
                      child: Text(
                        weather.alerts.first,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF856404),
                        ),
                      ),
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic store) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D5D33), Color(0xFF0A4D2A)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bienvenido a',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const Text(
                'Cultiva +',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.white70,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    store.settings.locationName,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () {
                MainNavigation.of(context)?.goToTab(4);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _recommendedCropTile(
    BuildContext context,
    CropCatalogItem item, {
    required int rank,
  }) {
    final rankLabel = switch (rank) {
      1 => 'Top 1',
      2 => 'Top 2',
      3 => 'Top 3',
      _ => 'Top $rank',
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CropDetailsScreen(id: item.id)),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E9D8)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: item.badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item.icon, color: item.badgeColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            rankLabel,
                            style: const TextStyle(
                              color: Color(0xFF0D5D33),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D5D33),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${item.sowingWindow} • ${item.cycleDays} días',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF0D5D33)),
            ],
          ),
        ),
      ),
    );
  }

  void _showAllRecommendations(
    BuildContext context,
    List<CropCatalogItem> items,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF1F4E0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Cultivos recomendados',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Ordenados por temporada actual y ventana de siembra.',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return _recommendedCropTile(
                        context,
                        items[index],
                        rank: index + 1,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
