import 'package:flutter/material.dart';
import 'package:spendly/theme/app_gradients.dart';
import 'package:spendly/theme/app_radius.dart';
import 'package:spendly/theme/colors.dart';
import 'package:spendly/theme/theme_extensions.dart';

class ChatEmptyState extends StatelessWidget {
  final ValueChanged<String> onSuggestionSelected;

  const ChatEmptyState({
    super.key,
    required this.onSuggestionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppGradients.chatBot,
              borderRadius: AppRadius.xxlBorderRadius,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'How can I help you today?',
            style: context.textTheme.headlineSmall?.copyWith(
              color: context.colors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ask me about budgeting, saving, or expenses',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.subtitleColor,
            ),
          ),
          const SizedBox(height: 36),
          _buildSuggestionChips(context),
        ],
      ),
    );
  }

  Widget _buildSuggestionChips(BuildContext context) {
    final suggestions = [
      '💰 How to save more?',
      '📊 Budget tips',
      '💳 Track expenses',
    ];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: suggestions.map((s) {
        return GestureDetector(
          onTap: () {
            // Remove emojis and special characters to clean the query, matching original behavior
            final cleanText = s.replaceAll(RegExp(r'[^\w\s?]'), '').trim();
            onSuggestionSelected(cleanText);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: AppGradients.chatBot,
              borderRadius: AppRadius.fullBorderRadius,
            ),
            child: Text(
              s,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
