import 'package:flutter/material.dart';

class CropCatalogItem {
  const CropCatalogItem({
    required this.id,
    required this.name,
    required this.imageAsset,
    required this.heroImageUrl,
    required this.season,
    required this.sowingWindow,
    required this.harvestWindow,
    required this.cycleDays,
    required this.description,
    required this.fertilizers,
    required this.pests,
    required this.gradientColors,
    required this.badgeColor,
    required this.icon,
    required this.pdfAssetPath,
    required this.idealTemperature,
    required this.waterRequirement,
    required this.soilType,
    required this.soilPh,
    required this.plantingDensity,
    required this.expectedYield,
    required this.sunExposure,
  });

  final String id;
  final String name;
  final String imageAsset;
  final String heroImageUrl;
  final String season;
  final String sowingWindow;
  final String harvestWindow;
  final int cycleDays;
  final String description;
  final List<String> fertilizers;
  final List<String> pests;
  final List<Color> gradientColors;
  final Color badgeColor;
  final IconData icon;
  final String pdfAssetPath;
  final String idealTemperature;
  final String waterRequirement;
  final String soilType;
  final String soilPh;
  final String plantingDensity;
  final String expectedYield;
  final String sunExposure;
}
