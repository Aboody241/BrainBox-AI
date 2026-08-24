import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

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
  final Uint8List? imageBytes;
  final String? imagePath;

  ChatMessageItem({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isStreaming = false,
    this.imageBytes,
    this.imagePath,
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
  Uint8List? _attachedImageBytes;
  String? _attachedImagePath;

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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _attachedImageBytes = bytes;
          _attachedImagePath = pickedFile.path;
        });
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(
          context,
          message: 'Could not attach image: $e',
        );
      }
    }
  }

  void _showImageSourceModal() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  title: Text(
                    'Take Photo',
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.photo_library_outlined,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  title: Text(
                    'Choose from Gallery',
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _sendMessage([String? customText]) async {
    final text = (customText ?? _messageController.text).trim();
    final imageBytes = _attachedImageBytes;
    final imagePath = _attachedImagePath;

    if ((text.isEmpty && imageBytes == null) || _isGenerating) return;

    final userMsg = ChatMessageItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
      imageBytes: imageBytes,
      imagePath: imagePath,
    );

    setState(() {
      _messages.add(userMsg);
      _isGenerating = true;
      _attachedImageBytes = null;
      _attachedImagePath = null;
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
              imageBytes: m.imageBytes,
              imagePath: m.imagePath,
            ))
        .toList();

    await _streamSubscription?.cancel();

    if (sl.isRegistered<StreamChatResponseUseCase>()) {
      final streamUseCase = sl<StreamChatResponseUseCase>();
      final promptToSend = text.isEmpty ? 'Describe this image in detail.' : text;

      _streamSubscription = streamUseCase(
        promptToSend,
        history: history,
        imageBytes: imageBytes,
      ).listen(
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
              // Floating App Bar (Hides on Scroll Down, Shows on Scroll Up)
              _buildFloatingTopBar(),

              // Messages / Empty State Content
              Expanded(
                child: NotificationListener<UserScrollNotification>(
                  onNotification: (notification) {
                    if (notification.direction == ScrollDirection.reverse) {
                      if (_isTopBarVisible) {
                        setState(() => _isTopBarVisible = false);
                      }
                    } else if (notification.direction ==
                        ScrollDirection.forward) {
                      if (!_isTopBarVisible) {
                        setState(() => _isTopBarVisible = true);
                      }
                    }
                    return true;
                  },
                  child: _messages.isEmpty
                      ? _buildEmptyState()
                      : _buildMessagesList(),
                ),
              ),

              // Stop Generating Button (Visible when AI is streaming)
              if (_isGenerating) ...[
                _buildStopGeneratingButton(),
                const SizedBox(height: AppSpacing.xs),
              ],

              // Attached Image Thumbnail Preview (if picked)
              _buildAttachedImagePreview(),

              // Message Input Bar
              _buildMessageInputField(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachedImagePreview() {
    if (_attachedImageBytes == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs, left: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                  width: 1.2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Image.memory(
                  _attachedImageBytes!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: -6,
              right: -6,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _attachedImageBytes = null;
                    _attachedImagePath = null;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Color(0xFF141718),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingTopBar() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: _isTopBarVisible
          ? Container(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button with custom container
                  InkWell(
                    onTap: () => context.pop(),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),

                  // Center Chat Title
                  Text(
                    'Chat',
                    style: AppTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  // Right Options / Menu Action
                  InkWell(
                    onTap: _showChatOptions,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.more_horiz_rounded,
                          size: 22,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xl),
          // Centered BrainBox Title
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

          // 5 Prompt Suggestion Cards
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
        crossAxisAlignment: CrossAxisAlignment.end,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (item.imageBytes != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        item.imageBytes!,
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (item.text.isNotEmpty) const SizedBox(height: 8),
                  ],
                  if (item.text.isNotEmpty)
                    Text(
                      item.text,
                      style: AppTypography.bodyMedium.copyWith(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        fontSize: 14.5,
                        height: 1.4,
                      ),
                    ),
                ],
              ),
            ),
          ),
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
        : 'Regenerate previous answer';
    _sendMessage(prompt);
  }

  Widget _buildStopGeneratingButton() {
    return Center(
      child: InkWell(
        onTap: _stopGenerating,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
              width: 1.2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.stop_circle_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Stop Generating',
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  fontSize: 13,
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: _showImageSourceModal,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 6,
              ),
              child: SvgPicture.asset(
                'assets/icons/image_upload.svg',
                width: 18,
                height: 22,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: TextField(
              controller: _messageController,
              onSubmitted: (_) => _sendMessage(),
              textInputAction: TextInputAction.send,
              decoration: InputDecoration(
                hintText: _attachedImageBytes != null
                    ? 'Ask about this image...'
                    : 'Send a message.',
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
              final isNotEmpty =
                  value.text.trim().isNotEmpty || _attachedImageBytes != null;
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
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red,
                  ),
                  title: const Text(
                    'Clear Chat History',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _messages.clear();
                    });
                    AppSnackBar.showSuccess(
                      context,
                      message: 'Chat history cleared',
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
