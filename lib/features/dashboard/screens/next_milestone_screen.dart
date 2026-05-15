import 'package:flutter/material.dart';

import '../../../shared/models/crop_record.dart';
import '../../crop_tracking/models/crop_tracking_models.dart';
import '../../crop_tracking/screens/crop_tracking_screen.dart';
import '../../crop_tracking/services/crop_tracking_service.dart';

class NextMilestoneScreen extends StatelessWidget {
  const NextMilestoneScreen({super.key, required this.crop});

  final CropRecord crop;

  @override
  Widget build(BuildContext context) {
    final plan = CropTrackingService.buildPlan(crop);
    final event = plan.upcomingEvents.isNotEmpty
        ? plan.upcomingEvents.first
        : null;
    final priorityColor = event == null
        ? const Color(0xFF0D5D33)
        : _priorityColor(event);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4E0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context, plan, event, priorityColor),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 34),
              child: Column(
                children: [
                  _buildMilestoneCard(event, priorityColor),
                  const SizedBox(height: 16),
                  _buildCropStatusCard(plan),
                  const SizedBox(height: 16),
                  _buildActionGuide(event, priorityColor),
                  const SizedBox(height: 16),
                  _buildTimelineButton(context),
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
    CropTrackingPlan plan,
    CropUpcomingEvent? event,
    Color priorityColor,
  ) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
      child: SizedBox(
        width: double.infinity,
        height: 360,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              crop.imageAsset,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(color: priorityColor),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.18),
                    Colors.black.withValues(alpha: 0.46),
                    const Color(0xFF0D5D33).withValues(alpha: 0.92),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 54, 20, 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton.filledTonal(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.chevron_left),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.30),
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: priorityColor.withValues(alpha: 0.90),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      event == null
                          ? 'Sin hito pendiente'
                          : _urgencyText(event),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    crop.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event?.task ?? 'No hay eventos próximos registrados',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${crop.formattedArea} • ${plan.progress}% del ciclo • ${crop.locationName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestoneCard(CropUpcomingEvent? event, Color priorityColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: event == null
          ? const Text(
              'Este cultivo no tiene eventos pendientes por ahora.',
              style: TextStyle(fontWeight: FontWeight.w700),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: priorityColor.withValues(alpha: 0.12),
                      child: Icon(event.icon, color: priorityColor, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.task,
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0D5D33),
                            ),
                          ),
                          Text(
                            event.date,
                            style: TextStyle(
                              color: priorityColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  event.description,
                  style: const TextStyle(color: Colors.black87, height: 1.42),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _smallFact(
                        label: 'Tiempo',
                        value: event.daysUntil <= 0
                            ? 'Hoy'
                            : '${event.daysUntil} días',
                        color: priorityColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _smallFact(
                        label: 'Prioridad',
                        value: event.priority == 'high' ? 'Alta' : 'Media',
                        color: priorityColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _smallFact(
                        label: 'Tipo',
                        value: event.required ? 'Clave' : 'Opcional',
                        color: priorityColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildCropStatusCard(CropTrackingPlan plan) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estado del cultivo',
            style: TextStyle(
              color: Color(0xFF0D5D33),
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          _statusRow('Etapa actual', plan.currentStage),
          _statusRow(
            'Día del ciclo',
            '${crop.daysSinceSowing}/${crop.cycleDays}',
          ),
          _statusRow(
            'Cosecha estimada',
            '${plan.daysToHarvest} días restantes',
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: plan.progress / 100,
              minHeight: 12,
              backgroundColor: const Color(0xFFE8F5E9),
              color: const Color(0xFF00A344),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionGuide(CropUpcomingEvent? event, Color priorityColor) {
    final actions = _actionsFor(event);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Qué revisar',
            style: TextStyle(
              color: Color(0xFF0D5D33),
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          ...actions.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle, color: priorityColor, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(item, style: const TextStyle(height: 1.35)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CropTrackingScreen(crop: crop)),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0D5D33),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      icon: const Icon(Icons.auto_graph, color: Colors.white),
      label: const Text(
        'Ver seguimiento completo',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _smallFact({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color, fontWeight: FontWeight.w900),
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
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.black54)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFFE2E9D8)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 14,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  Color _priorityColor(CropUpcomingEvent event) {
    if (event.daysUntil <= 1 || event.priority == 'high') {
      return Colors.redAccent;
    }
    return const Color(0xFFEF6C00);
  }

  String _urgencyText(CropUpcomingEvent event) {
    if (event.daysUntil <= 0) {
      return 'Programado para hoy';
    }
    if (event.daysUntil == 1) {
      return 'Mañana';
    }
    return 'En ${event.daysUntil} días';
  }

  List<String> _actionsFor(CropUpcomingEvent? event) {
    if (event == null) {
      return const <String>[
        'Revisa el estado general del cultivo una vez por semana.',
        'Mantén registro de riego, plagas y labores realizadas.',
      ];
    }
    final text = '${event.task} ${event.description}'.toLowerCase();
    if (text.contains('riego') || text.contains('humedad')) {
      return const <String>[
        'Verifica humedad del suelo antes de aplicar agua.',
        'Evita encharcamientos y ajusta el riego según lluvia reciente.',
        'Registra la lámina o duración del riego aplicado.',
      ];
    }
    if (text.contains('fertiliz')) {
      return const <String>[
        'Confirma dosis y fuente antes de aplicar.',
        'Aplica con humedad suficiente para mejorar absorción.',
        'Registra fecha, producto y cantidad aplicada.',
      ];
    }
    if (text.contains('plaga') ||
        text.contains('sanitario') ||
        text.contains('monitoreo')) {
      return const <String>[
        'Revisa hojas, tallos y frutos en varios puntos del lote.',
        'Anota presencia de daño, insectos o síntomas de enfermedad.',
        'Toma fotos para comparar evolución en la siguiente visita.',
      ];
    }
    if (text.contains('cosecha')) {
      return const <String>[
        'Revisa madurez, humedad y uniformidad del lote.',
        'Prepara herramientas, transporte y mano de obra.',
        'Define fecha de corte según clima y destino del producto.',
      ];
    }
    return const <String>[
      'Recorre el lote y revisa varias plantas representativas.',
      'Registra observaciones y cualquier cambio importante.',
      'Compara el avance con la etapa actual del cultivo.',
    ];
  }
}
