import '../models/crop_catalog_item.dart';
import '../models/pest_control_guide.dart';
import 'crop_catalog_service.dart';

class PestControlService {
  const PestControlService._();

  static List<PestControlGuide> guides({String? cropId}) {
    return CropCatalogService.items
        .where((crop) => cropId == null || crop.id == cropId)
        .map(guideFor)
        .toList();
  }

  static PestControlGuide guideFor(CropCatalogItem crop) {
    final preset = _pestGuides[crop.id];
    if (preset != null) {
      return preset(crop);
    }
    return PestControlGuide(
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
}

final Map<String, PestControlGuide Function(CropCatalogItem)> _pestGuides = {
  'maiz': (crop) => PestControlGuide(
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
  'sorgo': (crop) => PestControlGuide(
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
  'soja': (crop) => PestControlGuide(
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
  'tomate': (crop) => PestControlGuide(
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
  'chile': (crop) => PestControlGuide(
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
