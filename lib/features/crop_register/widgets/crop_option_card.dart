import 'package:flutter/material.dart';

import '../../crops_catalog/models/crop_catalog_item.dart';

class CropOptionCard extends StatelessWidget {
  const CropOptionCard({super.key, required this.item, required this.onTap});

  final CropCatalogItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: Image.asset(
                item.imageAsset,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              item.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF0D5D33),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${item.cycleDays} días',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              item.season,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
