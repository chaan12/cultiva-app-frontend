import 'package:flutter/material.dart';

class RegisterFieldCard extends StatelessWidget {
  const RegisterFieldCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.controller,
    required this.keyboardType,
    this.suffix,
    this.errorText,
    this.readOnly = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? suffix;
  final String? errorText;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: errorText == null ? Colors.black12 : Colors.red.shade300,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF0D5D33), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F8E9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: errorText == null
                          ? const Color(0xFFE2E9D8)
                          : Colors.red.shade200,
                    ),
                  ),
                  child: TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    readOnly: readOnly,
                    onTap: onTap,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      suffixText: suffix,
                    ),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D5D33),
                    ),
                  ),
                ),
                if (errorText != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    errorText!,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
