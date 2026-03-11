import 'package:flutter/material.dart';

import '../../../shared/models/crop_record.dart';
import '../models/crop_tracking_models.dart';
import '../services/crop_tracking_service.dart';

class CropTrackingScreen extends StatefulWidget {
  const CropTrackingScreen({super.key, required this.crop});

  final CropRecord crop;

  @override
  State<CropTrackingScreen> createState() => _CropTrackingScreenState();
}

class _CropTrackingScreenState extends State<CropTrackingScreen> {
  bool notifications = true;
  String activeTab = 'timeline';

  CropTrackingPlan get _plan => CropTrackingService.buildPlan(widget.crop);

  @override
  Widget build(BuildContext context) {
    final plan = _plan;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4E0),
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
                        : _buildTimeline(plan.timelineStages),
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

  Widget _buildHeader(CropTrackingPlan plan) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
      decoration: const BoxDecoration(
        color: Color(0xFF0D5D33),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.chevron_left, color: Colors.white, size: 32),
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
          ),
          const SizedBox(height: 10),
          Text(
            widget.crop.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${widget.crop.formattedArea} • Día ${widget.crop.daysSinceSowing}/${widget.crop.cycleDays}',
            style: const TextStyle(color: Colors.white70, fontSize: 16),
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

  Widget _buildNotificationToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: notifications
                ? const Color(0xFFE8F5E9)
                : Colors.grey[100],
            child: Icon(
              notifications
                  ? Icons.notifications_active
                  : Icons.notifications_off,
              color: notifications ? const Color(0xFF0D5D33) : Colors.grey,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notificaciones',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  notifications ? 'Alertas activas' : 'Alertas desactivadas',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: notifications,
            onChanged: (value) => setState(() => notifications = value),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _tabButton('events', Icons.bolt, 'Eventos'),
          _tabButton('timeline', Icons.auto_graph, 'Ciclo'),
        ],
      ),
    );
  }

  Widget _tabButton(String id, IconData icon, String label) {
    final isSelected = activeTab == id;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => activeTab = id),
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
                color: isSelected ? Colors.white : Colors.grey,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
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
    return Column(
      key: const ValueKey('events_list'),
      children: events.map(_eventCard).toList(),
    );
  }

  Widget _eventCard(CropUpcomingEvent event) {
    final priorityColor = event.priority == 'high'
        ? Colors.redAccent
        : Colors.amber[700]!;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    event.description,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
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
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(List<CropTimelineStage> stages) {
    return Container(
      key: const ValueKey('timeline_view'),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Línea de tiempo del cultivo',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D5D33),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Etapas fenológicas calculadas con base en los días transcurridos del cultivo.',
            style: TextStyle(color: Colors.grey, height: 1.4),
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
    final iconBgColor = isCompleted
        ? const Color(0xFF7CB342)
        : (isCurrent ? const Color(0xFF33691E) : Colors.white);
    final iconColor = isCurrent || isCompleted ? Colors.white : Colors.grey;
    final connectorColor = isCompleted
        ? const Color(0xFF7CB342)
        : Colors.grey.shade200;

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
                      ? Border.all(color: Colors.grey.shade200)
                      : null,
                  boxShadow: isCurrent
                      ? const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 4),
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
                                ? const Color(0xFF2E7D32)
                                : Colors.black54,
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
                    style: const TextStyle(
                      color: Color(0xFF0D5D33),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    stage.description,
                    style: const TextStyle(color: Colors.grey, height: 1.4),
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
