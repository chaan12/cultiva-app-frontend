import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/services/pdf_download_service.dart';
import '../../../shared/widgets/cultiva_snackbar.dart';
import '../../crop_register/screens/crop_register_screen.dart';
import '../../crops_catalog/services/crop_catalog_service.dart';

class CropDetailsScreen extends StatelessWidget {
  const CropDetailsScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final crop = CropCatalogService.byId(id);
    final pdfService = PdfDownloadService();
    final accent = crop.badgeColor;
    final lightTint = accent.withValues(alpha: 0.10);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 54, 20, 28),
              decoration: const BoxDecoration(
                color: AppColors.greenDark,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(36),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                crop.season,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              crop.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                height: 0.95,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              crop.description,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 98,
                        height: 118,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Image.asset(
                          crop.imageAsset,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _heroMetric(
                          label: 'Ciclo',
                          value: '${crop.cycleDays} días',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _heroMetric(
                          label: 'Temperatura',
                          value: crop.idealTemperature,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _heroMetric(
                          label: 'Rendimiento',
                          value: crop.expectedYield,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 34),
              child: Column(
                children: [
                  _spotlightCard(
                    accent: accent,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _dataTile(
                                icon: Icons.calendar_today,
                                title: 'Siembra',
                                value: crop.sowingWindow,
                                color: const Color(0xFF2E7D32),
                                background: const Color(0xFFE8F5E9),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _dataTile(
                                icon: Icons.spa,
                                title: 'Cosecha',
                                value: crop.harvestWindow,
                                color: const Color(0xFFEF6C00),
                                background: const Color(0xFFFFF3E0),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _miniFact(
                                label: 'Densidad',
                                value: crop.plantingDensity,
                                accent: accent,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _miniFact(
                                label: 'pH',
                                value: crop.soilPh,
                                accent: accent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _sectionCard(
                    title: 'Condiciones recomendadas',
                    icon: Icons.thermostat_outlined,
                    accent: accent,
                    background: lightTint,
                    child: Column(
                      children: [
                        _bulletRow(
                          icon: Icons.device_thermostat_outlined,
                          text: 'Temperatura ideal: ${crop.idealTemperature}',
                        ),
                        _bulletRow(
                          icon: Icons.water_drop_outlined,
                          text:
                              'Requerimiento hídrico: ${crop.waterRequirement}',
                        ),
                        _bulletRow(
                          icon: Icons.wb_sunny_outlined,
                          text: 'Exposición solar: ${crop.sunExposure}',
                        ),
                      ],
                    ),
                  ),
                  _sectionCard(
                    title: 'Suelo y establecimiento',
                    icon: Icons.landscape_outlined,
                    accent: accent,
                    child: Column(
                      children: [
                        _bulletRow(
                          icon: Icons.grass_outlined,
                          text: 'Tipo de suelo: ${crop.soilType}',
                        ),
                        _bulletRow(
                          icon: Icons.science_outlined,
                          text: 'pH recomendado: ${crop.soilPh}',
                        ),
                        _bulletRow(
                          icon: Icons.scatter_plot_outlined,
                          text: 'Densidad de siembra: ${crop.plantingDensity}',
                        ),
                      ],
                    ),
                  ),
                  _sectionCard(
                    title: 'Nutrición y rendimiento',
                    icon: Icons.bar_chart_rounded,
                    accent: accent,
                    background: const Color(0xFFFFFBF0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            'Rendimiento esperado: ${crop.expectedYield}',
                            style: TextStyle(
                              color: accent,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        ...crop.fertilizers.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _bulletRow(
                              icon: Icons.eco_outlined,
                              text: item,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _sectionCard(
                    title: 'Sanidad del cultivo',
                    icon: Icons.bug_report_outlined,
                    accent: accent,
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: crop.pests
                          .map(
                            (item) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF1EC),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: const Color(0xFFFFD0BF),
                                ),
                              ),
                              child: Text(
                                item,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF9A3412),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Acciones',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.greenDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Descarga la ficha técnica o registra una plantación de este cultivo.',
                          style: TextStyle(color: Colors.grey, height: 1.4),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () async {
                            try {
                              await pdfService.downloadAssetPdf(
                                assetPath: crop.pdfAssetPath,
                                fileName: '${crop.id}_ficha_tecnica.pdf',
                              );
                            } on PdfDownloadException catch (error) {
                              if (!context.mounted) {
                                return;
                              }
                              showCultivaSnackBar(
                                context,
                                message: error.message,
                                color: Colors.redAccent,
                                icon: Icons.picture_as_pdf_outlined,
                              );
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 54),
                            side: BorderSide(color: accent, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          icon: Icon(Icons.download_outlined, color: accent),
                          label: Text(
                            'Descargar ficha técnica',
                            style: TextStyle(
                              color: accent,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    CropRegisterScreen(initialCropId: crop.id),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.greenDark,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          icon: const Icon(
                            Icons.add_circle_outline,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Registrar plantación de ${crop.name}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
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

  Widget _heroMetric({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _spotlightCard({required Color accent, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _dataTile({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required Color background,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: AppColors.greenDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniFact({
    required String label,
    required String value,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.greenDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Color accent,
    required Widget child,
    Color background = Colors.white,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: accent.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.greenDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _bulletRow({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.greenDark),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(height: 1.4))),
        ],
      ),
    );
  }
}
