import 'package:flutter/material.dart';

import '../../../shared/models/crop_record.dart';

class CropRecordCard extends StatelessWidget {
  const CropRecordCard({super.key, required this.crop, required this.onTap});

  final CropRecord crop;
  final VoidCallback onTap;

  Color get _statusColor {
    switch (crop.status) {
      case 'evento-proximo':
        return const Color(0xFFF59E0B);
      case 'alerta':
        return Colors.redAccent;
      default:
        return const Color(0xFF00C853);
    }
  }

  String get _statusLabel {
    switch (crop.status) {
      case 'evento-proximo':
        return 'EVENTO';
      case 'alerta':
        return 'ALERTA';
      default:
        return 'NORMAL';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      crop.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${crop.formattedArea} • Día ${crop.daysSinceSowing}/${crop.cycleDays}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                    Text(
                      crop.locationName,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel,
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      crop.currentStage,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      '${crop.progress}%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: crop.progress / 100,
                  backgroundColor: _statusColor.withValues(alpha: 0.1),
                  color: _statusColor,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(10),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.event_note_rounded, color: _statusColor),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          crop.nextEventLabel,
                          style: TextStyle(
                            color: _statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                GestureDetector(
                  onTap: onTap,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ver seguimiento detallado',
                        style: TextStyle(
                          color: Color(0xFF0D5D33),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Color(0xFF0D5D33)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
