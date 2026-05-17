import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../features/crop_tracking/models/crop_tracking_models.dart';
import '../../../features/crop_tracking/services/crop_tracking_service.dart';
import '../../models/crop_record.dart';
import '../../models/weather_snapshot.dart';

class AgriculturalCalendarItem {
  const AgriculturalCalendarItem({required this.crop, required this.event});

  final CropRecord crop;
  final CropUpcomingEvent event;

  DateTime get date => _dateOnly(event.scheduledDate);
  bool get isOverdue => !event.completed && event.daysUntil < 0;
  bool get isToday => !event.completed && event.daysUntil == 0;
  bool get isUpcoming => !event.completed && event.daysUntil > 0;
  bool get isActionable => !event.completed && event.daysUntil <= 7;

  String get urgencyLabel {
    if (event.completed) {
      return event.userCompleted ? 'Concluido' : 'Cerrado por fecha';
    }
    if (isOverdue) {
      return 'Atrasado ${event.daysUntil.abs()} día(s)';
    }
    if (isToday) {
      return 'Hoy';
    }
    if (event.daysUntil == 1) {
      return 'Mañana';
    }
    return 'En ${event.daysUntil} días';
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

class CropWeatherAdvisory {
  const CropWeatherAdvisory({
    required this.title,
    required this.detail,
    required this.icon,
    required this.color,
    required this.priority,
  });

  final String title;
  final String detail;
  final IconData icon;
  final Color color;
  final int priority;
}

class AgriculturalAdvisoryService {
  const AgriculturalAdvisoryService._();

  static List<AgriculturalCalendarItem> calendarItems(List<CropRecord> crops) {
    final items = <AgriculturalCalendarItem>[];
    for (final crop in crops) {
      final plan = CropTrackingService.buildPlan(crop);
      for (final event in plan.allEvents) {
        items.add(AgriculturalCalendarItem(crop: crop, event: event));
      }
    }
    items.sort((a, b) {
      final dateCompare = a.date.compareTo(b.date);
      if (dateCompare != 0) {
        return dateCompare;
      }
      return a.crop.name.compareTo(b.crop.name);
    });
    return items;
  }

  static List<AgriculturalCalendarItem> priorityItems(
    List<CropRecord> crops, {
    int daysAhead = 7,
  }) {
    final items = calendarItems(crops).where((item) {
      return !item.event.completed && item.event.daysUntil <= daysAhead;
    }).toList();
    items.sort((a, b) {
      final urgencyCompare = a.event.daysUntil.compareTo(b.event.daysUntil);
      if (urgencyCompare != 0) {
        return urgencyCompare;
      }
      if (a.event.priority != b.event.priority) {
        return a.event.priority == 'high' ? -1 : 1;
      }
      return a.crop.name.compareTo(b.crop.name);
    });
    return items;
  }

  static List<AgriculturalCalendarItem> historyItems(CropRecord crop) {
    final plan = CropTrackingService.buildPlan(crop);
    final items = plan.allEvents
        .where((event) => event.completed)
        .map((event) => AgriculturalCalendarItem(crop: crop, event: event))
        .toList();
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  static List<CropWeatherAdvisory> weatherAdvisories({
    required List<CropRecord> crops,
    required WeatherSnapshot? weather,
  }) {
    final advisories = <CropWeatherAdvisory>[];
    if (weather == null) {
      return const <CropWeatherAdvisory>[
        CropWeatherAdvisory(
          title: 'Clima sin sincronizar',
          detail: 'Actualiza el clima para cruzarlo con tus cultivos activos.',
          icon: Icons.cloud_off_outlined,
          color: Colors.blueGrey,
          priority: 5,
        ),
      ];
    }

    if (weather.rainProbability >= 70 || weather.precipitationMm >= 8) {
      advisories.add(
        CropWeatherAdvisory(
          title: 'Evita aplicaciones antes de lluvia',
          detail:
              'Probabilidad de lluvia ${weather.rainProbability}%. Reprograma fertilización foliar, pesticidas o labores de suelo.',
          icon: Icons.umbrella_outlined,
          color: const Color(0xFF1565C0),
          priority: 1,
        ),
      );
    }
    if (weather.uvIndex >= 8 || weather.apparentTemperatureC >= 36) {
      advisories.add(
        CropWeatherAdvisory(
          title: 'Riesgo de estrés térmico',
          detail:
              'Sensación ${weather.apparentTemperatureC.toStringAsFixed(1)}°C y UV ${weather.uvIndex.toStringAsFixed(1)}. Prioriza riego temprano y revisa marchitez.',
          icon: Icons.wb_sunny_outlined,
          color: Colors.deepOrange,
          priority: 2,
        ),
      );
    }
    if (weather.humidity >= 80 && weather.rainProbability >= 40) {
      advisories.add(
        CropWeatherAdvisory(
          title: 'Ambiente favorable para hongos',
          detail:
              'Humedad ${weather.humidity}% con lluvia posible. Revisa manchas foliares y mejora ventilación en cultivos densos.',
          icon: Icons.coronavirus_outlined,
          color: Colors.purple,
          priority: 3,
        ),
      );
    }
    if (weather.windGustKmh >= 35) {
      advisories.add(
        CropWeatherAdvisory(
          title: 'Viento fuerte para labores',
          detail:
              'Rachas de ${weather.windGustKmh.toStringAsFixed(0)} km/h. Evita aspersiones y protege tutores o plantas jóvenes.',
          icon: Icons.air,
          color: Colors.teal,
          priority: 4,
        ),
      );
    }

    final urgentEvents = priorityItems(crops, daysAhead: 2);
    for (final item in urgentEvents.take(2)) {
      advisories.add(
        CropWeatherAdvisory(
          title: '${item.crop.name}: ${item.event.task}',
          detail: _eventWeatherHint(item.event, weather),
          icon: item.event.icon,
          color: item.event.priority == 'high'
              ? Colors.redAccent
              : const Color(0xFFF59E0B),
          priority: item.event.priority == 'high' ? 1 : 2,
        ),
      );
    }

    if (advisories.isEmpty) {
      advisories.add(
        const CropWeatherAdvisory(
          title: 'Condiciones operables',
          detail:
              'No hay señales climáticas críticas. Mantén monitoreo normal y sigue el calendario de eventos.',
          icon: Icons.check_circle_outline,
          color: Color(0xFF0D5D33),
          priority: 9,
        ),
      );
    }

    advisories.sort((a, b) => a.priority.compareTo(b.priority));
    return advisories;
  }

  static String monthSignal(DateTime date) {
    final month = DateFormat('MMMM', 'es_MX').format(date);
    if (date.month >= 5 && date.month <= 10) {
      return 'Cabañuelas: usa la señal de $month para planear drenaje, maleza y ventanas de siembra.';
    }
    return 'Cabañuelas: usa la señal de $month para anticipar riego, preparación de suelo y estrés por calor.';
  }

  static String _eventWeatherHint(
    CropUpcomingEvent event,
    WeatherSnapshot weather,
  ) {
    final text = '${event.task} ${event.description}'.toLowerCase();
    if (text.contains('fertiliz') || text.contains('aplicar')) {
      if (weather.rainProbability >= 60) {
        return 'Revisa ventana sin lluvia antes de aplicar. Lluvia: ${weather.rainProbability}%.';
      }
      return 'Hay ventana razonable; evita horas de mayor UV (${weather.uvIndex.toStringAsFixed(1)}).';
    }
    if (text.contains('riego') || text.contains('humedad')) {
      if (weather.rainProbability >= 60) {
        return 'Puede llover; verifica humedad antes de regar para no saturar.';
      }
      return 'Sin lluvia fuerte prevista; revisa humedad de suelo y programa riego temprano.';
    }
    if (text.contains('plaga') ||
        text.contains('monitoreo') ||
        text.contains('inspección')) {
      return 'Buen momento para revisar hojas. Humedad ${weather.humidity}% y viento ${weather.windSpeedKmh.toStringAsFixed(0)} km/h.';
    }
    return 'Cruza esta tarea con lluvia ${weather.rainProbability}% y temperatura ${weather.temperatureC.toStringAsFixed(1)}°C.';
  }
}
