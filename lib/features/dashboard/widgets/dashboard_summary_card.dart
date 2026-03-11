import 'package:flutter/material.dart';

class DashboardSummaryCard extends StatelessWidget {
  const DashboardSummaryCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
    this.backgroundColor = Colors.white,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(
                  0xFF0D5D33,
                ).withValues(alpha: 0.08),
                child: Icon(icon, color: const Color(0xFF0D5D33)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
