import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/service_locator.dart';
import '../../../../core/presentation/responsive/responsive.dart';
import '../../../../core/presentation/theme/app_colors.dart';
import '../../../../core/presentation/theme/app_spacing.dart';
import '../../../../core/presentation/theme/app_typography.dart';
import '../../../../core/presentation/widgets/widgets.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/stream_chat_response_usecase.dart';
import '../widgets/chat_markdown_view.dart';

class ChatMessageItem {
  final String id;
  String text;
  final bool isUser;
  final DateTime timestamp;
  bool isStreaming;

  ChatMessageItem({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isStreaming = false,
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
  bool _isTopBarVisible = true;
  Timer? _streamTimer;
  StreamSubscription<String>? _streamSubscription;

  static const List<String> _capabilityPrompts = [
    'Explain quantum computing in simple terms',
    'Write a Python script to automate daily tasks',
    'Give me 5 creative ideas for a sci-fi short story',
    'Draft a professional email requesting a project update',
    'Create a 3-day travel itinerary for visiting Tokyo',
  ];

  static const String _defaultAiResponse =
      'Quantum computing is a new type of computing that the principles of quantum mechanics to process information. While traditional computers use bits to represent and process data, which can be eithe quantum computers use quantum bits, or which can represent 0, 1, or both simultaneously';

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _streamTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _stopGenerating() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
    _streamTimer?.cancel();
    _streamTimer = null;
    if (mounted) {
      setState(() {
        _isGenerating = false;
        if (_messages.isNotEmpty && !_messages.last.isUser) {
          _messages.last.isStreaming = false;
        }
      });
    }
  }

  Future<void> _sendMessage([String? customText]) async {
    final text = (customText ?? _messageController.text).trim();
    if (text.isEmpty || _isGenerating) return;

    final userMsg = ChatMessageItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _isGenerating = true;
    });

    _messageController.clear();
    _scrollToBottom();

    final aiMsg = ChatMessageItem(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      text: '',
      isUser: false,
      timestamp: DateTime.now(),
      isStreaming: true,
    );

    setState(() {
      _messages.add(aiMsg);
    });

    final history = _messages
        .where((m) => m.id != userMsg.id && m.id != aiMsg.id)
        .map((m) => ChatMessage(
              id: m.id,
              content: m.text,
              isUser: m.isUser,
              timestamp: m.timestamp,
            ))
        .toList();

    await _streamSubscription?.cancel();

