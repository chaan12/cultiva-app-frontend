import 'package:flutter/material.dart';

import '../../../shared/state/app_scope.dart';
import '../../crop_register/screens/crop_register_screen.dart';
import '../../crop_tracking/screens/crop_tracking_screen.dart';
import '../../crop_tracking/services/crop_tracking_service.dart';
import '../widgets/crop_record_card.dart';

class MisCultivosScreen extends StatelessWidget {
  const MisCultivosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4E0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context, store),
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
                        'Cultivos activos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D5D33),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  if (store.crops.isEmpty)
                    _buildEmptyState(context)
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: store.crops.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final crop = store.crops[index];
                        return CropRecordCard(
                          crop: crop,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CropTrackingScreen(crop: crop),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  const SizedBox(height: 30),
                  if (store.nextHarvestCrop != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.agriculture_rounded,
                            color: Color(0xFF00C853),
                            size: 30,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${store.nextHarvestCrop!.name}: ${CropTrackingService.buildSummary(store.nextHarvestCrop!).nextEventLabel}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic store) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
      decoration: const BoxDecoration(
        color: Color(0xFF0D5D33),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
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
                    'Mis Cultivos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Gestión y seguimiento',
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
              _statCard(store.activeCropsCount.toString(), 'Activos'),
              _statCard(store.totalHectares.toStringAsFixed(1), 'Hectáreas'),
              _statCard(store.upcomingEventsCount.toString(), 'Eventos'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard(String value, String label) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            value,
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

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.agriculture_outlined,
            size: 48,
            color: Color(0xFF0D5D33),
          ),
          const SizedBox(height: 16),
          const Text(
            'Aún no tienes cultivos registrados.',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'Agrega tu primer cultivo para empezar a ver métricas reales.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CropRegisterScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D5D33),
            ),
            child: const Text(
              'Registrar cultivo',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
