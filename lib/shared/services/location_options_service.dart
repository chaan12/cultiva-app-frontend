import '../models/app_location.dart';

class LocationOptionsService {
  const LocationOptionsService._();

  static const List<AppLocation> options = <AppLocation>[
    AppLocation(
      latitude: 21.8853,
      longitude: -102.2916,
      label: 'Aguascalientes, Aguascalientes',
    ),
    AppLocation(
      latitude: 32.6245,
      longitude: -115.4523,
      label: 'Mexicali, Baja California',
    ),
    AppLocation(
      latitude: 24.1426,
      longitude: -110.3128,
      label: 'La Paz, Baja California Sur',
    ),
    AppLocation(
      latitude: 19.8301,
      longitude: -90.5349,
      label: 'Campeche, Campeche',
    ),
    AppLocation(
      latitude: 19.7464,
      longitude: -89.8441,
      label: 'Hopelchén, Campeche',
    ),
    AppLocation(
      latitude: 16.7516,
      longitude: -93.1029,
      label: 'Tuxtla Gutiérrez, Chiapas',
    ),
    AppLocation(
      latitude: 28.6353,
      longitude: -106.0889,
      label: 'Chihuahua, Chihuahua',
    ),
    AppLocation(
      latitude: 19.4326,
      longitude: -99.1332,
      label: 'Ciudad de México, Ciudad de México',
    ),
    AppLocation(
      latitude: 25.4232,
      longitude: -101.0053,
      label: 'Saltillo, Coahuila',
    ),
    AppLocation(
      latitude: 19.2433,
      longitude: -103.7241,
      label: 'Colima, Colima',
    ),
    AppLocation(
      latitude: 24.0277,
      longitude: -104.6532,
      label: 'Durango, Durango',
    ),
    AppLocation(
      latitude: 19.2826,
      longitude: -99.6557,
      label: 'Toluca, Estado de México',
    ),
    AppLocation(
      latitude: 21.0190,
      longitude: -101.2574,
      label: 'Guanajuato, Guanajuato',
    ),
    AppLocation(
      latitude: 17.5515,
      longitude: -99.5006,
      label: 'Chilpancingo, Guerrero',
    ),
    AppLocation(
      latitude: 20.1011,
      longitude: -98.7591,
      label: 'Pachuca, Hidalgo',
    ),
    AppLocation(
      latitude: 20.6597,
      longitude: -103.3496,
      label: 'Guadalajara, Jalisco',
    ),
    AppLocation(
      latitude: 19.7008,
      longitude: -101.1844,
      label: 'Morelia, Michoacán',
    ),
    AppLocation(
      latitude: 18.9242,
      longitude: -99.2216,
      label: 'Cuernavaca, Morelos',
    ),
    AppLocation(
      latitude: 21.5085,
      longitude: -104.8957,
      label: 'Tepic, Nayarit',
    ),
    AppLocation(
      latitude: 25.6866,
      longitude: -100.3161,
      label: 'Monterrey, Nuevo León',
    ),
    AppLocation(
      latitude: 17.0732,
      longitude: -96.7266,
      label: 'Oaxaca, Oaxaca',
    ),
    AppLocation(
      latitude: 19.0414,
      longitude: -98.2063,
      label: 'Puebla, Puebla',
    ),
    AppLocation(
      latitude: 20.5888,
      longitude: -100.3899,
      label: 'Querétaro, Querétaro',
    ),
    AppLocation(
      latitude: 18.5001,
      longitude: -88.2961,
      label: 'Chetumal, Quintana Roo',
    ),
    AppLocation(
      latitude: 22.1565,
      longitude: -100.9855,
      label: 'San Luis Potosí, San Luis Potosí',
    ),
    AppLocation(
      latitude: 24.8091,
      longitude: -107.3940,
      label: 'Culiacán, Sinaloa',
    ),
    AppLocation(
      latitude: 29.0729,
      longitude: -110.9559,
      label: 'Hermosillo, Sonora',
    ),
    AppLocation(
      latitude: 17.9892,
      longitude: -92.9475,
      label: 'Villahermosa, Tabasco',
    ),
    AppLocation(
      latitude: 23.7369,
      longitude: -99.1411,
      label: 'Ciudad Victoria, Tamaulipas',
    ),
    AppLocation(
      latitude: 19.3182,
      longitude: -98.2375,
      label: 'Tlaxcala, Tlaxcala',
    ),
    AppLocation(
      latitude: 19.5438,
      longitude: -96.9102,
      label: 'Xalapa, Veracruz',
    ),
    AppLocation(
      latitude: 20.9674,
      longitude: -89.5926,
      label: 'Mérida, Yucatán',
    ),
    AppLocation(
      latitude: 20.6896,
      longitude: -88.2019,
      label: 'Valladolid, Yucatán',
    ),
    AppLocation(
      latitude: 21.1429,
      longitude: -88.1510,
      label: 'Tizimín, Yucatán',
    ),
    AppLocation(
      latitude: 20.9301,
      longitude: -89.0187,
      label: 'Izamal, Yucatán',
    ),
    AppLocation(
      latitude: 20.4614,
      longitude: -89.4325,
      label: 'Tekax, Yucatán',
    ),
    AppLocation(
      latitude: 21.0971,
      longitude: -89.2833,
      label: 'Motul, Yucatán',
    ),
    AppLocation(
      latitude: 22.7709,
      longitude: -102.5832,
      label: 'Zacatecas, Zacatecas',
    ),
  ];

  static List<String> get states {
    final values = options.map(stateOf).toSet().toList()..sort();
    return values;
  }

  static List<AppLocation> optionsForState(String state) {
    final values = options.where((option) => stateOf(option) == state).toList()
      ..sort((a, b) => a.label.compareTo(b.label));
    return values;
  }

  static String stateOf(AppLocation location) {
    final parts = location.label.split(',');
    return parts.length > 1 ? parts.last.trim() : location.label;
  }

  static AppLocation? byLabel(String label) {
    for (final option in options) {
      if (option.label == label) {
        return option;
      }
    }
    return null;
  }
}
