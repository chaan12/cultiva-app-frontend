import 'package:intl/intl.dart';

import '../../features/crops_catalog/models/crop_catalog_item.dart';
import '../security/input_sanitizer.dart';

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
    List<String>? completedEventIds,
  }) : _completedEventIds = completedEventIds;

  factory CropRecord.fromMap(Map<String, Object?> map) {
    final id = InputSanitizer.safeId(_readString(map, 'id'), maxLength: 96);
    final cropId = InputSanitizer.safeId(
      _readString(map, 'cropId'),
      maxLength: 48,
    );
    final areaHa = _readDouble(map, 'areaHa');
    final sowingDate = _readDate(map, 'sowingDate');
    final createdAt = _readDate(map, 'createdAt');
    final completedAtValue = map['completedAt'];
    final imageAsset = _readString(map, 'imageAsset');
    if (id.isEmpty ||
        cropId.isEmpty ||
        !areaHa.isFinite ||
        areaHa <= 0 ||
        !imageAsset.startsWith('assets/images/')) {
      throw const FormatException('Registro de cultivo inválido.');
    }
    return CropRecord(
      id: id,
      cropId: cropId,
      name: InputSanitizer.text(_readString(map, 'name'), maxLength: 80),
      areaHa: areaHa,
      sowingDate: sowingDate,
      locationName: InputSanitizer.location(_readString(map, 'locationName')),
      season: InputSanitizer.text(_readString(map, 'season'), maxLength: 80),
      cycleDays: _readInt(map, 'cycleDays').clamp(1, 5000),
      imageAsset: imageAsset,
      accentColorValue: _readInt(map, 'accentColorValue'),
      createdAt: createdAt,
      isCompleted: (map['isCompleted'] as bool?) ?? false,
      completedAt: completedAtValue == null
          ? null
          : _readDate(map, 'completedAt'),
      completedEventIds: (map['completedEventIds'] as List<dynamic>?)
          ?.whereType<String>()
          .map((id) => InputSanitizer.safeId(id, maxLength: 80))
          .where((id) => id.isNotEmpty)
          .take(200)
          .toList(),
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
  final List<String>? _completedEventIds;

  List<String> get completedEventIds => _completedEventIds ?? const <String>[];

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
      'completedEventIds': completedEventIds,
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
    List<String>? completedEventIds,
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
      completedEventIds: completedEventIds ?? this.completedEventIds,
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

  static String _readString(Map<String, Object?> map, String key) {
    final value = map[key];
    return value is String ? value : '';
  }

  static double _readDouble(Map<String, Object?> map, String key) {
    final value = map[key];
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? double.nan;
    }
    return double.nan;
  }

  static int _readInt(Map<String, Object?> map, String key) {
    final value = map[key];
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  static DateTime _readDate(Map<String, Object?> map, String key) {
    final value = map[key];
    if (value is! String) {
      throw const FormatException('Fecha de cultivo inválida.');
    }
    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      throw const FormatException('Fecha de cultivo inválida.');
    }
    return parsed;
  }
}
