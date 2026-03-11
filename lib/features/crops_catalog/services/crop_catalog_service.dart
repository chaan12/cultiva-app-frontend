import 'package:flutter/material.dart';

import '../models/crop_catalog_item.dart';

class CropCatalogService {
  const CropCatalogService._();

  static const List<CropCatalogItem> items = <CropCatalogItem>[
    CropCatalogItem(
      id: 'maiz',
      name: 'Maíz',
      imageAsset: 'assets/images/CUL - maiz.png',
      heroImageUrl:
          'https://images.unsplash.com/photo-1691326564837-51e3619f1d70?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=1080',
      season: 'Primavera-Verano',
      sowingWindow: 'Abril - Junio',
      harvestWindow: 'Agosto - Octubre',
      cycleDays: 140,
      description:
          'Cultivo base de la agricultura maya, adaptado al clima tropical.',
      fertilizers: <String>[
        'Nitrógeno (N): 120-150 kg/ha',
        'Fósforo (P₂O₅): 60-80 kg/ha',
        'Potasio (K₂O): 40-60 kg/ha',
      ],
      pests: <String>[
        'Gusano cogollero',
        'Barrenador del tallo',
        'Gallina ciega',
      ],
      gradientColors: <Color>[Color(0xFFFBBF24), Color(0xFFEAB308)],
      badgeColor: Color(0xFF00C853),
      icon: Icons.grass_rounded,
      pdfAssetPath: 'assets/pdfs/maiz_ficha_tecnica.pdf',
      idealTemperature: '24-32 °C',
      waterRequirement: '500-800 mm por ciclo',
      soilType: 'Franco a franco-arcilloso, bien drenado',
      soilPh: '5.5 - 7.5',
      plantingDensity: '55,000-75,000 plantas/ha',
      expectedYield: '4-10 t/ha de grano',
      sunExposure: 'Pleno sol',
    ),
    CropCatalogItem(
      id: 'tomate',
      name: 'Tomate',
      imageAsset: 'assets/images/CUL - tomate.png',
      heroImageUrl:
          'https://images.unsplash.com/photo-1683008952375-410ae668e6b9?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=1080',
      season: 'Todo el año',
      sowingWindow: 'Todo el año (bajo riego)',
      harvestWindow: '75-90 días después de trasplante',
      cycleDays: 110,
      description:
          'Cultivo de alto valor comercial, requiere manejo intensivo.',
      fertilizers: <String>[
        'Nitrógeno (N): 150-200 kg/ha',
        'Fósforo (P₂O₅): 100-150 kg/ha',
        'Potasio (K₂O): 200-250 kg/ha',
      ],
      pests: <String>[
        'Mosca blanca',
        'Gusano del fruto',
        'Araña roja',
        'Trips',
      ],
      gradientColors: <Color>[Color(0xFFF87171), Color(0xFFDC2626)],
      badgeColor: Color(0xFF0D5D33),
      icon: Icons.local_florist_rounded,
      pdfAssetPath: 'assets/pdfs/tomate_ficha_tecnica.pdf',
      idealTemperature: '18-28 °C',
      waterRequirement: '600-900 mm por ciclo',
      soilType: 'Franco arenoso, profundo y drenado',
      soilPh: '6.0 - 7.0',
      plantingDensity: '10,000-18,000 plantas/ha',
      expectedYield: '30-80 t/ha',
      sunExposure: 'Alta radiación y buena ventilación',
    ),
    CropCatalogItem(
      id: 'sorgo',
      name: 'Sorgo',
      imageAsset: 'assets/images/CUL - sorgo.png',
      heroImageUrl:
          'https://images.unsplash.com/photo-1622383563227-04401ab4e5ea?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=1080',
      season: 'Verano - Otoño',
      sowingWindow: 'Junio - Agosto',
      harvestWindow: 'Octubre - Diciembre',
      cycleDays: 105,
      description:
          'Alternativa resistente a estrés hídrico y útil para grano o forraje.',
      fertilizers: <String>[
        'Nitrógeno (N): 90-120 kg/ha',
        'Fósforo (P₂O₅): 40-60 kg/ha',
        'Potasio (K₂O): 30-50 kg/ha',
      ],
      pests: <String>[
        'Mosquita del sorgo',
        'Pulgón amarillo',
        'Gusano cogollero',
      ],
      gradientColors: <Color>[Color(0xFFF97316), Color(0xFFEA580C)],
      badgeColor: Color(0xFFF97316),
      icon: Icons.park_rounded,
      pdfAssetPath: 'assets/pdfs/sorgo_ficha_tecnica.pdf',
      idealTemperature: '26-34 °C',
      waterRequirement: '350-550 mm por ciclo',
      soilType: 'Franco a arcilloso, tolera menor fertilidad',
      soilPh: '5.5 - 8.0',
      plantingDensity: '120,000-180,000 plantas/ha',
      expectedYield: '3-7 t/ha de grano',
      sunExposure: 'Pleno sol',
    ),
    CropCatalogItem(
      id: 'trigo',
      name: 'Trigo',
      imageAsset: 'assets/images/CUL - trigo.png',
      heroImageUrl:
          'https://images.unsplash.com/photo-1500382017468-9049fed747ef?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=1080',
      season: 'Otoño - Invierno',
      sowingWindow: 'Noviembre - Enero',
      harvestWindow: 'Marzo - Mayo',
      cycleDays: 125,
      description:
          'Cultivo de grano para climas templados con alto valor alimentario.',
      fertilizers: <String>[
        'Nitrógeno (N): 100-140 kg/ha',
        'Fósforo (P₂O₅): 50-70 kg/ha',
        'Potasio (K₂O): 20-40 kg/ha',
      ],
      pests: <String>['Pulgón del trigo', 'Roya amarilla', 'Carbón parcial'],
      gradientColors: <Color>[Color(0xFFD97706), Color(0xFFB45309)],
      badgeColor: Color(0xFFB45309),
      icon: Icons.agriculture_rounded,
      pdfAssetPath: 'assets/pdfs/trigo_ficha_tecnica.pdf',
      idealTemperature: '12-24 °C',
      waterRequirement: '450-650 mm por ciclo',
      soilType: 'Franco con buena retención y drenaje',
      soilPh: '6.0 - 7.5',
      plantingDensity: '180-250 kg de semilla/ha',
      expectedYield: '3-8 t/ha',
      sunExposure: 'Sol directo',
    ),
    CropCatalogItem(
      id: 'zanahoria',
      name: 'Zanahoria',
      imageAsset: 'assets/images/CUL - zanahoria.png',
      heroImageUrl:
          'https://images.unsplash.com/photo-1447175008436-054170c2e979?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=1080',
      season: 'Invierno - Primavera',
      sowingWindow: 'Octubre - Febrero',
      harvestWindow: 'Enero - Mayo',
      cycleDays: 100,
      description:
          'Raíz de ciclo corto que demanda suelo suelto y humedad uniforme.',
      fertilizers: <String>[
        'Nitrógeno (N): 80-100 kg/ha',
        'Fósforo (P₂O₅): 60-80 kg/ha',
        'Potasio (K₂O): 120-150 kg/ha',
      ],
      pests: <String>['Mosca de la zanahoria', 'Nematodos', 'Alternaria'],
      gradientColors: <Color>[Color(0xFFF97316), Color(0xFFEA580C)],
      badgeColor: Color(0xFFEA580C),
      icon: Icons.spa_rounded,
      pdfAssetPath: 'assets/pdfs/zanahoria_ficha_tecnica.pdf',
      idealTemperature: '15-22 °C',
      waterRequirement: '350-500 mm por ciclo',
      soilType: 'Suelto, profundo, franco arenoso',
      soilPh: '6.0 - 6.8',
      plantingDensity: '0.8-1.2 millones de plantas/ha',
      expectedYield: '25-45 t/ha',
      sunExposure: 'Sol completo',
    ),
    CropCatalogItem(
      id: 'soja',
      name: 'Soja',
      imageAsset: 'assets/images/CUL - soja.png',
      heroImageUrl:
          'https://images.unsplash.com/photo-1471193945509-9ad0617afabf?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=1080',
      season: 'Primavera - Verano',
      sowingWindow: 'Mayo - Julio',
      harvestWindow: 'Septiembre - Noviembre',
      cycleDays: 115,
      description:
          'Leguminosa con buena fijación de nitrógeno y demanda de monitoreo sanitario.',
      fertilizers: <String>[
        'Inoculante de rizobio',
        'Fósforo (P₂O₅): 50-70 kg/ha',
        'Potasio (K₂O): 60-90 kg/ha',
      ],
      pests: <String>['Chinche verde', 'Oruga medidora', 'Roya asiática'],
      gradientColors: <Color>[Color(0xFF16A34A), Color(0xFF15803D)],
      badgeColor: Color(0xFF15803D),
      icon: Icons.eco_rounded,
      pdfAssetPath: 'assets/pdfs/soja_ficha_tecnica.pdf',
      idealTemperature: '20-30 °C',
      waterRequirement: '450-700 mm por ciclo',
      soilType: 'Franco a franco-arcilloso bien drenado',
      soilPh: '6.0 - 7.0',
      plantingDensity: '250,000-400,000 plantas/ha',
      expectedYield: '2.5-4.5 t/ha',
      sunExposure: 'Alta radiación',
    ),
  ];

  static CropCatalogItem byId(String id) {
    return items.firstWhere((item) => item.id == id, orElse: () => items.first);
  }
}
