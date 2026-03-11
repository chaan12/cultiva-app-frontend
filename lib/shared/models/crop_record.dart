import 'package:intl/intl.dart';

import '../../features/crops_catalog/models/crop_catalog_item.dart';

class CropRecord {
  CropRecord({
    required this.id,
    required this.cropId,
    required this.name,
    required this.areaHa,
    required this.sowingDate,
    required this.locationName,
    required this.season,
    required this.cycleDays,
    required this.imageAsset,
    required this.accentColorValue,
    required this.createdAt,
    this.isCompleted = false,
    this.completedAt,
  });

  factory CropRecord.fromMap(Map<String, Object?> map) {
    return CropRecord(
      id: map['id'] as String,
      cropId: map['cropId'] as String,
      name: map['name'] as String,
      areaHa: ((map['areaHa'] as num?) ?? 0).toDouble(),
      sowingDate: DateTime.parse(map['sowingDate'] as String),
      locationName: map['locationName'] as String,
      season: map['season'] as String,
      cycleDays: (map['cycleDays'] as num).toInt(),
      imageAsset: map['imageAsset'] as String,
      accentColorValue: (map['accentColorValue'] as num).toInt(),
      createdAt: DateTime.parse(map['createdAt'] as String),
      isCompleted: (map['isCompleted'] as bool?) ?? false,
      completedAt: map['completedAt'] == null
          ? null
          : DateTime.parse(map['completedAt'] as String),
    );
  }

  factory CropRecord.fromCatalog({
    required CropCatalogItem item,
    required double areaHa,
    required DateTime sowingDate,
    required String locationName,
  }) {
    final now = DateTime.now();
    return CropRecord(
      id: '${item.id}-${now.microsecondsSinceEpoch}',
      cropId: item.id,
      name: item.name,
      areaHa: areaHa,
      sowingDate: sowingDate,
      locationName: locationName,
      season: item.season,
      cycleDays: item.cycleDays,
      imageAsset: item.imageAsset,
      accentColorValue: item.badgeColor.toARGB32(),
      createdAt: now,
      isCompleted: false,
    );
  }

  final String id;
  final String cropId;
  final String name;
  final double areaHa;
  final DateTime sowingDate;
  final String locationName;
  final String season;
  final int cycleDays;
  final String imageAsset;
  final int accentColorValue;
  final DateTime createdAt;
  final bool isCompleted;
  final DateTime? completedAt;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'cropId': cropId,
      'name': name,
      'areaHa': areaHa,
      'sowingDate': sowingDate.toIso8601String(),
      'locationName': locationName,
      'season': season,
      'cycleDays': cycleDays,
      'imageAsset': imageAsset,
      'accentColorValue': accentColorValue,
      'createdAt': createdAt.toIso8601String(),
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  CropRecord copyWith({
    String? id,
    String? cropId,
    String? name,
    double? areaHa,
    DateTime? sowingDate,
    String? locationName,
    String? season,
    int? cycleDays,
    String? imageAsset,
    int? accentColorValue,
    DateTime? createdAt,
    bool? isCompleted,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return CropRecord(
      id: id ?? this.id,
      cropId: cropId ?? this.cropId,
      name: name ?? this.name,
      areaHa: areaHa ?? this.areaHa,
      sowingDate: sowingDate ?? this.sowingDate,
      locationName: locationName ?? this.locationName,
      season: season ?? this.season,
      cycleDays: cycleDays ?? this.cycleDays,
      imageAsset: imageAsset ?? this.imageAsset,
      accentColorValue: accentColorValue ?? this.accentColorValue,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
    );
  }

  int get daysSinceSowing {
    final difference = DateTime.now().difference(
      DateTime(sowingDate.year, sowingDate.month, sowingDate.day),
    );
    return difference.isNegative ? 0 : difference.inDays;
  }

  int get daysToHarvest {
    final remaining = cycleDays - daysSinceSowing;
    return remaining < 0 ? 0 : remaining;
  }

  int get progress {
    if (cycleDays <= 0) {
      return 0;
    }
    final value = (daysSinceSowing / cycleDays) * 100;
    return value.clamp(0, 100).round();
  }

  String get formattedArea => '${areaHa.toStringAsFixed(1)} ha';

  String get formattedSowingDate => DateFormat('dd/MM/yyyy').format(sowingDate);

  String get currentStage {
    if (progress < 15) {
      return 'Establecimiento';
    }
    if (progress < 45) {
      return 'Crecimiento vegetativo';
    }
    if (progress < 75) {
      return 'Floración';
    }
    if (progress < 95) {
      return 'Llenado y maduración';
    }
    return 'Listo para cosecha';
  }

  String get status {
    if (daysToHarvest <= 7) {
      return 'alerta';
    }
    if (nextEventDays <= 2) {
      return 'evento-proximo';
    }
    return 'normal';
  }

  int get nextEventDays {
    if (daysToHarvest <= 7) {
      return daysToHarvest;
    }
    if (progress < 20) {
      return _intervalCountdown(7);
    }
    if (progress < 50) {
      return _intervalCountdown(14);
    }
    if (progress < 80) {
      return _intervalCountdown(10);
    }
    return _intervalCountdown(5);
  }

  String get nextEventLabel {
    if (daysToHarvest <= 7) {
      return 'Cosecha en ${daysToHarvest == 0 ? 1 : daysToHarvest} día(s)';
    }
    if (progress < 20) {
      return 'Revisión de germinación en $nextEventDays día(s)';
    }
    if (progress < 50) {
      return 'Fertilización en $nextEventDays día(s)';
    }
    if (progress < 80) {
      return 'Monitoreo sanitario en $nextEventDays día(s)';
    }
    return 'Riego de cierre en $nextEventDays día(s)';
  }

  int _intervalCountdown(int interval) {
    final remainder = daysSinceSowing % interval;
    return remainder == 0 ? interval : interval - remainder;
  }
}
