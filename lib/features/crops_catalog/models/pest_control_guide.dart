import 'crop_catalog_item.dart';

class PestControlGuide {
  const PestControlGuide({
    required this.crop,
    required this.mainPest,
    required this.symptoms,
    required this.prevention,
    required this.control,
    required this.goodPractices,
    required this.season,
  });

  final CropCatalogItem crop;
  final String mainPest;
  final List<String> symptoms;
  final List<String> prevention;
  final List<String> control;
  final List<String> goodPractices;
  final String season;
}
