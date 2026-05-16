import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/services/agricultural_advisory_service.dart';
import '../../../shared/state/app_scope.dart';

class AgriculturalCalendarScreen extends StatefulWidget {
  const AgriculturalCalendarScreen({super.key});

  @override
  State<AgriculturalCalendarScreen> createState() =>
      _AgriculturalCalendarScreenState();
}

class _AgriculturalCalendarScreenState
    extends State<AgriculturalCalendarScreen> {
  late DateTime _visibleMonth;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
    _selectedDay = DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final items = AgriculturalAdvisoryService.calendarItems(store.crops);
    final monthItems = _itemsInMonth(items, _visibleMonth);
    final selectedItems = _itemsOnDay(items, _selectedDay);
    final priorityItems = AgriculturalAdvisoryService.priorityItems(
      store.crops,
      daysAhead: 15,
    );
    final advisories = AgriculturalAdvisoryService.weatherAdvisories(
      crops: store.crops,
      weather: store.weather,
    );

    return Scaffold(
      backgroundColor: AppColors.screenBackground(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context, monthItems, priorityItems),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMonthControls(context),
                  const SizedBox(height: 14),
                  _buildMonthGrid(context, monthItems),
                  const SizedBox(height: 18),
                  _buildSelectedDayAgenda(context, selectedItems),
                  const SizedBox(height: 18),
                  _buildPriorityAgenda(context, priorityItems),
                  const SizedBox(height: 18),
                  _buildClimateBlock(context, advisories),
                  const SizedBox(height: 18),
                  _buildLegend(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    List<AgriculturalCalendarItem> monthItems,
    List<AgriculturalCalendarItem> priorityItems,
  ) {
    final topPadding = MediaQuery.paddingOf(context).top + 30;
    final completedCount = monthItems
        .where((item) => item.event.completed)
        .length;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPadding, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D5D33), Color(0xFF246B45)],
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
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.chevron_left, color: Colors.white),
                tooltip: 'Regresar',
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.notifications_active, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      'Alertas',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Calendario agrícola',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Agenda de labores, riesgos y eventos por cultivo.',
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _headerMetric(
                  '${monthItems.length}',
                  'Eventos del mes',
                  Icons.calendar_month,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _headerMetric(
                  '${priorityItems.length}',
                  'Próximos 15 días',
                  Icons.bolt,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _headerMetric(
                  '$completedCount',
                  'Concluidos',
                  Icons.check_circle_outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerMetric(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthControls(BuildContext context) {
    return Row(
      children: [
        IconButton.filledTonal(
          onPressed: () => _shiftMonth(-1),
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Text(
            toBeginningOfSentenceCase(
              DateFormat('MMMM yyyy', 'es_MX').format(_visibleMonth),
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        IconButton.filledTonal(
          onPressed: () => _shiftMonth(1),
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Widget _buildMonthGrid(
    BuildContext context,
    List<AgriculturalCalendarItem> monthItems,
  ) {
    final firstDay = DateTime(_visibleMonth.year, _visibleMonth.month);
    final leading = firstDay.weekday - 1;
    final daysInMonth = DateUtils.getDaysInMonth(
      _visibleMonth.year,
      _visibleMonth.month,
    );
    final totalCells = ((leading + daysInMonth + 6) ~/ 7) * 7;
    const weekdays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        children: [
          Row(
            children: weekdays
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          color: AppColors.mutedText(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalCells,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemBuilder: (context, index) {
              final dayNumber = index - leading + 1;
              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const SizedBox.shrink();
              }
              final date = DateTime(
                _visibleMonth.year,
                _visibleMonth.month,
                dayNumber,
              );
              final dayItems = _itemsOnDay(monthItems, date);
              return _dayCell(context, date, dayItems);
            },
          ),
        ],
      ),
    );
  }

  Widget _dayCell(
    BuildContext context,
    DateTime date,
    List<AgriculturalCalendarItem> dayItems,
  ) {
    final selected = DateUtils.isSameDay(date, _selectedDay);
    final today = DateUtils.isSameDay(date, DateTime.now());
    final hasHigh = dayItems.any((item) => item.event.priority == 'high');
    final completed =
        dayItems.isNotEmpty && dayItems.every((i) => i.event.completed);
    final color = completed
        ? AppColors.mutedText(context)
        : hasHigh
        ? Colors.redAccent
        : const Color(0xFFF59E0B);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => setState(() => _selectedDay = date),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.greenText(context)
              : today
              ? AppColors.greenIconBackground(context)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: dayItems.isEmpty ? null : Border.all(color: color),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: TextStyle(
                color: selected ? Colors.white : AppColors.primaryText(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            if (dayItems.isNotEmpty)
              Container(
                width: 18,
                height: 5,
                decoration: BoxDecoration(
                  color: selected ? Colors.white : color,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDayAgenda(
    BuildContext context,
    List<AgriculturalCalendarItem> items,
  ) {
    return _sectionCard(
      context,
      title: DateUtils.isSameDay(_selectedDay, DateTime.now())
          ? 'Agenda de hoy'
          : DateFormat('d MMMM yyyy', 'es_MX').format(_selectedDay),
      icon: Icons.event_note_outlined,
      child: items.isEmpty
          ? _emptyText(context, 'No hay eventos programados para este día.')
          : Column(
              children: items.map((item) => _eventTile(context, item)).toList(),
            ),
    );
  }

  Widget _buildPriorityAgenda(
    BuildContext context,
    List<AgriculturalCalendarItem> items,
  ) {
    return _sectionCard(
      context,
      title: 'Próximas acciones',
      icon: Icons.bolt_outlined,
      child: items.isEmpty
          ? _emptyText(
              context,
              'Sin eventos pendientes en los próximos 15 días.',
            )
          : Column(
              children: items
                  .take(8)
                  .map((item) => _eventTile(context, item, dense: true))
                  .toList(),
            ),
    );
  }

  Widget _buildClimateBlock(
    BuildContext context,
    List<CropWeatherAdvisory> advisories,
  ) {
    return _sectionCard(
      context,
      title: 'Clima aplicado',
      icon: Icons.cloud_sync_outlined,
      child: Column(
        children: advisories
            .take(4)
            .map(
              (advisory) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
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

  Widget _buildLegend(BuildContext context) {
    return _sectionCard(
      context,
      title: 'Lectura rápida',
      icon: Icons.info_outline,
      child: Column(
        children: [
          _legendRow(context, Colors.redAccent, 'Evento crítico o requerido'),
          _legendRow(context, const Color(0xFFF59E0B), 'Evento operativo'),
          _legendRow(context, AppColors.mutedText(context), 'Evento concluido'),
          const SizedBox(height: 8),
          Text(
            AgriculturalAdvisoryService.monthSignal(_visibleMonth),
            style: TextStyle(color: AppColors.mutedText(context), height: 1.35),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
              Icon(icon, color: AppColors.greenText(context)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppColors.greenText(context),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _eventTile(
    BuildContext context,
    AgriculturalCalendarItem item, {
    bool dense = false,
  }) {
    final color = item.event.completed
        ? AppColors.mutedText(context)
        : item.event.priority == 'high'
        ? Colors.redAccent
        : const Color(0xFFF59E0B);

    return Container(
      margin: EdgeInsets.only(bottom: dense ? 8 : 12),
      padding: EdgeInsets.all(dense ? 12 : 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppColors.isDark(context) ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            item.event.completed ? Icons.check_circle_outline : item.event.icon,
            color: color,
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
                  '${item.crop.name} • ${item.urgencyLabel}',
                  style: TextStyle(color: color, fontWeight: FontWeight.w700),
                ),
                if (!dense)
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

  Widget _emptyText(BuildContext context, String text) {
    return Text(text, style: TextStyle(color: AppColors.mutedText(context)));
  }

  Widget _legendRow(BuildContext context, Color color, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: AppColors.mutedText(context)),
            ),
          ),
        ],
      ),
    );
  }

  List<AgriculturalCalendarItem> _itemsInMonth(
    List<AgriculturalCalendarItem> items,
    DateTime month,
  ) {
    return items.where((item) {
      return item.date.year == month.year && item.date.month == month.month;
    }).toList();
  }

  List<AgriculturalCalendarItem> _itemsOnDay(
    List<AgriculturalCalendarItem> items,
    DateTime date,
  ) {
    return items.where((item) => DateUtils.isSameDay(item.date, date)).toList();
  }

  void _shiftMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
      _selectedDay = DateTime(_visibleMonth.year, _visibleMonth.month);
    });
  }
}
