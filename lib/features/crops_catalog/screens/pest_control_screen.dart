import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/crop_catalog_item.dart';
import '../services/crop_catalog_service.dart';

class PestControlScreen extends StatelessWidget {
  const PestControlScreen({super.key, this.initialCropId});

  final String? initialCropId;

  @override
  Widget build(BuildContext context) {
    final guides = CropCatalogService.items
        .where((crop) {
          final initialCropId = this.initialCropId;
          return initialCropId == null || crop.id == initialCropId;
        })
        .map((crop) => _guideFor(crop))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.screenBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.screenBackground(context),
        foregroundColor: AppColors.primaryText(context),
        elevation: 0,
        title: const Text('Control de plagas'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        itemCount: guides.length,
        itemBuilder: (context, index) {
          return _PestGuideCard(guide: guides[index]);
        },
      ),
    );
  }
}

class _PestGuideCard extends StatelessWidget {
  const _PestGuideCard({required this.guide});

  final _PestGuide guide;

  @override
  Widget build(BuildContext context) {
    final crop = guide.crop;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    crop.imageAsset,
                    width: 58,
                    height: 58,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: 58,
                      height: 58,
                      color: crop.badgeColor.withValues(alpha: 0.12),
                      child: Icon(crop.icon, color: crop.badgeColor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        crop.name,
                        style: TextStyle(
                          color: AppColors.primaryText(context),
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${crop.pests.length} plagas registradas',
                        style: TextStyle(
                          color: AppColors.greenText(context),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _RegisteredPests(pests: crop.pests),
            const SizedBox(height: 12),
            _SeasonPill(text: guide.season),
            const SizedBox(height: 12),
            _GuideBlock(title: 'Síntomas comunes', items: guide.symptoms),
            _GuideBlock(title: 'Métodos preventivos', items: guide.prevention),
            _GuideBlock(
              title: 'Recomendaciones de control',
              items: guide.control,
            ),
            _GuideBlock(
              title: 'Buenas prácticas agrícolas',
              items: guide.goodPractices,
            ),
          ],
        ),
      ),
    );
  }
}

