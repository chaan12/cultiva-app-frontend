import 'package:flutter/material.dart';

import '../../../core/routes/main_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/services/agricultural_advisory_service.dart';
import '../../../shared/state/app_scope.dart';
import '../../../shared/state/app_store.dart';
import '../../calendar/screens/agricultural_calendar_screen.dart';
import '../../crops_catalog/models/crop_catalog_item.dart';
import '../../crop_details/screens/crop_details_screen.dart';
import '../../crop_register/screens/crop_register_screen.dart';
import '../../crop_tracking/screens/crop_tracking_screen.dart';
import '../../crop_tracking/services/crop_tracking_service.dart';
import '../widgets/dashboard_summary_card.dart';
import 'next_milestone_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final weather = store.weather;
    final recommended = store.recommendedCropItems;
    final featuredRecommended = recommended.take(3).toList();

    return Scaffold(
      backgroundColor: AppColors.screenBackground(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context, store),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _todayOverviewCard(context, store),
                  const SizedBox(height: 16),
                  _priorityActionsCard(context, store),
                  const SizedBox(height: 16),
                  _quickActionsCard(context),
                  const SizedBox(height: 16),
                  _climateAppliedCard(context, store),
                  const SizedBox(height: 16),
                  DashboardSummaryCard(
                    title: 'Temporada actual',
                    subtitle: 'Recomendación dinámica',
                    icon: Icons.eco_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          store.currentSeason,
                          style: TextStyle(
                            color: AppColors.greenText(context),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.subtleBackground(context),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.border(context),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ranking sugerido para sembrar ahora',
                                style: TextStyle(
                                  color: AppColors.mutedText(context),
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
                                foregroundColor: AppColors.greenText(context),
                                side: BorderSide(
                                  color: AppColors.greenText(context),
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
                          context,
                          'Cultivos activos',
                          store.activeCropsCount.toString(),
                        ),
                        _metricRow(
                          context,
                          'Superficie total',
                          '${store.totalHectares.toStringAsFixed(1)} ha',
                        ),
                        _metricRow(
                          context,
                          'Eventos próximos',
                          store.upcomingEventsCount.toString(),
                        ),
                        if (store.nextPendingEventCrop != null)
                          _metricRow(
                            context,
                            'Próximo hito',
                            '${store.nextPendingEventCrop!.name}: ${CropTrackingService.buildSummary(store.nextPendingEventCrop!).nextEventLabel}',
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
                      backgroundColor: AppColors.isDark(context)
                          ? const Color(0xFF2A2412)
                          : const Color(0xFFFFFDE7),
                      child: Text(
                        weather.alerts.first,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.isDark(context)
                              ? const Color(0xFFFFE08A)
                              : const Color(0xFF856404),
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

  Widget _buildHeader(BuildContext context, AppStore store) {
    final topPadding = MediaQuery.paddingOf(context).top + 30;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, topPadding, 24, 40),
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
          Expanded(
            child: Column(
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
                    Expanded(
                      child: Text(
                        store.settings.locationName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 92,
            height: 92,
            child: Image.asset('assets/logos/cultiva_logo.png'),
          ),
        ],
      ),
    );
  }

  Widget _todayOverviewCard(BuildContext context, AppStore store) {
    final weather = store.weather;
    final nextCrop = store.nextPendingEventCrop;
    final nextSummary = nextCrop == null
        ? null
        : CropTrackingService.buildSummary(nextCrop);
    final bestCrop = store.recommendedCropItem;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.dashboard_customize,
                color: AppColors.greenText(context),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Panel de hoy',
                  style: TextStyle(
                    color: AppColors.greenText(context),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => MainNavigation.of(context)?.goToTab(3),
                child: const Text('Clima'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _overviewTile(
                  context,
                  icon: Icons.thermostat,
                  label: 'Clima',
                  value: weather == null
                      ? 'Sin datos'
                      : '${weather.temperatureC.toStringAsFixed(0)}°C',
                  detail: weather == null
                      ? store.settings.locationName
                      : 'Lluvia ${weather.rainProbability}%',
                  color: const Color(0xFF1565C0),
                  background: const Color(0xFFE3F2FD),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _overviewTile(
                  context,
                  icon: Icons.event_available,
                  label: 'Próximo hito',
                  value: nextSummary?.nextEventLabel ?? 'Sin tareas',
                  detail: nextCrop?.name ?? 'Registra un cultivo',
                  color: const Color(0xFFEF6C00),
                  background: const Color(0xFFFFF3E0),
                  onTap: nextCrop == null
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  NextMilestoneScreen(crop: nextCrop),
                            ),
                          );
                        },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CropDetailsScreen(id: bestCrop.id),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.subtleBackground(context),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border(context)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: bestCrop.badgeColor.withValues(
                      alpha: 0.14,
                    ),
                    child: Icon(bestCrop.icon, color: bestCrop.badgeColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mejor opción para revisar',
                          style: TextStyle(
                            color: AppColors.mutedText(context),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '${bestCrop.name} · ${bestCrop.sowingWindow}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.greenText(context),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.greenText(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickActionsCard(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _quickAction(
                context,
                icon: Icons.add_circle_outline,
                label: 'Registrar',
                color: AppColors.greenText(context),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CropRegisterScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _quickAction(
                context,
                icon: Icons.calendar_month_outlined,
                label: 'Calendario',
                color: AppColors.greenText(context),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AgriculturalCalendarScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _quickAction(
                context,
                icon: Icons.spa_outlined,
                label: 'Catálogo',
                color: AppColors.greenText(context),
                onTap: () => MainNavigation.of(context)?.goToTab(2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _quickAction(
                context,
                icon: Icons.cloud_outlined,
                label: 'Clima',
                color: const Color.fromARGB(255, 90, 167, 255),
                onTap: () => MainNavigation.of(context)?.goToTab(3),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _priorityActionsCard(BuildContext context, AppStore store) {
    final priorityItems = AgriculturalAdvisoryService.priorityItems(
      store.crops,
      daysAhead: 7,
    );

    return DashboardSummaryCard(
      title: 'Acciones prioritarias',
      subtitle: 'Qué atender primero esta semana',
      icon: Icons.bolt_outlined,
      child: priorityItems.isEmpty
          ? Text(
              'No hay eventos urgentes. Revisa calendario para planear las siguientes labores.',
              style: TextStyle(color: AppColors.mutedText(context)),
            )
          : Column(
              children: [
                ...priorityItems
                    .take(3)
                    .map((item) => _priorityActionTile(context, item)),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AgriculturalCalendarScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: const Text('Abrir calendario agrícola'),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _priorityActionTile(
    BuildContext context,
    AgriculturalCalendarItem item,
  ) {
    final color = item.isOverdue
        ? Colors.redAccent
        : item.isToday
        ? const Color(0xFFEF6C00)
        : const Color(0xFFF59E0B);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CropTrackingScreen(crop: item.crop),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withValues(
              alpha: AppColors.isDark(context) ? 0.12 : 0.08,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withValues(alpha: 0.28)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.16),
                child: Icon(item.event.icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.event.task,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.primaryText(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${item.crop.name} • ${item.urgencyLabel}',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: color),
            ],
          ),
        ),
      ),
    );
  }

  Widget _climateAppliedCard(BuildContext context, AppStore store) {
    final advisories = AgriculturalAdvisoryService.weatherAdvisories(
      crops: store.crops,
      weather: store.weather,
    );

    return DashboardSummaryCard(
      title: 'Clima aplicado al cultivo',
      subtitle: AgriculturalAdvisoryService.monthSignal(DateTime.now()),
      icon: Icons.cloud_sync_outlined,
      child: Column(
        children: advisories
            .take(3)
            .map(
              (advisory) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: advisory.color.withValues(alpha: 0.14),
                      child: Icon(advisory.icon, color: advisory.color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            advisory.title,
                            style: TextStyle(
                              color: AppColors.primaryText(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            advisory.detail,
                            style: TextStyle(
                              color: AppColors.mutedText(context),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _overviewTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required String detail,
    required Color color,
    required Color background,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 124),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.isDark(context)
                ? color.withValues(alpha: 0.12)
                : background,
            borderRadius: BorderRadius.circular(18),
            border: AppColors.isDark(context)
                ? Border.all(color: color.withValues(alpha: 0.26))
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color),
                  const Spacer(),
                  if (onTap != null)
                    Icon(Icons.chevron_right, color: color, size: 20),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.mutedText(context),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                detail,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.mutedText(context),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 82),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: AppColors.mutedText(context)),
            ),
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
            color: AppColors.cardBackground(context),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border(context)),
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
                            color: AppColors.greenIconBackground(context),
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
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.greenText(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${item.sowingWindow} • ${item.cycleDays} días',
                      style: TextStyle(color: AppColors.mutedText(context)),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.greenText(context)),
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
      backgroundColor: AppColors.screenBackground(context),
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
                Text(
                  'Ordenados por temporada actual y ventana de siembra.',
                  style: TextStyle(color: AppColors.mutedText(context)),
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
