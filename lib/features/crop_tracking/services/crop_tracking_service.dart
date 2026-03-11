import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/models/crop_record.dart';
import '../models/crop_tracking_models.dart';

class CropTrackingService {
  const CropTrackingService._();

  static CropTrackingPlan buildPlan(CropRecord crop) {
    final profile = _profiles[crop.cropId] ?? _profiles['maiz']!;
    final totalDays = crop.cycleDays;
    final elapsedDays = crop.daysSinceSowing.clamp(0, totalDays);
    final progress = totalDays == 0
        ? 0
        : ((elapsedDays / totalDays) * 100).clamp(0, 100).round();

    final timelineStages = profile.stages.map((stage) {
      final startDay = (stage.startFraction * totalDays).round();
      final endDay = math.max(
        startDay + 1,
        (stage.endFraction * totalDays).round(),
      );
      final isCompleted = elapsedDays >= endDay;
      final isCurrent = elapsedDays >= startDay && elapsedDays < endDay;
      return CropTimelineStage(
        name: stage.name,
        date: _formatDate(crop.sowingDate.add(Duration(days: startDay))),
        description: stage.description,
        completed: isCompleted,
        current: isCurrent,
        icon: stage.icon,
        daysRemaining: isCurrent ? math.max(endDay - elapsedDays, 0) : null,
      );
    }).toList();

    final currentStage = timelineStages.firstWhere(
      (stage) => stage.current,
      orElse: () => timelineStages.last,
    );

    final sortedEvents = profile.events.map((event) {
      final day = (event.dayFraction * totalDays).round();
      return CropUpcomingEvent(
        task: event.task,
        date: _formatDate(crop.sowingDate.add(Duration(days: day))),
        daysUntil: day - elapsedDays,
        priority: event.priority,
        icon: event.icon,
        description: event.description,
        required: event.required,
        completed: elapsedDays > day,
      );
    }).toList()..sort((a, b) => a.daysUntil.compareTo(b.daysUntil));

    final upcomingEvents = sortedEvents
        .where((event) => event.daysUntil >= -1)
        .take(6)
        .toList();
    final nextEvent = upcomingEvents.isNotEmpty ? upcomingEvents.first : null;
    final daysToHarvest = math.max(totalDays - elapsedDays, 0);

    final summary = CropTrackingSummary(
      currentStage: currentStage.name,
      nextEventLabel: nextEvent == null
          ? 'Sin eventos pendientes'
          : '${nextEvent.task} en ${math.max(nextEvent.daysUntil, 0)} día(s)',
      nextEventDays: nextEvent == null
          ? daysToHarvest
          : math.max(nextEvent.daysUntil, 0),
      status: daysToHarvest <= 7
          ? 'alerta'
          : (nextEvent != null && nextEvent.daysUntil <= 2
                ? 'evento-proximo'
                : 'normal'),
      progress: progress,
      daysToHarvest: daysToHarvest,
    );

    return CropTrackingPlan(
      currentStage: currentStage.name,
      progress: progress,
      daysToHarvest: daysToHarvest,
      timelineStages: timelineStages,
      upcomingEvents: upcomingEvents,
      summary: summary,
    );
  }

  static CropTrackingSummary buildSummary(CropRecord crop) {
    return buildPlan(crop).summary;
  }