class _SeasonPill extends StatelessWidget {
  const _SeasonPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.greenIconBackground(context),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          'Temporada: $text',
          style: TextStyle(
            color: AppColors.greenText(context),
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _RegisteredPests extends StatelessWidget {
  const _RegisteredPests({required this.pests});

  final List<String> pests;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plagas registradas',
          style: TextStyle(
            color: AppColors.primaryText(context),
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: pests.map((pest) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.greenIconBackground(context),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                pest,
                style: TextStyle(
                  color: AppColors.greenText(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _GuideBlock extends StatelessWidget {
  const _GuideBlock({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 7),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: AppColors.greenText(context),
                    size: 17,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        color: AppColors.primaryText(context),
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PestGuide {
  const _PestGuide({
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

_PestGuide _guideFor(CropCatalogItem crop) {
  final preset = _pestGuides[crop.id];
  if (preset != null) {
    return preset(crop);
  }
  return _PestGuide(
    crop: crop,
    mainPest: crop.pests.first,
    symptoms: const <String>[
      'Daño visible en hojas, brotes o frutos.',
      'Pérdida de vigor y crecimiento irregular.',
    ],
    prevention: const <String>[
      'Monitorear el lote cada semana.',
      'Eliminar residuos enfermos y controlar malezas.',
    ],
    control: const <String>[
      'Priorizar control biológico o mecánico cuando sea viable.',
      'Aplicar productos registrados solo con diagnóstico confirmado.',
    ],
    goodPractices: const <String>[
      'Rotar cultivos y evitar aplicaciones calendarizadas.',
      'Registrar fecha, producto y resultado de cada intervención.',
    ],
    season: crop.season,
  );
}

final Map<String, _PestGuide Function(CropCatalogItem)> _pestGuides = {
  'maiz': (crop) => _PestGuide(
    crop: crop,
    mainPest: 'Gusano cogollero',
    symptoms: const <String>[
      'Perforaciones y raspado en hojas nuevas.',
      'Excremento oscuro dentro del cogollo.',
      'Plantas retrasadas o cogollos destruidos.',
    ],
    prevention: const <String>[
      'Revisar cogollos desde emergencia hasta etapa vegetativa.',
      'Evitar siembras escalonadas sin monitoreo.',
      'Conservar enemigos naturales en bordes y refugios.',
    ],
    control: const <String>[
      'Intervenir temprano cuando haya larvas pequeñas.',
      'Usar Bacillus thuringiensis o control biológico disponible.',
      'Rotar ingredientes activos para reducir resistencia.',
    ],
    goodPractices: const <String>[
      'Muestrear al menos 20 plantas por punto del lote.',
      'Aplicar al cogollo y calibrar volumen de aspersión.',
    ],
    season: 'Primavera-verano, con mayor riesgo en clima cálido y húmedo',
  ),
  'sorgo': (crop) => _PestGuide(
    crop: crop,
    mainPest: 'Pulgones',
    symptoms: const <String>[
      'Hojas pegajosas por mielecilla.',
      'Amarillamiento y enrollamiento de hojas.',
      'Presencia de fumagina sobre la planta.',
    ],
    prevention: const <String>[
      'Evitar exceso de nitrógeno.',
      'Revisar el envés de hojas y zonas bajas del cultivo.',
    ],
    control: const <String>[
      'Favorecer catarinas, crisopas y parasitoides.',
      'Aplicar jabón potásico o producto registrado si supera umbral.',
    ],
    goodPractices: const <String>[
      'No eliminar enemigos naturales con insecticidas de amplio espectro.',
      'Registrar focos iniciales y tratarlos de forma dirigida.',
    ],
    season: 'Verano-otoño, especialmente en periodos secos',
  ),
  'soja': (crop) => _PestGuide(
    crop: crop,
    mainPest: 'Mosca blanca',
    symptoms: const <String>[
      'Adultos blancos al mover el follaje.',
      'Amarillamiento y debilitamiento de hojas.',
      'Mielecilla y fumagina en ataques altos.',
    ],
    prevention: const <String>[
      'Mantener bordes limpios de hospederos.',
      'Evitar estrés hídrico y revisar brotes tiernos.',
    ],
    control: const <String>[
      'Usar trampas amarillas para monitoreo.',
      'Aplicar control biológico o productos selectivos registrados.',
    ],
    goodPractices: const <String>[
      'Rotar modos de acción.',
      'No mover material infestado a lotes sanos.',
    ],
    season: 'Primavera-verano, con picos en calor y baja lluvia',
  ),
  'tomate': (crop) => _PestGuide(
    crop: crop,
    mainPest: 'Mosca blanca',
    symptoms: const <String>[
      'Hojas amarillas y pegajosas.',
      'Fumagina y debilitamiento general.',
      'Riesgo de virosis en brotes nuevos.',
    ],
    prevention: const <String>[
      'Usar malla, trampas amarillas y plántula sana.',
      'Eliminar malezas hospederas alrededor del cultivo.',
    ],
    control: const <String>[
      'Liberar controladores biológicos donde sea posible.',
      'Aplicar productos selectivos y rotar modos de acción.',
    ],
    goodPractices: const <String>[
      'Separar ciclos viejos de trasplantes nuevos.',
      'Desinfectar herramientas y retirar plantas con virosis severa.',
    ],
    season: 'Todo el año, con presión alta en calor',
  ),
  'chile': (crop) => _PestGuide(
    crop: crop,
    mainPest: 'Trips',
    symptoms: const <String>[
      'Plateado o raspado en hojas y frutos.',
      'Deformación de brotes tiernos.',
      'Caída de flores en infestaciones fuertes.',
    ],
    prevention: const <String>[
      'Instalar trampas azules o amarillas.',
      'Controlar malezas y evitar polvo en el lote.',
    ],
    control: const <String>[
      'Dirigir aplicaciones a brotes y flores.',
      'Alternar control biológico con productos selectivos registrados.',
    ],
    goodPractices: const <String>[
      'Monitorear antes de floración.',
      'Evitar aplicaciones repetidas del mismo ingrediente activo.',
    ],
    season: 'Primavera-verano, más frecuente en clima seco',
  ),
};
