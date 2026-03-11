import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../crops_catalog/services/crop_catalog_service.dart';

class CropDetailsScreen extends StatelessWidget {
  const CropDetailsScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final crop = CropCatalogService.byId(id);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Image.network(
                  crop.heroImageUrl,
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
                        color: Colors.white.withValues(alpha: 0.9),
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
                        crop.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        crop.description,
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
                        child: _infoCard(
                          Icons.calendar_today,
                          'Siembra',
                          crop.sowingWindow,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _infoCard(
                          Icons.spa,
                          'Cosecha',
                          crop.harvestWindow,
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _section(
                    icon: Icons.access_time,
                    title: 'Ciclo vegetativo',
                    child: Text('${crop.cycleDays} días'),
                  ),
                  const SizedBox(height: 16),
                  _section(
                    icon: Icons.science_outlined,
                    title: 'Fertilización sugerida',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: crop.fertilizers
                          .map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text('• $item'),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _section(
                    icon: Icons.bug_report_outlined,
                    title: 'Plagas comunes',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: crop.pests
                          .map(
                            (item) => Chip(
                              label: Text(item),
                              backgroundColor: Colors.orange.withValues(
                                alpha: 0.12,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _section({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.greenDark),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
