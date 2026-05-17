import '../../../features/crops_catalog/models/crop_catalog_item.dart';
import '../../../features/crops_catalog/services/crop_catalog_service.dart';

class CropRecommendationService {
  const CropRecommendationService._();

  static String currentSeason({DateTime? now}) {
    final month = (now ?? DateTime.now()).month;
    if (month >= 3 && month <= 8) {
      return 'Primavera - Verano';
    }
    return 'Otoño - Invierno';
  }

  static CropCatalogItem recommendedCropItem({DateTime? now}) {
    return recommendedCropItems(now: now).first;
  }

  static List<CropCatalogItem> recommendedCropItems({DateTime? now}) {
    final month = (now ?? DateTime.now()).month;
    final currentSeasonParts = currentSeason(
      now: now,
    ).split(' - ').map((part) => part.trim().toLowerCase()).toList();
    final ranked = [...CropCatalogService.items]
      ..sort((a, b) {
        final scoreA = _recommendationScore(
          item: a,
          month: month,
          currentSeasonParts: currentSeasonParts,
        );
        final scoreB = _recommendationScore(
          item: b,
          month: month,
          currentSeasonParts: currentSeasonParts,
        );
        if (scoreA != scoreB) {
          return scoreB.compareTo(scoreA);
        }
        return a.cycleDays.compareTo(b.cycleDays);
      });
    return ranked;
  }

  static int _recommendationScore({
    required CropCatalogItem item,
    required int month,
    required List<String> currentSeasonParts,
  }) {
    final season = item.season.toLowerCase();
    final sowingWindow = item.sowingWindow.toLowerCase();
    var score = 0;

    if (season.contains('todo el año') ||
        sowingWindow.contains('todo el año')) {
      score += 40;
    }
    if (_windowContainsMonth(sowingWindow, month)) {
      score += 70;
    }
    if (currentSeasonParts.every(season.contains)) {
      score += 50;
    } else {
      for (final part in currentSeasonParts) {
        if (season.contains(part)) {
          score += 20;
        }
      }
    }
    score += (160 - item.cycleDays).clamp(0, 60);
    return score;
  }

  static bool _windowContainsMonth(String window, int month) {
    const monthNames = <String, int>{
      'enero': 1,
      'febrero': 2,
      'marzo': 3,
      'abril': 4,
      'mayo': 5,
      'junio': 6,
      'julio': 7,
      'agosto': 8,
      'septiembre': 9,
      'setiembre': 9,
      'octubre': 10,
      'noviembre': 11,
      'diciembre': 12,
    };
    for (final entry in monthNames.entries) {
      if (window.contains(entry.key) && entry.value == month) {
        return true;
      }
    }
    return false;
  }
}
