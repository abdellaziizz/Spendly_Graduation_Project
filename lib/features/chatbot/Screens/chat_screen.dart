import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/features/chatbot/Model/chat_message.dart';
import 'package:spendly/features/chatbot/Provider/chat_provider.dart';
import 'package:spendly/features/chatbot/widgets/chat_empty_state.dart';
import 'package:spendly/features/chatbot/widgets/chat_input_area.dart';
import 'package:spendly/features/chatbot/widgets/message_bubble.dart';
import 'package:spendly/features/chatbot/widgets/typing_indicator.dart';
import 'package:spendly/theme/app_gradients.dart';
import 'package:spendly/theme/app_radius.dart';
import 'package:spendly/theme/colors.dart';
import 'package:spendly/theme/theme_extensions.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

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
    final messages = ref.watch(chatProvider);
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
                ? ChatEmptyState(
                    onSuggestionSelected: (suggestion) {
                      _controller.text = suggestion;
                      _handleSend();
                    },
                  )
                : _buildMessageList(context, messages, isLoading),
          ),
          ChatInputArea(
            controller: _controller,
            focusNode: _focusNode,
            isLoading: isLoading,
            onSend: _handleSend,
          ),
        ],
      ),
    );
  }

  // appbar for the chatbot screen with the bot's name and status
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
                  Text('Always active', style: context.textTheme.labelSmall),
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

  // the main chat list showing all messages.
  Widget _buildMessageList(
    BuildContext context,
    List<Message> messages,
    bool isLoading,
  ) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: messages.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length && isLoading) {
          return const TypingIndicator();
        }
        return MessageBubble(message: messages[index]);
      },
    );
  }
}
