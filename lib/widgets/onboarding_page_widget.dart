import 'package:flutter/material.dart';

class OnboardingPageWidget extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final bool isTitleRich;
  final String? titlePart1;
  final String? titlePart2;

  const OnboardingPageWidget({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    this.isTitleRich = false,
    this.titlePart1,
    this.titlePart2,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // The image with styling matching the design
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagePath,
                height: 250,
                width: 250,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 48),

          if (isTitleRich)
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff274C77),
                ),
                children: [
                  TextSpan(text: titlePart1),
                  const TextSpan(text: ' '),
                  TextSpan(
                    text: titlePart2,
                    style: const TextStyle(color: Color(0xff0466C8)),
                  ),
                ],
              ),
            )
          else
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xff274C77),
              ),
            ),

          const SizedBox(height: 16),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
