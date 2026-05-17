import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/pest_control_guide.dart';
import '../services/pest_control_service.dart';

class PestControlScreen extends StatelessWidget {
  const PestControlScreen({super.key, this.initialCropId});

  final String? initialCropId;

  @override
  Widget build(BuildContext context) {
    final guides = PestControlService.guides(cropId: initialCropId);

    return Scaffold(
      backgroundColor: AppColors.screenBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.screenBackground(context),
        foregroundColor: AppColors.primaryText(context),
        elevation: 0,
        title: const Text('Control de plagas'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        itemCount: guides.length,
        itemBuilder: (context, index) {
          return _PestGuideCard(guide: guides[index]);
        },
      ),
    );
  }
}

class _PestGuideCard extends StatelessWidget {
  const _PestGuideCard({required this.guide});

  final PestControlGuide guide;

  @override
  Widget build(BuildContext context) {
    final crop = guide.crop;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    crop.imageAsset,
                    width: 58,
                    height: 58,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: 58,
                      height: 58,
                      color: crop.badgeColor.withValues(alpha: 0.12),
                      child: Icon(crop.icon, color: crop.badgeColor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        crop.name,
                        style: TextStyle(
                          color: AppColors.primaryText(context),
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${crop.pests.length} plagas registradas',
                        style: TextStyle(
                          color: AppColors.greenText(context),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _RegisteredPests(pests: crop.pests),
            const SizedBox(height: 12),
            _SeasonPill(text: guide.season),
            const SizedBox(height: 12),
            _GuideBlock(title: 'Síntomas comunes', items: guide.symptoms),
            _GuideBlock(title: 'Métodos preventivos', items: guide.prevention),
            _GuideBlock(
              title: 'Recomendaciones de control',
              items: guide.control,
            ),
            _GuideBlock(
              title: 'Buenas prácticas agrícolas',
              items: guide.goodPractices,
            ),
          ],
        ),
      ),
    );
  }
}

class _SeasonPill extends StatelessWidget {
  const _SeasonPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.greenIconBackground(context),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          'Temporada: $text',
          style: TextStyle(
            color: AppColors.greenText(context),
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _RegisteredPests extends StatelessWidget {
  const _RegisteredPests({required this.pests});

  final List<String> pests;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plagas registradas',
          style: TextStyle(
            color: AppColors.primaryText(context),
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: pests.map((pest) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.greenIconBackground(context),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                pest,
                style: TextStyle(
                  color: AppColors.greenText(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _GuideBlock extends StatelessWidget {
  const _GuideBlock({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 7),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: AppColors.greenText(context),
                    size: 17,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        color: AppColors.primaryText(context),
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
