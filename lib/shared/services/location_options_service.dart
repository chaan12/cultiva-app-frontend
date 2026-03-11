import '../models/app_location.dart';

class LocationOptionsService {
  const LocationOptionsService._();

  static const List<AppLocation> options = <AppLocation>[
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
      latitude: 19.7464,
      longitude: -89.8441,
      label: 'Hopelchén, Campeche',
    ),
    AppLocation(
      latitude: 19.8301,
      longitude: -90.5349,
      label: 'Campeche, Campeche',
    ),
  ];

  static AppLocation? byLabel(String label) {
    for (final option in options) {
      if (option.label == label) {
        return option;
      }
    }
    return null;
  }
}