  static String _formatDate(DateTime date) {
    try {
      return DateFormat('dd MMM yyyy', 'es_MX').format(date);
    } catch (_) {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  static const Map<String, _CropProfile> _profiles = <String, _CropProfile>{
    'maiz': _CropProfile(
      stages: <CropStageDefinition>[
        CropStageDefinition(
          name: 'Siembra y emergencia',
          description: 'Germinación y establecimiento inicial del cultivo.',
          startFraction: 0.0,
          endFraction: 0.08,
          icon: Icons.eco_outlined,
        ),
        CropStageDefinition(
          name: 'Desarrollo foliar',
          description: 'Formación acelerada de hojas y raíces adventicias.',
          startFraction: 0.08,
          endFraction: 0.24,
          icon: Icons.grass_rounded,
        ),
        CropStageDefinition(
          name: 'Crecimiento vegetativo',
          description: 'Alargamiento del tallo y máxima demanda de nitrógeno.',
          startFraction: 0.24,
          endFraction: 0.45,
          icon: Icons.trending_up,
        ),
        CropStageDefinition(
          name: 'Espigamiento y floración',
          description: 'Emisión de espiga y polinización, etapa crítica.',
          startFraction: 0.45,
          endFraction: 0.60,
          icon: Icons.wb_sunny_outlined,
        ),
        CropStageDefinition(
          name: 'Llenado de grano',
          description: 'Acumulación de materia seca en el grano.',
          startFraction: 0.60,
          endFraction: 0.83,
          icon: Icons.grain,
        ),
        CropStageDefinition(
          name: 'Madurez fisiológica',
          description: 'Secado final de mazorca y preparación de cosecha.',
          startFraction: 0.83,
          endFraction: 1.0,
          icon: Icons.check_circle_outline,
        ),
      ],
      events: <CropEventDefinition>[
        CropEventDefinition(
          task: 'Revisión de nascencia',
          description: 'Validar uniformidad y porcentaje de emergencia.',
          dayFraction: 0.05,
          icon: Icons.search,
          priority: 'high',
          required: true,
        ),
        CropEventDefinition(
          task: 'Control inicial de maleza',
          description: 'Evitar competencia temprana por agua y nutrientes.',
          dayFraction: 0.14,
          icon: Icons.content_cut,
          priority: 'medium',
          required: true,
        ),
        CropEventDefinition(
          task: 'Fertilización de cobertura',
          description: 'Aplicar nitrógeno en crecimiento activo.',
          dayFraction: 0.28,
          icon: Icons.compost_outlined,
          priority: 'high',
          required: true,
        ),
        CropEventDefinition(
          task: 'Monitoreo de cogollero',
          description: 'Inspección de hojas y cogollo por daño de plaga.',
          dayFraction: 0.36,
          icon: Icons.bug_report_outlined,
          priority: 'high',
          required: true,
        ),
        CropEventDefinition(
          task: 'Riego o lámina suplementaria',
          description: 'Mantener humedad adecuada previo a floración.',
          dayFraction: 0.48,
          icon: Icons.water_drop_outlined,
          priority: 'high',
          required: true,
        ),
        CropEventDefinition(
          task: 'Programar cosecha',
          description: 'Ajustar fecha de corte y logística de recolección.',
          dayFraction: 0.92,
          icon: Icons.agriculture_outlined,
          priority: 'medium',
          required: true,
        ),
      ],
    ),
    'tomate': _CropProfile(
      stages: <CropStageDefinition>[
        CropStageDefinition(
          name: 'Trasplante y prendimiento',
          description: 'Recuperación inicial y emisión de raíces.',
          startFraction: 0.0,
          endFraction: 0.10,
          icon: Icons.local_florist_outlined,
        ),
        CropStageDefinition(
          name: 'Crecimiento vegetativo',
          description: 'Desarrollo de follaje y poda/entutorado.',
          startFraction: 0.10,
          endFraction: 0.28,
          icon: Icons.park_outlined,
        ),
        CropStageDefinition(
          name: 'Floración',
          description: 'Emisión de racimos florales y manejo nutricional.',
          startFraction: 0.28,
          endFraction: 0.45,
          icon: Icons.wb_sunny_outlined,
        ),
        CropStageDefinition(
          name: 'Cuajado de fruto',
          description: 'Inicio del fruto y alto consumo de potasio.',
          startFraction: 0.45,
          endFraction: 0.62,
          icon: Icons.circle_outlined,
        ),
        CropStageDefinition(
          name: 'Engorde y maduración',
          description: 'Crecimiento del fruto y cambio de color.',
          startFraction: 0.62,
          endFraction: 0.88,
          icon: Icons.local_pizza_outlined,
        ),
        CropStageDefinition(
          name: 'Cosecha escalonada',
          description: 'Cortes sucesivos según firmeza y color.',
          startFraction: 0.88,
          endFraction: 1.0,
          icon: Icons.shopping_basket_outlined,
        ),
      ],
      events: <CropEventDefinition>[
        CropEventDefinition(
          task: 'Primer riego de establecimiento',
          description: 'Asegurar prendimiento tras el trasplante.',
          dayFraction: 0.03,
          icon: Icons.water_drop_outlined,
          priority: 'high',
          required: true,
        ),
        CropEventDefinition(
          task: 'Entutorado y poda baja',
          description: 'Guiar crecimiento y mejorar ventilación.',
          dayFraction: 0.16,
          icon: Icons.vertical_align_top,
          priority: 'medium',
          required: true,
        ),
        CropEventDefinition(
          task: 'Fertilización rica en potasio',
          description: 'Preparar la planta para floración y cuajado.',
          dayFraction: 0.34,
          icon: Icons.compost_outlined,
          priority: 'high',
          required: true,
        ),
        CropEventDefinition(
          task: 'Monitoreo de mosca blanca',
          description: 'Revisar envés de hojas y aplicar control oportuno.',
          dayFraction: 0.42,
          icon: Icons.bug_report_outlined,
          priority: 'high',
          required: true,
        ),
        CropEventDefinition(
          task: 'Ajuste de riego por fructificación',
          description: 'Evitar agrietamiento y estrés hídrico.',
          dayFraction: 0.60,
          icon: Icons.opacity_outlined,
          priority: 'high',
          required: true,
        ),
        CropEventDefinition(
          task: 'Inicio de corte comercial',
          description: 'Seleccionar frutos por color y firmeza.',
          dayFraction: 0.90,
          icon: Icons.shopping_cart_checkout,
          priority: 'medium',
          required: true,
        ),
      ],
    ),
    'sorgo': _CropProfile(
      stages: <CropStageDefinition>[
        CropStageDefinition(
          name: 'Siembra y emergencia',
          description: 'Establecimiento de plántulas y primeras hojas.',
          startFraction: 0.0,
          endFraction: 0.10,
          icon: Icons.eco_outlined,
        ),
        CropStageDefinition(
          name: 'Macollamiento',
          description: 'Desarrollo de tallos secundarios y cobertura.',
          startFraction: 0.10,
          endFraction: 0.25,
          icon: Icons.grass,
        ),
        CropStageDefinition(
          name: 'Elongación de tallo',
          description: 'Acumulación de biomasa y demanda hídrica.',
          startFraction: 0.25,
          endFraction: 0.45,
          icon: Icons.straighten,
        ),
        CropStageDefinition(
          name: 'Embuchamiento y panoja',
          description: 'Formación de panoja antes de floración.',
          startFraction: 0.45,
          endFraction: 0.60,
          icon: Icons.filter_vintage,
        ),
        CropStageDefinition(
          name: 'Floración',
          description: 'Polinización y sensibilidad a estrés.',
          startFraction: 0.60,
          endFraction: 0.72,
          icon: Icons.wb_sunny_outlined,
        ),
        CropStageDefinition(
          name: 'Llenado y madurez',
          description: 'Endurecimiento de grano y secado.',
          startFraction: 0.72,
          endFraction: 1.0,
          icon: Icons.check_circle_outline,
        ),
      ],
      events: <CropEventDefinition>[
        CropEventDefinition(
          task: 'Ajuste de densidad',
          description: 'Verificar población y resiembra si es necesario.',
          dayFraction: 0.06,
          icon: Icons.playlist_add_check_circle_outlined,
          priority: 'medium',
          required: true,
        ),
        CropEventDefinition(
          task: 'Control de maleza temprana',
          description: 'Evitar reducción de macollos.',
          dayFraction: 0.18,
          icon: Icons.content_cut,
          priority: 'medium',
          required: true,
        ),
        CropEventDefinition(
          task: 'Fertilización nitrogenada',
          description: 'Aplicar antes de elongación principal.',
          dayFraction: 0.32,
          icon: Icons.compost_outlined,
          priority: 'high',
          required: true,
        ),
        CropEventDefinition(
          task: 'Monitoreo de pulgón amarillo',
          description: 'Revisar haz y envés de hojas superiores.',
          dayFraction: 0.46,
          icon: Icons.bug_report_outlined,
          priority: 'high',
          required: true,
        ),
        CropEventDefinition(
          task: 'Plan de cosecha',
          description: 'Ajustar humedad del grano y maquinaria.',
          dayFraction: 0.90,
          icon: Icons.agriculture_outlined,
          priority: 'medium',
          required: true,
        ),
      ],
    ),
    'trigo': _CropProfile(
      stages: <CropStageDefinition>[
        CropStageDefinition(
          name: 'Siembra y emergencia',
          description: 'Germinación y salida del coleóptilo.',
          startFraction: 0.0,
          endFraction: 0.10,
          icon: Icons.eco_outlined,
        ),
        CropStageDefinition(
          name: 'Macollaje',
          description: 'Definición del número de tallos productivos.',
          startFraction: 0.10,
          endFraction: 0.28,
          icon: Icons.grass,
        ),
        CropStageDefinition(
          name: 'Encañado',
          description: 'Elongación del tallo principal.',
          startFraction: 0.28,
          endFraction: 0.48,
          icon: Icons.straighten,
        ),
        CropStageDefinition(
          name: 'Espigamiento',
          description: 'Salida de espiga y manejo fitosanitario.',
          startFraction: 0.48,
          endFraction: 0.62,
          icon: Icons.grain,
        ),
        CropStageDefinition(
          name: 'Floración y llenado',
          description: 'Definición del peso de mil granos.',
          startFraction: 0.62,
          endFraction: 0.84,
          icon: Icons.wb_sunny_outlined,
        ),
        CropStageDefinition(
          name: 'Madurez y cosecha',
          description: 'Secado de espiga y preparación de corte.',
          startFraction: 0.84,
          endFraction: 1.0,
          icon: Icons.check_circle_outline,
        ),
      ],
      events: <CropEventDefinition>[
        CropEventDefinition(
          task: 'Revisión de emergencia',
          description: 'Evaluar uniformidad de plántulas.',
          dayFraction: 0.06,
          icon: Icons.search,
          priority: 'medium',
          required: true,
        ),
        CropEventDefinition(
          task: 'Aplicación de nitrógeno',
          description: 'Favorecer macollaje y desarrollo vegetativo.',
          dayFraction: 0.22,
          icon: Icons.compost_outlined,
          priority: 'high',
          required: true,
        ),
        CropEventDefinition(
          task: 'Monitoreo de roya',
          description: 'Inspección preventiva en hojas bandera.',
          dayFraction: 0.52,
          icon: Icons.bug_report_outlined,
          priority: 'high',
          required: true,
        ),
        CropEventDefinition(
          task: 'Riego en llenado',
          description: 'Sostener peso de grano en fases críticas.',
          dayFraction: 0.70,
          icon: Icons.water_drop_outlined,
          priority: 'medium',
          required: true,
        ),
        CropEventDefinition(
          task: 'Programar trilla',
          description: 'Revisar humedad y condiciones de cosecha.',
          dayFraction: 0.93,
          icon: Icons.agriculture_outlined,
          priority: 'medium',
          required: true,
        ),
      ],
    ),
    'zanahoria': _CropProfile(
      stages: <CropStageDefinition>[
        CropStageDefinition(
          name: 'Siembra y germinación',
          description: 'Emergencia lenta y delicada del cultivo.',
          startFraction: 0.0,
          endFraction: 0.12,
          icon: Icons.eco_outlined,
        ),
        CropStageDefinition(
          name: 'Desarrollo foliar',
          description: 'Formación del follaje y sombreo del surco.',
          startFraction: 0.12,
          endFraction: 0.34,
          icon: Icons.park_outlined,
        ),
        CropStageDefinition(
          name: 'Engrosamiento de raíz',
          description: 'Acumulación de azúcares y calibre comercial.',
          startFraction: 0.34,
          endFraction: 0.72,
          icon: Icons.spa_outlined,
        ),
        CropStageDefinition(
          name: 'Madurez comercial',
          description: 'Definición de longitud, diámetro y color.',
          startFraction: 0.72,
          endFraction: 0.92,
          icon: Icons.check_circle_outline,
        ),
        CropStageDefinition(
          name: 'Cosecha',
          description: 'Arranque y clasificación por calibre.',
          startFraction: 0.92,
          endFraction: 1.0,
          icon: Icons.shopping_basket_outlined,
        ),
      ],
      events: <CropEventDefinition>[
        CropEventDefinition(
          task: 'Aclareo de plantas',
          description: 'Ajustar espaciamiento para calibre uniforme.',
          dayFraction: 0.18,
          icon: Icons.drag_indicator,
          priority: 'high',
          required: true,
        ),
        CropEventDefinition(
          task: 'Control de maleza en surco',
          description: 'Reducir competencia en etapas tempranas.',
          dayFraction: 0.24,
          icon: Icons.content_cut,
          priority: 'medium',
          required: true,
        ),
        CropEventDefinition(
          task: 'Fertilización potásica',
          description: 'Favorecer color y calidad de raíz.',
          dayFraction: 0.42,
          icon: Icons.compost_outlined,
          priority: 'medium',
          required: true,
        ),
        CropEventDefinition(
          task: 'Monitoreo de Alternaria',
          description: 'Revisar follaje por lesiones y marchitez.',
          dayFraction: 0.58,
          icon: Icons.bug_report_outlined,
          priority: 'high',
          required: true,
        ),
        CropEventDefinition(
          task: 'Programar arranque',
          description: 'Definir ventana de cosecha por calibre.',
          dayFraction: 0.90,
          icon: Icons.shopping_cart_checkout,
          priority: 'medium',
          required: true,
        ),
      ],
    ),
    'soja': _CropProfile(
      stages: <CropStageDefinition>[
        CropStageDefinition(
          name: 'Siembra y emergencia',
          description: 'Inicio del cultivo y revisión de población.',
          startFraction: 0.0,
          endFraction: 0.10,
          icon: Icons.eco_outlined,
        ),
        CropStageDefinition(
          name: 'Desarrollo vegetativo',
          description: 'Emisión de nudos y expansión del dosel.',
          startFraction: 0.10,
          endFraction: 0.34,
          icon: Icons.grass,
        ),
        CropStageDefinition(
          name: 'Floración',
          description: 'Inicio de flores y alta sensibilidad al estrés.',
          startFraction: 0.34,
          endFraction: 0.52,
          icon: Icons.wb_sunny_outlined,
        ),
        CropStageDefinition(
          name: 'Formación de vainas',
          description: 'Cuajado y retención de estructuras reproductivas.',
          startFraction: 0.52,
          endFraction: 0.68,
          icon: Icons.view_stream_outlined,
        ),
        CropStageDefinition(
          name: 'Llenado de grano',
          description: 'Definición final del rendimiento.',
          startFraction: 0.68,
          endFraction: 0.88,
          icon: Icons.grain,
        ),
        CropStageDefinition(
          name: 'Madurez y cosecha',
          description: 'Secado de vainas y preparación de trilla.',
          startFraction: 0.88,
          endFraction: 1.0,
          icon: Icons.check_circle_outline,
        ),
      ],
      events: <CropEventDefinition>[
        CropEventDefinition(
          task: 'Revisión de nodulación',
          description: 'Evaluar actividad del inoculante en raíces.',
          dayFraction: 0.14,
          icon: Icons.biotech_outlined,
          priority: 'medium',
          required: true,
        ),
        CropEventDefinition(
          task: 'Control temprano de maleza',
          description: 'Evitar pérdida de área foliar útil.',
          dayFraction: 0.20,
          icon: Icons.content_cut,
          priority: 'medium',
          required: true,
        ),
        CropEventDefinition(
          task: 'Monitoreo de chinche',
          description: 'Vigilar daño durante formación de vainas.',
          dayFraction: 0.56,
          icon: Icons.bug_report_outlined,
          priority: 'high',
          required: true,
        ),
        CropEventDefinition(
          task: 'Riego de soporte en llenado',
          description: 'Mantener humedad útil durante R5-R6.',
          dayFraction: 0.74,
          icon: Icons.water_drop_outlined,
          priority: 'high',
          required: true,
        ),
        CropEventDefinition(
          task: 'Definir fecha de trilla',
          description: 'Ajustar cosecha por humedad de grano.',
          dayFraction: 0.94,
          icon: Icons.agriculture_outlined,
          priority: 'medium',
          required: true,
        ),
      ],
    ),
  };
}

class _CropProfile {
  const _CropProfile({required this.stages, required this.events});

  final List<CropStageDefinition> stages;
  final List<CropEventDefinition> events;
}
