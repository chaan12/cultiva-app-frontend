import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../shared/security/input_sanitizer.dart';

class MarketCenter {
  const MarketCenter({
    required this.id,
    required this.name,
    required this.state,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.mainProducts,
    this.address,
    this.openingHours,
    this.phoneNumbers = const <String>[],
    this.accessNotes,
    this.description,
    this.tags = const <String>[],
    this.images = const <String>[],
  });

  final String id;
  final String name;
  final String state;
  final String city;
  final double latitude;
  final double longitude;
  final String type;
  final List<String> mainProducts;
  final String? address;
  final String? openingHours;
  final List<String> phoneNumbers;
  final String? accessNotes;
  final String? description;
  final List<String> tags;
  final List<String> images;

  factory MarketCenter.fromJson(Map<String, dynamic> json) {
    final id = InputSanitizer.safeId(_string(json['id']), maxLength: 80);
    final latitude = _double(json['lat']);
    final longitude = _double(json['lng']);
    if (id.isEmpty ||
        latitude == null ||
        longitude == null ||
        latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
      throw const FormatException('Central de mercado inválida.');
    }
    return MarketCenter(
      id: id,
      name: InputSanitizer.text(_string(json['nombre']), maxLength: 120),
      state: InputSanitizer.text(_string(json['estado']), maxLength: 80),
      city: InputSanitizer.text(_string(json['ciudad']), maxLength: 80),
      latitude: latitude,
      longitude: longitude,
      type: InputSanitizer.text(_string(json['tipo']), maxLength: 80),
      address: _optionalText(json['direccion'], maxLength: 180),
      openingHours: _optionalText(json['horarios'], maxLength: 180),
      phoneNumbers: _stringList(json['telefono']),
      accessNotes: _optionalText(json['notas_acceso'], maxLength: 180),
      mainProducts: _stringList(json['cultivos']),
      description: _optionalText(json['descripcion'], maxLength: 320),
      tags: _stringList(json['tags']),
      images: _stringList(json['imagenes']),
    );
  }

  static List<String> _stringList(Object? value) {
    if (value == null) {
      return const <String>[];
    }
    if (value is String) {
      final trimmed = InputSanitizer.text(value, maxLength: 80);
      return trimmed.isEmpty ? const <String>[] : <String>[trimmed];
    }
    if (value is List) {
      return value
          .whereType<String>()
          .map((item) => InputSanitizer.text(item, maxLength: 80))
          .where((item) => item.isNotEmpty)
          .take(24)
          .toList();
    }
    return const <String>[];
  }

  static String _string(Object? value) {
    return value is String ? value : '';
  }

  static double? _double(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  static String? _optionalText(Object? value, {required int maxLength}) {
    if (value is! String) {
      return null;
    }
    final sanitized = InputSanitizer.text(value, maxLength: maxLength);
    return sanitized.isEmpty ? null : sanitized;
  }

  double distanceKmFrom(double latitude, double longitude) {
    const earthRadiusKm = 6371.0;
    final dLat = _degreesToRadians(this.latitude - latitude);
    final dLon = _degreesToRadians(this.longitude - longitude);
    final lat1 = _degreesToRadians(latitude);
    final lat2 = _degreesToRadians(this.latitude);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _degreesToRadians(double degrees) => degrees * math.pi / 180;
}

class CropMarketPrice {
  const CropMarketPrice({
    required this.cropId,
    required this.cropName,
    required this.variety,
    required this.market,
    required this.pricePerKg,
    required this.dailyChangePercent,
    required this.weeklyChangePercent,
    required this.presentation,
    required this.quality,
    required this.updatedAt,
    required this.source,
    required this.history,
    required this.color,
    this.priceUnit = 'kg',
  });

  final String cropId;
  final String cropName;
  final String variety;
  final MarketCenter market;
  final double pricePerKg;
  final double dailyChangePercent;
  final double weeklyChangePercent;
  final String presentation;
  final String quality;
  final DateTime updatedAt;
  final String source;
  final List<MarketPricePoint> history;
  final Color color;
  final String priceUnit;

  double get pricePerTon => pricePerKg * 1000;
  bool get isUpToday => dailyChangePercent >= 0;
  bool get isUpThisWeek => weeklyChangePercent >= 0;
}

class MarketPricePoint {
  const MarketPricePoint({required this.date, required this.pricePerKg});

  final DateTime date;
  final double pricePerKg;
}

class MarketSnapshot {
  const MarketSnapshot({
    required this.prices,
    required this.nearbyMarkets,
    required this.nearestMarket,
    required this.locationLabel,
    required this.isLiveSource,
  });

  final List<CropMarketPrice> prices;
  final List<MarketCenter> nearbyMarkets;
  final MarketCenter nearestMarket;
  final String locationLabel;
  final bool isLiveSource;

  List<CropMarketPrice> get featuredPrices {
    final localPrices = prices
        .where((price) => price.market.state == nearestMarket.state)
        .toList();
    final sorted = [...(localPrices.isEmpty ? prices : localPrices)]
      ..sort((a, b) => b.weeklyChangePercent.compareTo(a.weeklyChangePercent));
    return sorted.take(4).toList();
  }

  List<CropMarketPrice> get localPrices {
    final matches =
        prices
            .where((price) => price.market.state == nearestMarket.state)
            .toList()
          ..sort((a, b) {
            final cropCompare = a.cropName.compareTo(b.cropName);
            if (cropCompare != 0) {
              return cropCompare;
            }
            return b.pricePerKg.compareTo(a.pricePerKg);
          });
    return matches.isEmpty ? prices : matches;
  }

  double get averageLocalPricePerKg {
    final values = localPrices;
    if (values.isEmpty) {
      return 0;
    }
    final sum = values.fold<double>(
      0,
      (total, price) => total + price.pricePerKg,
    );
    return sum / values.length;
  }

  double get averageWeeklyChangePercent {
    final values = localPrices;
    if (values.isEmpty) {
      return 0;
    }
    final sum = values.fold<double>(
      0,
      (total, price) => total + price.weeklyChangePercent,
    );
    return sum / values.length;
  }

  List<String> get cropNames {
    final names = prices.map((price) => price.cropName).toSet().toList()
      ..sort();
    return names;
  }

  List<CropMarketPrice> pricesForCrop(String cropName) {
    final matches =
        localPrices.where((price) => price.cropName == cropName).toList()
          ..sort((a, b) => b.pricePerKg.compareTo(a.pricePerKg));
    if (matches.isNotEmpty) {
      return matches;
    }
    final allMatches =
        prices.where((price) => price.cropName == cropName).toList()
          ..sort((a, b) => b.pricePerKg.compareTo(a.pricePerKg));
    return allMatches;
  }
}