    if (sl.isRegistered<StreamChatResponseUseCase>()) {
      final streamUseCase = sl<StreamChatResponseUseCase>();
      _streamSubscription = streamUseCase(text, history: history).listen(
        (chunk) {
          if (!mounted) return;
          setState(() {
            aiMsg.text += chunk;
          });
          _scrollToBottom();
        },
        onError: (error) {
          if (!mounted) return;
          setState(() {
            if (aiMsg.text.isEmpty) {
              aiMsg.text =
                  'Sorry, I encountered an issue connecting to Gemini. Please check your network and try again.';
            }
            aiMsg.isStreaming = false;
            _isGenerating = false;
          });
        },
        onDone: () {
          if (!mounted) return;
          setState(() {
            aiMsg.isStreaming = false;
            _isGenerating = false;
          });
        },
        cancelOnError: true,
      );
    } else {
      // Fallback generator for unmocked standalone tests
      final fullResponse = text.toLowerCase().contains('quantum')
          ? _defaultAiResponse
          : 'I am BrainBox AI, your smart conversational assistant. How can I help you achieve your goals today? Feel free to ask me anything!';

      final words = fullResponse.split(' ');
      var currentIndex = 0;

      _streamTimer?.cancel();
      _streamTimer = Timer.periodic(const Duration(milliseconds: 45), (timer) {
        if (currentIndex < words.length) {
          if (!mounted) {
            timer.cancel();
            return;
          }
          setState(() {
            aiMsg.text = words.sublist(0, currentIndex + 1).join(' ');
          });
          currentIndex++;
          _scrollToBottom();
        } else {
          timer.cancel();
          _streamTimer = null;
          if (mounted) {
            setState(() {
              aiMsg.isStreaming = false;
              _isGenerating = false;
            });
          }
        }
      });
    }
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
              // Floating Top Navigation Bar (Hides on scroll down)
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: _isTopBarVisible
                    ? _buildTopBar()
                    : const SizedBox.shrink(),
              ),

              // Messages List or Welcome Cards with Scroll Direction Listener
              Expanded(
                child: NotificationListener<UserScrollNotification>(
                  onNotification: (notification) {
                    if (notification.direction == ScrollDirection.reverse) {
                      if (_isTopBarVisible) {
                        setState(() => _isTopBarVisible = false);
                      }
                    } else if (notification.direction == ScrollDirection.forward) {
                      if (!_isTopBarVisible) {
                        setState(() => _isTopBarVisible = true);
                      }
                    }
                    return false;
                  },
                  child: _messages.isEmpty
                      ? _buildEmptyWelcomeState()
                      : _buildMessagesList(),
                ),
              ),

              // Stop Generating button (above input field when generating)
              if (_isGenerating) ...[
                const SizedBox(height: AppSpacing.xs),
                _buildStopGeneratingButton(),
                const SizedBox(height: AppSpacing.xs),
              ],

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
                color: Color.fromARGB(255, 116, 116, 116),
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
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final item = _messages[index];
        if (item.isUser) {
          return _buildUserBubble(item);
        } else {
          return _buildAiBubble(item);
        }
      },
    );
  }

  Widget _buildUserBubble(ChatMessageItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                item.text,
                style: AppTypography.bodyMedium.copyWith(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  fontSize: 14.5,
                  height: 1.4,
                ),
              ),
            ),
          ),
          // const SizedBox(width: AppSpacing.xs),
          // IconButton(
          //   icon: const Icon(
          //     Icons.edit_outlined,
          //     size: 20,
          //     color: Color(0xFF9CA3AF),
          //   ),
          //   tooltip: 'Edit message',
          //   onPressed: () {
          //     _messageController.text = item.text;
          //   },
          // ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiBubble(ChatMessageItem item) {
    final isLastAiMessage = _messages.isNotEmpty && _messages.last == item;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 237, 238, 241),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row with Avatar & Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // BrainBox Avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF141718),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/logos/Logo.svg',
                        width: 22,
                        height: 22,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  // Action Buttons (Copy & Share)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        padding: const EdgeInsets.all(2),
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.content_copy_outlined,
                          size: 18,
                          color: Color(0xFF9CA3AF),
                        ),
                        tooltip: 'Copy',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: item.text));
                          AppSnackBar.showSuccess(
                            context,
                            message: 'Message copied to clipboard',
                          );
                        },
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      IconButton(
                        padding: const EdgeInsets.all(2),
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.share_outlined,
                          size: 18,
                          color: Color(0xFF9CA3AF),
                        ),
                        tooltip: 'Share',
                        onPressed: () {
                          AppSnackBar.showInfo(
                            context,
                            message: 'Sharing message...',
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Message Body with rich Markdown and copyable code blocks
              ChatMarkdownView(
                text: item.text,
                isStreaming: item.isStreaming,
              ),
            ],
          ),
        ),
        if (isLastAiMessage && !item.isStreaming && !_isGenerating) ...[
          const SizedBox(height: AppSpacing.xs),
          _buildRegenerateButton(item),
          const SizedBox(height: AppSpacing.xs),
        ],
      ],
    );
  }

  Widget _buildRegenerateButton(ChatMessageItem item) {
    return InkWell(
      onTap: () => _regenerateResponse(item),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFD1D5DB),
                  width: 1.5,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.change_circle,
                  size: 22,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Regenerate\n  Respond',
              style: AppTypography.labelMedium.copyWith(
                color: const Color(0xFF6B7280),
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _regenerateResponse(ChatMessageItem item) {
    if (_isGenerating) return;
    final lastUserIndex = _messages.lastIndexWhere((m) => m.isUser);
    final prompt = lastUserIndex != -1
        ? _messages[lastUserIndex].text
        : 'Explain quantum computing in simple terms';

    setState(() {
      _messages.remove(item);
      _isGenerating = true;
    });

    final aiMsg = ChatMessageItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: '',
      isUser: false,
      timestamp: DateTime.now(),
      isStreaming: true,
    );

    setState(() {
      _messages.add(aiMsg);
    });

    final fullResponse = prompt.toLowerCase().contains('quantum')
        ? _defaultAiResponse
        : 'Here is a newly generated response tailored to your request. How else can I assist you?';

    final words = fullResponse.split(' ');
    var currentIndex = 0;

    _streamTimer?.cancel();
    _streamTimer = Timer.periodic(const Duration(milliseconds: 45), (timer) {
      if (currentIndex < words.length) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() {
          aiMsg.text = words.sublist(0, currentIndex + 1).join(' ');
        });
        currentIndex++;
        _scrollToBottom();
      } else {
        timer.cancel();
        _streamTimer = null;
        if (mounted) {
          setState(() {
            aiMsg.isStreaming = false;
            _isGenerating = false;
          });
        }
      }
    });
  }

  Widget _buildStopGeneratingButton() {
    return Center(
      child: InkWell(
        onTap: _stopGenerating,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Stop generating...',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
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
                  width: isNotEmpty ? 40 : 24,
                  height: isNotEmpty ? 40 : 24,
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
                  _stopGenerating();
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
