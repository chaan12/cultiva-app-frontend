import 'package:flutter/material.dart';

class CropStageDefinition {
  const CropStageDefinition({
    required this.name,
    required this.description,
    required this.startFraction,
    required this.endFraction,
    required this.icon,
  });

  final String name;
  final String description;
  final double startFraction;
  final double endFraction;
  final IconData icon;
}

class CropEventDefinition {
  const CropEventDefinition({
    required this.task,
    required this.description,
    required this.dayFraction,
    required this.icon,
    required this.priority,
    required this.required,
  });

  final String task;
  final String description;
  final double dayFraction;
  final IconData icon;
  final String priority;
  final bool required;
}

class CropTimelineStage {
  const CropTimelineStage({
    required this.name,
    required this.date,
    required this.description,
    required this.completed,
    required this.current,
    required this.icon,
    this.daysRemaining,
  });

  final String name;
  final String date;
  final String description;
  final bool completed;
  final bool current;
  final IconData icon;
  final int? daysRemaining;
}

class CropUpcomingEvent {
  const CropUpcomingEvent({
    required this.task,
    required this.date,
    required this.daysUntil,
    required this.priority,
    required this.icon,
    required this.description,
    required this.required,
    required this.completed,
  });

  final String task;
  final String date;
  final int daysUntil;
  final String priority;
  final IconData icon;
  final String description;
  final bool required;
  final bool completed;
}

class CropTrackingSummary {
  const CropTrackingSummary({
    required this.currentStage,
    required this.nextEventLabel,
    required this.nextEventDays,
    required this.status,
    required this.progress,
    required this.daysToHarvest,
  });

  final String currentStage;
  final String nextEventLabel;
  final int nextEventDays;
  final String status;
  final int progress;
  final int daysToHarvest;
}

class CropTrackingPlan {
  const CropTrackingPlan({
    required this.currentStage,
    required this.progress,
    required this.daysToHarvest,
    required this.timelineStages,
    required this.upcomingEvents,
    required this.summary,
  });

  final String currentStage;
  final int progress;
  final int daysToHarvest;
  final List<CropTimelineStage> timelineStages;
  final List<CropUpcomingEvent> upcomingEvents;
  final CropTrackingSummary summary;
}
