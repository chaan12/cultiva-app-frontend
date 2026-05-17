import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/services/pdf_download_service.dart';
import '../../../shared/widgets/cultiva_snackbar.dart';
import '../../crop_register/screens/crop_register_screen.dart';
import '../../crops_catalog/models/crop_catalog_item.dart';
import '../../crops_catalog/screens/pest_control_screen.dart';
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroBanner(context, crop),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 34),
              child: Column(
                children: [
                  _spotlightCard(
                    context,
                    accent: accent,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _dataTile(
                                context,
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
                                context,
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
                                context,
                                label: 'Densidad',
                                value: crop.plantingDensity,
                                accent: accent,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _miniFact(
                                context,
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
                    context,
                    title: 'Condiciones recomendadas',
                    icon: Icons.thermostat_outlined,
                    accent: accent,
                    background: lightTint,
                    child: Column(
                      children: [
                        _bulletRow(
                          context,
                          icon: Icons.device_thermostat_outlined,
                          text: 'Temperatura ideal: ${crop.idealTemperature}',
                        ),
                        _bulletRow(
                          context,
                          icon: Icons.water_drop_outlined,
                          text:
                              'Requerimiento hídrico: ${crop.waterRequirement}',
                        ),
                        _bulletRow(
                          context,
                          icon: Icons.wb_sunny_outlined,
                          text: 'Exposición solar: ${crop.sunExposure}',
                        ),
                      ],
                    ),
                  ),
                  _sectionCard(
                    context,
                    title: 'Suelo y establecimiento',
                    icon: Icons.landscape_outlined,
                    accent: accent,
                    child: Column(
                      children: [
                        _bulletRow(
                          context,
                          icon: Icons.grass_outlined,
                          text: 'Tipo de suelo: ${crop.soilType}',
                        ),
                        _bulletRow(
                          context,
                          icon: Icons.science_outlined,
                          text: 'pH recomendado: ${crop.soilPh}',
                        ),
                        _bulletRow(
                          context,
                          icon: Icons.scatter_plot_outlined,
                          text: 'Densidad de siembra: ${crop.plantingDensity}',
                        ),
                      ],
                    ),
                  ),
                  _sectionCard(
                    context,
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
                              context,
                              icon: Icons.eco_outlined,
                              text: item,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _sectionCard(
                    context,
                    title: 'Sanidad del cultivo',
                    icon: Icons.bug_report_outlined,
                    accent: accent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: crop.pests.map((item) {
                            final isDark = AppColors.isDark(context);
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF341D16)
                                    : const Color(0xFFFFF1EC),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF7C2D12)
                                      : const Color(0xFFFFD0BF),
                                ),
                              ),
                              child: Text(
                                item,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? const Color(0xFFFDBA74)
                                      : const Color(0xFF9A3412),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      PestControlScreen(initialCropId: crop.id),
                                ),
                              );
                            },
                            icon: const Icon(Icons.health_and_safety_outlined),
                            label: const Text('Ver recomendaciones de control'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground(context),
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
                        Text(
                          'Acciones',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.greenText(context),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Descarga la ficha técnica o registra una plantación de este cultivo.',
                          style: TextStyle(
                            color: AppColors.mutedText(context),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final pdfAssetPath = crop.pdfAssetPath;
                            if (pdfAssetPath == null) {
                              showCultivaSnackBar(
                                context,
                                message:
                                    'Ficha técnica no disponible para este cultivo.',
                                color: Colors.orange,
                                icon: Icons.info_outline,
                              );
                              return;
                            }
                            try {
                              await pdfService.downloadAssetPdf(
                                assetPath: pdfAssetPath,
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
                            crop.pdfAssetPath == null
                                ? 'Ficha técnica no disponible'
                                : 'Descargar ficha técnica',
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

  Widget _buildHeroBanner(BuildContext context, CropCatalogItem crop) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
      child: SizedBox(
        width: double.infinity,
        height: 430,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              crop.imageAsset,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (_, _, _) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: crop.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(
                  crop.icon,
                  color: Colors.white.withValues(alpha: 0.72),
                  size: 120,
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.22),
                    AppColors.greenDark.withValues(alpha: 0.60),
                    AppColors.greenDark.withValues(alpha: 0.92),
                  ],
                  stops: const [0.0, 0.48, 1.0],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 54, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.28),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      crop.season,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    crop.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      height: 0.95,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    crop.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.38,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _heroMetric(
                          label: 'Ciclo',
                          value: '${crop.cycleDays} días',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _heroMetric(
                          label: 'Temperatura',
                          value: crop.idealTemperature,
                        ),
                      ),
                      const SizedBox(width: 10),
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

  Widget _spotlightCard(
    BuildContext context, {
    required Color accent,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
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

  Widget _dataTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required Color background,
  }) {
    final isDark = AppColors.isDark(context);
    final foreground = isDark ? Color.lerp(color, Colors.white, 0.25)! : color;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? color.withValues(alpha: 0.12) : background,
        borderRadius: BorderRadius.circular(22),
        border: isDark
            ? Border.all(color: color.withValues(alpha: 0.30))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withValues(alpha: isDark ? 0.22 : 0.15),
            child: Icon(icon, color: foreground, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(color: AppColors.mutedText(context), fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniFact(
    BuildContext context, {
    required String label,
    required String value,
    required Color accent,
  }) {
    final isDark = AppColors.isDark(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: isDark ? 0.13 : 0.08),
        borderRadius: BorderRadius.circular(18),
        border: isDark
            ? Border.all(color: accent.withValues(alpha: 0.20))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: AppColors.mutedText(context), fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.greenText(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color accent,
    required Widget child,
    Color? background,
  }) {
    final isDark = AppColors.isDark(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardBackground(context)
            : background ?? AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: accent.withValues(alpha: isDark ? 0.25 : 0.12),
        ),
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
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.greenText(context),
                  ),
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

  Widget _bulletRow(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.greenText(context)),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: AppColors.primaryText(context),
                height: 1.4,
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
