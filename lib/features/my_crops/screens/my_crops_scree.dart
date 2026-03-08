import 'package:flutter/material.dart';
import '../../crop_register/screens/crop_register_screen.dart';

class Cultivo {
  final String id;
  final String nombre;
  final String area;
  final String fechaSiembra;
  final int diasDesdeSiembra;
  final String etapaActual;
  final int progreso;
  final String estado;
  final String proximoEvento;
  final int diasCosecha;
  final int totalDias;

  Cultivo({
    required this.id,
    required this.nombre,
    required this.area,
    required this.fechaSiembra,
    required this.diasDesdeSiembra,
    required this.etapaActual,
    required this.progreso,
    required this.estado,
    required this.proximoEvento,
    required this.diasCosecha,
    required this.totalDias,
  });
}

class MisCultivosScreen extends StatefulWidget {
  const MisCultivosScreen({super.key});

  @override
  State<MisCultivosScreen> createState() => _MisCultivosScreenState();
}

class _MisCultivosScreenState extends State<MisCultivosScreen> {
  int currentIndex = 1; 
  
  final List<Cultivo> cultivosRegistrados = [
    Cultivo(
      id: 'maiz-1',
      nombre: 'Maíz',
      area: '2.5 ha',
      fechaSiembra: '15 Abril 2026',
      diasDesdeSiembra: 23,
      etapaActual: 'Crecimiento vegetativo',
      progreso: 19,
      estado: 'evento-proximo',
      proximoEvento: 'Fertilización en 2 días',
      diasCosecha: 97,
      totalDias: 120,
    ),
    Cultivo(
      id: 'chile-1',
      nombre: 'Chile Habanero',
      area: '1.2 ha',
      fechaSiembra: '5 Marzo 2026',
      diasDesdeSiembra: 64,
      etapaActual: 'Floración',
      progreso: 43,
      estado: 'normal',
      proximoEvento: 'Riego en 4 días',
      diasCosecha: 56,
      totalDias: 150,
    ),
    Cultivo(
      id: 'tomate-1',
      nombre: 'Tomate',
      area: '0.8 ha',
      fechaSiembra: '1 Febrero 2026',
      diasDesdeSiembra: 98,
      etapaActual: 'Fructificación',
      progreso: 82,
      estado: 'alerta',
      proximoEvento: '¡Cosecha en 5 días!',
      diasCosecha: 5,
      totalDias: 120,
    ),
  ];

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'evento-proximo':
        return const Color(0xFFF59E0B); // Amber
      case 'alerta':
        return Colors.redAccent;
      default:
        return const Color(0xFF00C853); // Green
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4E0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER ---
            _buildHeader(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),
                  const Row(
                    children: [
                      Icon(Icons.trending_up, color: Color(0xFF0D5D33)),
                      SizedBox(width: 8),
                      Text(
                        "Cultivos activos",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D5D33),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cultivosRegistrados.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _buildCultivoCard(cultivosRegistrados[index]);
                    },
                  ),

                  const SizedBox(height: 30),
                  const Text(
                    "Completados",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildPastCropCard(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
      decoration: const BoxDecoration(
        color: Color(0xFF0D5D33),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Mis Cultivos",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Gestión y seguimiento",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CropRegisterScreen(),
                    ),
                  );
                },
                child: CircleAvatar(
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(cultivosRegistrados.length.toString(), "Activos"),
              _buildStatItem("4.5", "Hectáreas"),
              _buildStatItem("2", "Eventos"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String val, String label) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues( alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            val,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildCultivoCard(Cultivo cultivo) {
    Color statusColor = _getEstadoColor(cultivo.estado);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues( alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Cabecera de la Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withValues( alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cultivo.nombre,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${cultivo.area} • Día ${cultivo.diasDesdeSiembra}/${cultivo.totalDias}",
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    cultivo.estado.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Barra de Progreso y Contenido
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      cultivo.etapaActual,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      "${cultivo.progreso}%",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: cultivo.progreso / 100,
                  backgroundColor: statusColor.withValues( alpha: 0.1),
                  color: statusColor,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(10),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withValues( alpha: 0.05),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.water_drop_outlined,
                        color: statusColor,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        cultivo.proximoEvento,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Ver seguimiento detallado",
                      style: TextStyle(
                        color: Color(0xFF0D5D33),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Color(0xFF0D5D33)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPastCropCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues( alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Frijol",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                "3.0 ha • Oct 2025 - Ene 2026",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                "Rendimiento: 1.8 ton/ha",
                style: TextStyle(
                  color: Color(0xFF00C853),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Icon(Icons.check_circle, color: Color(0xFF00C853), size: 30),
        ],
      ),
    );
  }
}
