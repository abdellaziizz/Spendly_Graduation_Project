import 'package:flutter/material.dart';
import 'package:spendly/theme/app_gradients.dart';
import 'package:spendly/theme/app_radius.dart';
import 'package:spendly/theme/colors.dart';
import 'package:spendly/theme/theme_extensions.dart';

class ChatInputArea extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isLoading;
  final VoidCallback onSend;

  const ChatInputArea({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isLoading,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = context.isDark
        ? AppColors.chatBgDark
        : AppColors.chatBgLight;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 8,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          top: BorderSide(color: context.colors.outline.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest,
                borderRadius: AppRadius.fullBorderRadius,
                border: Border.all(
                  color: context.colors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                style: TextStyle(color: context.onSurface, fontSize: 14.5),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                maxLines: 4,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: 'Ask me anything...',
                  hintStyle: TextStyle(
                    color: context.hintColor,
                    fontSize: 14.5,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: isLoading ? null : onSend,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: isLoading ? null : AppGradients.chatBot,
                color: isLoading
                    ? context.colors.surfaceContainerHighest
                    : null,
                borderRadius: AppRadius.lgBorderRadius,
                boxShadow: isLoading
                    ? null
                    : [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Icon(
                Icons.send_rounded,
                color: isLoading ? context.hintColor : Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
