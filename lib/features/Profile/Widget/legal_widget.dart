import 'package:flutter/material.dart';

class LegalWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final String subtitle1;
  final String subtitle2;
  final Color iconColor;
  final Color iconBackgroundColor;
  const LegalWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.subtitle1,
    required this.subtitle2,
    required this.iconColor,
    required this.iconBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 🔹 Subtitle 1
          Text(
            subtitle1,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),

          const SizedBox(height: 10),

          // 🔹 Subtitle 2
          Text(
            subtitle2,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),

          const SizedBox(height: 16),

          // 🔹 Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                "Read Full Policy",
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
