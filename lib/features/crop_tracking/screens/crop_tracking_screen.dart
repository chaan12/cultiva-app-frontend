import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/models/crop_record.dart';
import '../../../shared/services/advisory/agricultural_advisory_service.dart';
import '../../../shared/services/audio/cultiva_sound_service.dart';
import '../../../shared/state/app_scope.dart';
import '../../../shared/widgets/cultiva_snackbar.dart';
import '../models/crop_tracking_models.dart';
import '../services/crop_tracking_service.dart';

import '../../my_crops/screens/crop_edit_screen.dart';

class CropTrackingScreen extends StatefulWidget {
  const CropTrackingScreen({super.key, required this.crop});

  final CropRecord crop;

  @override
  State<CropTrackingScreen> createState() => _CropTrackingScreenState();
}

class _CropTrackingScreenState extends State<CropTrackingScreen> {
  late CropRecord _crop;
  bool notifications = true;
  String activeTab = 'timeline';

  @override
  void initState() {
    super.initState();
    _crop = widget.crop;
  }

  CropTrackingPlan get _plan => CropTrackingService.buildPlan(_crop);

  @override
  Widget build(BuildContext context) {
    final plan = _plan;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(plan),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildNotificationToggle(),
                    const SizedBox(height: 20),
                    _buildTabSelector(),
                    const SizedBox(height: 20),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: activeTab == 'events'
                          ? _buildEventsList(plan.upcomingEvents)
                          : activeTab == 'history'
                          ? _buildCropHistory()
                          : _buildTimeline(plan.timelineStages),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(CropTrackingPlan plan) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, topPadding, 24, 40),
      decoration: const BoxDecoration(
        color: Color(0xFF0D5D33),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.chevron_left,
                  color: Colors.white,
                  size: 32,
                ),
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
              ),
              IconButton(
                onPressed: _editCrop,
                icon: const Icon(
                  Icons.edit_outlined,
                  color: Colors.white,
                  size: 28,
                ),
                tooltip: 'Editar cultivo',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _crop.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${_crop.formattedArea} • Día ${_crop.daysSinceSowing}/${_crop.cycleDays}',
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          Text(
            _crop.locationName,
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
          const SizedBox(height: 25),
          Container(
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
                    Expanded(
                      child: Text(
                        plan.currentStage,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      '${plan.progress}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: plan.progress / 100,
                    backgroundColor: Colors.white24,
                    color: Colors.white,
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${plan.daysToHarvest} días hasta cosecha estimada',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editCrop() async {
    final updated = await Navigator.push<CropRecord>(
      context,
      MaterialPageRoute(builder: (_) => CropEditScreen(crop: _crop)),
    );
    if (updated != null && mounted) {
      setState(() => _crop = updated);
    }
  }

  Widget _buildNotificationToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: notifications
                ? AppColors.greenIconBackground(context)
                : AppColors.subtleBackground(context),
            child: Icon(
              notifications
                  ? Icons.notifications_active
                  : Icons.notifications_off,
              color: notifications
                  ? AppColors.greenText(context)
                  : AppColors.mutedText(context),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notificaciones',
                  style: TextStyle(
                    color: AppColors.primaryText(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  notifications ? 'Alertas activas' : 'Alertas desactivadas',
                  style: TextStyle(
                    color: AppColors.mutedText(context),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: notifications,
            onChanged: (value) {
              unawaited(CultivaSoundService.selection(context));
              setState(() => notifications = value);
            },
            activeThumbColor: const Color(0xFF00C853),
            activeTrackColor: const Color(0xFF00C853).withValues(alpha: 0.35),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _tabButton('events', Icons.bolt, 'Eventos'),
          _tabButton('timeline', Icons.auto_graph, 'Ciclo'),
          _tabButton('history', Icons.history, 'Historial'),
        ],
      ),
    );
  }

  Widget _tabButton(String id, IconData icon, String label) {
    final isSelected = activeTab == id;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (activeTab == id) {
            return;
          }
          unawaited(CultivaSoundService.selection(context));
          setState(() => activeTab = id);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0D5D33) : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.mutedText(context),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : AppColors.mutedText(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventsList(List<CropUpcomingEvent> events) {
    String? nextPendingEventId;
    for (final event in events) {
      if (!event.completed) {
        nextPendingEventId = event.id;
        break;
      }
    }

    return Column(
      key: const ValueKey('events_list'),
      children: events
          .map(
            (event) =>
                _eventCard(event, canComplete: event.id == nextPendingEventId),
          )
          .toList(),
    );
  }

  Widget _eventCard(CropUpcomingEvent event, {required bool canComplete}) {
    if (event.completed) {
      return _completedEventCard(event);
    }

    final priorityColor = event.priority == 'high'
        ? Colors.redAccent
        : Colors.amber[700]!;
    final card = Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: priorityColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: priorityColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(event.icon, color: priorityColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.task,
                    style: TextStyle(
                      color: AppColors.primaryText(context),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    event.description,
                    style: TextStyle(
                      color: AppColors.mutedText(context),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    event.daysUntil <= 0
                        ? 'Programado para hoy'
                        : 'En ${event.daysUntil} días • ${event.date}',
                    style: TextStyle(
                      color: priorityColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (canComplete) ...[
              const SizedBox(width: 12),
              Icon(
                Icons.swipe_left_alt_rounded,
                color: priorityColor.withValues(alpha: 0.7),
              ),
            ],
          ],
        ),
      ),
    );

    if (!canComplete) {
      return card;
    }

    return Dismissible(
      key: ValueKey('event-${event.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF0D5D33),
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.check_circle_outline, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        await _markEventCompleted(event);
        return false;
      },
      child: card,
    );
  }

  Widget _completedEventCard(CropUpcomingEvent event) {
    final card = Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.subtleBackground(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.border(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.check_circle_outline,
              color: AppColors.mutedText(context),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.task,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.mutedText(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  event.userCompleted
                      ? 'Concluido manualmente • ${event.date}'
                      : 'Concluido por fecha • ${event.date}',
                  style: TextStyle(
                    color: AppColors.mutedText(context),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (!event.userCompleted) {
      return card;
    }

    return GestureDetector(
      onLongPress: () => _showRestoreEventSheet(event),
      child: card,
    );
  }

  Future<void> _markEventCompleted(CropUpcomingEvent event) async {
    final updatedCrop = await AppScope.of(
      context,
    ).markCropEventCompleted(_crop.id, event.id);
    if (!mounted || updatedCrop == null) {
      return;
    }
    setState(() => _crop = updatedCrop);
    showCultivaSnackBar(
      context,
      message: 'Evento marcado como concluido.',
      color: const Color(0xFF0D5D33),
      icon: Icons.check_circle_outline,
    );
  }

  void _showRestoreEventSheet(CropUpcomingEvent event) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cardBackground(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.border(context),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  event.task,
                  style: TextStyle(
                    color: AppColors.primaryText(context),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Este evento está marcado como concluido.',
                  style: TextStyle(color: AppColors.mutedText(context)),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _restoreEventPending(event);
                    },
                    icon: const Icon(Icons.undo_rounded),
                    label: const Text('Volver a pendiente'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _restoreEventPending(CropUpcomingEvent event) async {
    final updatedCrop = await AppScope.of(
      context,
    ).unmarkCropEventCompleted(_crop.id, event.id);
    if (!mounted || updatedCrop == null) {
      return;
    }
    setState(() => _crop = updatedCrop);
    showCultivaSnackBar(
      context,
      message: 'Evento devuelto a pendiente.',
      color: const Color(0xFF0D5D33),
      icon: Icons.undo_rounded,
    );
  }

  Widget _buildCropHistory() {
    final items = AgriculturalAdvisoryService.historyItems(_crop);

    return Container(
      key: const ValueKey('crop_history_view'),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, color: AppColors.greenText(context)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Historial del cultivo',
                  style: TextStyle(
                    color: AppColors.greenText(context),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Eventos concluidos por fecha o marcados manualmente.',
            style: TextStyle(color: AppColors.mutedText(context), height: 1.35),
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            Text(
              'Todavía no hay eventos concluidos para este cultivo.',
              style: TextStyle(color: AppColors.mutedText(context)),
            )
          else
            ...items.map(_historyItem),
        ],
      ),
    );
  }

  Widget _historyItem(AgriculturalCalendarItem item) {
    final isManual = item.event.userCompleted;
    final color = isManual
        ? const Color(0xFF0D5D33)
        : AppColors.mutedText(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.subtleBackground(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.14),
            child: Icon(
              isManual ? Icons.task_alt : Icons.event_available_outlined,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.event.task,
                  style: TextStyle(
                    color: AppColors.primaryText(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${isManual ? 'Marcado manualmente' : 'Concluido por fecha'} • ${item.event.date}',
                  style: TextStyle(color: color, fontWeight: FontWeight.w700),
                ),
                Text(
                  item.event.description,
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
    );
  }

  Widget _buildTimeline(List<CropTimelineStage> stages) {
    return Container(
      key: const ValueKey('timeline_view'),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Línea de tiempo del cultivo',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.greenText(context),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Etapas fenológicas calculadas con base en los días transcurridos del cultivo.',
            style: TextStyle(color: AppColors.mutedText(context), height: 1.4),
          ),
          const SizedBox(height: 25),
          ...stages.asMap().entries.map(
            (entry) =>
                _timelineItem(entry.value, entry.key == stages.length - 1),
          ),
        ],
      ),
    );
  }

  Widget _timelineItem(CropTimelineStage stage, bool isLast) {
    final isCompleted = stage.completed;
    final isCurrent = stage.current;
    final isDark = AppColors.isDark(context);
    final iconBgColor = isCompleted
        ? const Color(0xFF7CB342)
        : (isCurrent
              ? const Color(0xFF33691E)
              : AppColors.subtleBackground(context));
    final iconColor = isCurrent || isCompleted
        ? Colors.white
        : AppColors.mutedText(context);
    final connectorColor = isCompleted
        ? const Color(0xFF7CB342)
        : (isDark ? AppColors.border(context) : Colors.grey.shade200);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: !isCurrent && !isCompleted
                      ? Border.all(color: AppColors.border(context))
                      : null,
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.25 : 0.08,
                            ),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Icon(stage.icon, color: iconColor, size: 24),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 4,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: connectorColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          stage.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isCurrent || isCompleted
                                ? AppColors.greenText(context)
                                : AppColors.primaryText(context),
                          ),
                        ),
                      ),
                      if (isCurrent && stage.daysRemaining != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D4B2D),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '${stage.daysRemaining}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const Text(
                                'días',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    stage.date,
                    style: TextStyle(
                      color: AppColors.greenText(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    stage.description,
                    style: TextStyle(
                      color: AppColors.mutedText(context),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
