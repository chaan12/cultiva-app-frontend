import 'package:flutter/material.dart';

import '../../../core/routes/main_navigation.dart';
import '../../../shared/state/app_scope.dart';
import '../../crop_details/screens/crop_details_screen.dart';
import '../widgets/dashboard_summary_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final weather = store.weather;

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
                                'Cultivo recomendado',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                store.recommendedCropItem.name,
                                style: const TextStyle(
                                  color: Color(0xFF34A853),
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'Basado en la temporada actual y el catálogo local.',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CropDetailsScreen(
                                  id: store.recommendedCropItem.id,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00A344),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text(
                            'Ver detalles del cultivo',
                            style: TextStyle(color: Colors.white),
                          ),
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
                            '${store.nextHarvestCrop!.name}: ${store.nextHarvestCrop!.nextEventLabel}',
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
}
