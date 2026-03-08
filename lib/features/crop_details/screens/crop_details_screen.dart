import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CropDetailsScreen extends StatelessWidget {
  final String id;

  const CropDetailsScreen({super.key, required this.id});

  static final Map<String, Map<String, dynamic>> cultivosData = {
    "maiz": {
      "nombre": "Maíz",
      "imagen":
          "https://images.unsplash.com/photo-1691326564837-51e3619f1d70?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=1080",
      "fechasSiembra": "Abril - Junio",
      "fechasCosecha": "Agosto - Octubre",
      "cicloVegetativo": "90-120 días",
      "descripcion":
          "Cultivo base de la agricultura maya, adaptado al clima tropical.",
      "fertilizantes": [
        "Nitrógeno (N): 120-150 kg/ha",
        "Fósforo (P₂O₅): 60-80 kg/ha",
        "Potasio (K₂O): 40-60 kg/ha",
      ],
      "plagas": ["Gusano cogollero", "Barrenador del tallo", "Gallina ciega"],
    },
    "tomate": {
      "nombre": "Tomate",
      "imagen":
          "https://images.unsplash.com/photo-1683008952375-410ae668e6b9?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=1080",
      "fechasSiembra": "Todo el año (bajo riego)",
      "fechasCosecha": "75-90 días después de trasplante",
      "cicloVegetativo": "90-120 días",
      "descripcion":
          "Cultivo de alto valor comercial, requiere manejo intensivo.",
      "fertilizantes": [
        "Nitrógeno (N): 150-200 kg/ha",
        "Fósforo (P₂O₅): 100-150 kg/ha",
        "Potasio (K₂O): 200-250 kg/ha",
      ],
      "plagas": ["Mosca blanca", "Gusano del fruto", "Araña roja", "Trips"],
    },
    "chile": {
      "nombre": "Chile Habanero",
      "imagen":
          "https://images.unsplash.com/photo-1720420866056-07fe15991f16?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=1080",
      "fechasSiembra": "Marzo - Mayo",
      "fechasCosecha": "Julio - Octubre",
      "cicloVegetativo": "90-150 días",
      "descripcion": "Cultivo tradicional yucateco con denominación de origen.",
      "fertilizantes": [
        "Nitrógeno (N): 100-120 kg/ha",
        "Fósforo (P₂O₅): 80-100 kg/ha",
        "Potasio (K₂O): 120-150 kg/ha",
      ],
      "plagas": ["Picudo del chile", "Trips", "Mosca blanca", "Áfidos"],
    },
    "frijol": {
      "nombre": "Frijol",
      "imagen":
          "https://images.unsplash.com/photo-1605402966404-ec40b9bd5009?q=80&w=1080",
      "fechasSiembra": "Febrero - Abril / Agosto - Septiembre",
      "fechasCosecha": "Mayo - Julio / Octubre - Noviembre",
      "cicloVegetativo": "70-90 días",
      "descripcion":
          "Cultivo básico en la milpa mesoamericana, complementa nutricionalmente al maíz.",
      "fertilizantes": [
        "Nitrógeno (N): 20-40 kg/ha",
        "Fósforo (P₂O₅): 40-60 kg/ha",
        "Potasio (K₂O): 20-30 kg/ha",
      ],
      "plagas": [
        "Trips",
        "Mosca blanca",
        "Picudo del frijol",
      ],
    },

    "sandia": {
      "nombre": "Sandía",
      "imagen":
          "https://images.unsplash.com/photo-1724167381533-4c91f4658e89?q=80&w=1080",
      "fechasSiembra": "Febrero - Abril",
      "fechasCosecha": "Mayo - Julio",
      "cicloVegetativo": "80-100 días",
      "descripcion":
          "Cultivo de clima cálido muy popular en regiones tropicales por su alto contenido de agua.",
      "fertilizantes": [
        "Nitrógeno (N): 100-120 kg/ha",
        "Fósforo (P₂O₅): 80-100 kg/ha",
        "Potasio (K₂O): 120-150 kg/ha",
      ],
      "plagas": [
        "Mosca blanca",
        "Pulgones",
        "Araña roja",
      ],
    },

    "calabaza": {
      "nombre": "Calabaza",
      "imagen":
          "https://images.unsplash.com/photo-1570586437263-ab629fccc818?q=80&w=1080",
      "fechasSiembra": "Marzo - Mayo",
      "fechasCosecha": "Junio - Septiembre",
      "cicloVegetativo": "90-120 días",
      "descripcion":
          "Parte del sistema tradicional de milpa junto con maíz y frijol, ayuda a conservar la humedad del suelo.",
      "fertilizantes": [
        "Nitrógeno (N): 80-100 kg/ha",
        "Fósforo (P₂O₅): 60-80 kg/ha",
        "Potasio (K₂O): 80-100 kg/ha",
      ],
      "plagas": [
        "Trips",
        "Pulgones",
        "Escarabajo del pepino",
      ],
    },
  };

  @override
  Widget build(BuildContext context) {
    final cultivo = cultivosData[id] ?? cultivosData["maiz"]!;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Image.network(
                  cultivo["imagen"],
                  height: 260,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),

                Container(
                  height: 260,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black54, Colors.transparent],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),

                Positioned(
                  top: 40,
                  left: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back),
                    ),
                  ),
                ),

                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cultivo["nombre"],
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        cultivo["descripcion"],
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: infoCard(
                          Icons.calendar_today,
                          "Siembra",
                          cultivo["fechasSiembra"],
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: infoCard(
                          Icons.spa,
                          "Cosecha",
                          cultivo["fechasCosecha"],
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  cardSection(
                    icon: Icons.access_time,
                    title: "Ciclo vegetativo",
                    child: Text(
                      cultivo["cicloVegetativo"],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  cardSection(
                    icon: Icons.water_drop,
                    title: "Fertilización recomendada",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: (cultivo["fertilizantes"] as List)
                          .map<Widget>(
                            (f) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text("• $f"),
                            ),
                          )
                          .toList(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  cardSection(
                    icon: Icons.bug_report,
                    title: "Plagas principales",
                    child: Wrap(
                      spacing: 8,
                      children: (cultivo["plagas"] as List)
                          .map<Widget>(
                            (p) => Chip(
                              label: Text(p),
                              backgroundColor: Colors.red.shade100,
                            ),
                          )
                          .toList(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download),
                    label: const Text("Descargar ficha técnica (PDF)"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.greenPrimary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 55),
                    ),
                  ),

                  const SizedBox(height: 12),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/registrar");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.greenDark,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 55),
                    ),
                    child: Text("Registrar plantación de ${cultivo["nombre"]}"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget infoCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget cardSection({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
