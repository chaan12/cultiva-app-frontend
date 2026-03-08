import 'package:flutter/material.dart';
import '../../crop_details/screens/crop_details_screen.dart';

// --- MODELO DE DATOS ---
class CultivoCatalogo {
  final String id;
  final String nombre;
  final String temporada;
  final String imagen;
  final Color temporadaColor;

  CultivoCatalogo({
    required this.id,
    required this.nombre,
    required this.temporada,
    required this.imagen,
    required this.temporadaColor,
  });
}

class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  int currentIndex = 2; // Index 2 para la pestaña "Catálogo"

  // Datos idénticos a tu archivo React
  final List<CultivoCatalogo> cultivos = [
    CultivoCatalogo(
      id: 'maiz',
      nombre: 'Maíz',
      temporada: 'Primavera-Verano',
      imagen:
          'https://images.unsplash.com/photo-1691326564837-51e3619f1d70?q=80&w=400',
      temporadaColor: const Color(0xFF00C853),
    ),
    CultivoCatalogo(
      id: 'tomate',
      nombre: 'Tomate',
      temporada: 'Todo el año',
      imagen:
          'https://images.unsplash.com/photo-1683008952375-410ae668e6b9?q=80&w=400',
      temporadaColor: const Color(0xFF0D5D33),
    ),
    CultivoCatalogo(
      id: 'chile',
      nombre: 'Chile Habanero',
      temporada: 'Primavera-Verano',
      imagen:
          'https://images.unsplash.com/photo-1720420866056-07fe15991f16?q=80&w=400',
      temporadaColor: const Color(0xFF00C853),
    ),
    CultivoCatalogo(
      id: 'frijol',
      nombre: 'Frijol',
      temporada: 'Primavera-Otoño',
      imagen:
          'https://images.unsplash.com/photo-1605402966404-ec40b9bd5009?q=80&w=400',
      temporadaColor: Colors.orange,
    ),
    CultivoCatalogo(
      id: 'sandia',
      nombre: 'Sandía',
      temporada: 'Primavera-Verano',
      imagen:
          'https://images.unsplash.com/photo-1724167381533-4c91f4658e89?q=80&w=400',
      temporadaColor: const Color(0xFF00C853),
    ),
    CultivoCatalogo(
      id: 'calabaza',
      nombre: 'Calabaza',
      temporada: 'Primavera-Verano',
      imagen:
          'https://images.unsplash.com/photo-1570586437263-ab629fccc818?q=80&w=400',
      temporadaColor: const Color(0xFF00C853),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4E0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Catálogo de cultivos",
          style: TextStyle(
            color: Color(0xFF0D5D33),
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 15),
            child: _buildSearchBar(),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: cultivos.length,
        itemBuilder: (context, index) {
          return _fadeInUp(
            delay: index * 100,
            child: _buildCropCard(cultivos[index]),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: "Buscar cultivo...",
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildCropCard(CultivoCatalogo cultivo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CropDetailsScreen(id: cultivo.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Imagen del cultivo
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  cultivo.imagen,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 90,
                    height: 90,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Info del cultivo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cultivo.nombre,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D5D33),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: cultivo.temporadaColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        cultivo.temporada,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  // Helper de animación idéntico a los anteriores
  Widget _fadeInUp({required int delay, required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      child: child,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
    );
  }
}
