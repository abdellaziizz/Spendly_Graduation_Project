import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/features/chatbot/Model/chat_message.dart';
import 'package:spendly/features/chatbot/Provider/chat_provider.dart';
import 'package:spendly/theme/app_gradients.dart';
import 'package:spendly/theme/app_radius.dart';
import 'package:spendly/theme/colors.dart';
import 'package:spendly/theme/theme_extensions.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _controller      = TextEditingController();
  final ScrollController      _scrollController = ScrollController();
  final FocusNode             _focusNode        = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    _focusNode.requestFocus();
    await ref.read(chatProvider.notifier).sendMessage(text);
  }

  @override
  Widget build(BuildContext context) {
    final messages  = ref.watch(chatProvider);
    final isLoading = ref.watch(isLoadingProvider);

    ref.listen(chatProvider, (_, _) => _scrollToBottom());

    return Scaffold(
      backgroundColor: context.isDark
          ? AppColors.chatBgDark
          : AppColors.chatBgLight,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? _buildEmptyState(context)
                : _buildMessageList(context, messages, isLoading),
          ),
          _buildInputArea(context, isLoading),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: context.isDark
          ? AppColors.chatBgDark
          : AppColors.chatBgLight,
      elevation: 0,
      centerTitle: false,
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: AppGradients.chatBot,
              borderRadius: AppRadius.mdBorderRadius,
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your CFO',
                style: context.textTheme.titleMedium?.copyWith(
                  letterSpacing: 0.3,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Always active',
                    style: context.textTheme.labelSmall,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh_rounded, color: context.subtitleColor),
          tooltip: 'New Chat',
          onPressed: () => ref.read(chatProvider.notifier).clearChat(),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
            _controller.text = s.replaceAll(RegExp(r'[^\w\s?]'), '').trim();
            _handleSend();
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

  Widget _buildMessageList(
      BuildContext context, List<Message> messages, bool isLoading) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: messages.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length && isLoading) {
          return _buildTypingIndicator(context);
        }
        return _buildMessageBubble(context, messages[index]);
      },
    );
  }

  Widget _buildMessageBubble(BuildContext context, Message message) {
    final isUser   = message.isUser;
    final aiBubble = context.isDark
        ? AppColors.chatAiBubbleDark
        : AppColors.chatAiBubbleLight;
    final aiTextColor = context.isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                gradient: AppGradients.chatBot,
                borderRadius: AppRadius.smBorderRadius,
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 14,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? AppColors.chatUserBubble : aiBubble,
                borderRadius: BorderRadius.only(
                  topLeft:     const Radius.circular(18),
                  topRight:    const Radius.circular(18),
                  bottomLeft:  Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                boxShadow: isUser
                    ? [
                        BoxShadow(
                          color: AppColors.chatUserBubble.withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : aiTextColor,
                      fontSize: 14.5,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: isUser
                          ? Colors.white.withValues(alpha: 0.5)
                          : context.hintColor,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(BuildContext context) {
    final aiBubble = context.isDark
        ? AppColors.chatAiBubbleDark
        : AppColors.chatAiBubbleLight;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              gradient: AppGradients.chatBot,
              borderRadius: AppRadius.smBorderRadius,
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 14,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: aiBubble,
              borderRadius: const BorderRadius.only(
                topLeft:     Radius.circular(18),
                topRight:    Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft:  Radius.circular(4),
              ),
            ),
            child: const _TypingDots(),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context, bool isLoading) {
    final bgColor = context.isDark ? AppColors.chatBgDark : AppColors.chatBgLight;

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
          top: BorderSide(
            color: context.colors.outline.withValues(alpha: 0.5),
          ),
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
                controller: _controller,
                focusNode: _focusNode,
                style: TextStyle(
                  color: context.onSurface,
                  fontSize: 14.5,
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _handleSend(),
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
            onTap: isLoading ? null : _handleSend,
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
                color: isLoading
                    ? context.hintColor
                    : Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

/// Animated three-dot typing indicator.
class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay   = i * 0.2;
            final t       = ((_ctrl.value - delay) % 1.0).clamp(0.0, 1.0);
            final scale   = t < 0.5 ? 1.0 + t : 2.0 - t;
            final opacity = t < 0.5 ? 0.4 + t * 1.2 : 1.0 - (t - 0.5) * 1.2;
            return Padding(
              padding: EdgeInsets.only(right: i < 2 ? 4 : 0),
              child: Transform.scale(
                scale: scale.clamp(0.7, 1.3),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: context.colors.primary
                        .withValues(alpha: opacity.clamp(0.3, 1.0)),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
