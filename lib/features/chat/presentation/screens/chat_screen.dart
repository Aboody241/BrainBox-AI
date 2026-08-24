import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/responsive/responsive.dart';
import '../../../../core/presentation/theme/app_colors.dart';
import '../../../../core/presentation/theme/app_spacing.dart';
import '../../../../core/presentation/theme/app_typography.dart';
import '../../../../core/presentation/widgets/widgets.dart';

class ChatMessageItem {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessageItem({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatScreen extends StatefulWidget {
  final String conversationId;

  const ChatScreen({
    super.key,
    required this.conversationId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessageItem> _messages = [];
  bool _isGenerating = false;

  static const List<String> _capabilityPrompts = [
    'Remembers what user said earlier in the conversation',
    'Allows user to provide. follow-up corrections With Ai',
    'Limited knowledge of world and events after 2021',
    'May occasionally generate incorrect information',
    'May occasionally produce harmful instructions or biased content',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
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

  Future<void> _sendMessage([String? customText]) async {
    final text = (customText ?? _messageController.text).trim();
    if (text.isEmpty || _isGenerating) return;

    setState(() {
      _messages.add(
        ChatMessageItem(
          text: text,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isGenerating = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // Simulate AI response stream
    await Future<void>.delayed(const Duration(milliseconds: 750));
    if (!mounted) return;

    setState(() {
      _messages.add(
        ChatMessageItem(
          text:
              'I am BrainBox AI, your smart conversational assistant. How can I help you achieve your goals today?',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
      _isGenerating = false;
    });

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AppCenteredContent(
          maxWidth: AppBreakpoints.maxFormWidth,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Column(
            children: [
              // Top Bar
              _buildTopBar(),

              // Content Area (Welcome cards if empty, or Messages list)
              Expanded(
                child: _messages.isEmpty
                    ? _buildEmptyWelcomeState()
                    : _buildMessagesList(),
              ),

              // Bottom Input Box
              _buildMessageInputField(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Reusable Back Button
          const AppBackButton(),

          // More Options Button
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.more_horiz_rounded,
                size: 26,
                color: Color(0xFFC2C3CB),
              ),
              onPressed: () {
                _showChatOptions();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWelcomeState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xl),
          // Heading Title
          Text(
            'BrainBox',
            textAlign: TextAlign.center,
            style: AppTypography.displayLarge.copyWith(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // 5 Capability & Disclaimer Cards
          ..._capabilityPrompts.map(
            (prompt) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: InkWell(
                onTap: () => _sendMessage(prompt),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.lg,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 233, 234, 238),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    prompt,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySmall.copyWith(
                      color: const Color(0xFF7E848D),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      itemCount: _messages.length + (_isGenerating ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isGenerating) {
          return const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: AppSpacing.sm),
                Text('BrainBox is thinking...'),
              ],
            ),
          );
        }

        final item = _messages[index];
        return AppChatBubble(
          message: item.text,
          isUser: item.isUser,
          timestamp:
              '${item.timestamp.hour.toString().padLeft(2, '0')}:${item.timestamp.minute.toString().padLeft(2, '0')}',
        );
      },
    );
  }

  Widget _buildMessageInputField() {
    return Container(
      margin: const EdgeInsets.only(
        top: AppSpacing.xs,
        bottom: AppSpacing.xs,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              onSubmitted: (_) => _sendMessage(),
              textInputAction: TextInputAction.send,
              decoration: InputDecoration(
                hintText: 'Send a message.',
                hintStyle: AppTypography.bodySmall.copyWith(
                  color: const Color(0xFFC2C3CB),
                  fontSize: 14,
                ),
                filled: false,
                fillColor: Colors.transparent,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: AppSpacing.sm,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _messageController,
            builder: (context, value, _) {
              final isNotEmpty = value.text.trim().isNotEmpty;
              return GestureDetector(
                onTap: () => _sendMessage(),
                behavior: HitTestBehavior.opaque,
                child: SvgPicture.asset(
                  isNotEmpty
                      ? 'assets/icons/Send.svg'
                      : 'assets/icons/send_icon.svg',
                  width: 24,
                  height: 24,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showChatOptions() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'Clear Chat',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  setState(() => _messages.clear());
                  context.pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
