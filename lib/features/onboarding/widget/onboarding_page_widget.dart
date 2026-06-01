import 'package:flutter/material.dart';
import 'package:spendly/theme/theme_extensions.dart';

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
          // Image card
          Container(
            decoration: BoxDecoration(
              color: context.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagePath,
                height: 350,
                width: 350,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 48),

          if (isTitleRich)
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: titlePart1,
                    style: TextStyle(
                      color:
                          context.colors.primaryContainer != Colors.transparent
                          ? context.colors.onPrimaryContainer
                          : context.colors.onSurface,
                    ),
                  ),
                  const TextSpan(text: ' '),
                  TextSpan(
                    text: titlePart2,
                    style: TextStyle(color: context.colors.primary),
                  ),
                ],
              ),
            )
          else
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

          const SizedBox(height: 16),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.subtitleColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
