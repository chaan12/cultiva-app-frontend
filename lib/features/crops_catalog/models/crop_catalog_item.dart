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
}
