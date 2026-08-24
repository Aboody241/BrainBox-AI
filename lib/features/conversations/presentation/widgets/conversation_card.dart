import 'package:flutter/material.dart';

import '../../../../core/presentation/theme/app_colors.dart';
import '../../../../core/presentation/theme/app_spacing.dart';
import '../../../../core/presentation/theme/app_typography.dart';

class ConversationItem {
  final String id;
  String title;
  final String lastMessage;
  final DateTime updatedAt;
  bool isPinned;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;

  ConversationItem({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.updatedAt,
    this.isPinned = false,
    this.icon = Icons.chat_bubble_outline_rounded,
    this.iconBgColor = const Color(0xFFECEEF1),
    this.iconColor = AppColors.primary,
  });
}

class ConversationCard extends StatelessWidget {
  final ConversationItem conversation;
  final VoidCallback onTap;
  final VoidCallback onPinToggle;
  final VoidCallback onDelete;
  final void Function(String newTitle)? onRename;

  const ConversationCard({
    super.key,
    required this.conversation,
    required this.onTap,
    required this.onPinToggle,
    required this.onDelete,
    this.onRename,
  });

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      final hour = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = dateTime.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.month}/${dateTime.day}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 0.9,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Topic Squircle Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: conversation.iconBgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Icon(
                      conversation.icon,
                      color: conversation.iconColor,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // Title & Last Snippet
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversation.title,
                              style: AppTypography.titleSmall.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (conversation.isPinned) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.push_pin_rounded,
                              size: 16,
                              color: AppColors.primary,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        conversation.lastMessage,
                        style: AppTypography.bodySmall.copyWith(
                          color: const Color(0xFF6B7280),
                          fontSize: 13,
                          height: 1.35,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),

                // Timestamp & Options
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatTimestamp(conversation.updatedAt),
                      style: AppTypography.labelMedium.copyWith(
                        color: const Color(0xFF9CA3AF),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _showOptionsBottomSheet(context),
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.more_horiz_rounded,
                          size: 20,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(
                    conversation.isPinned
                        ? Icons.push_pin_outlined
                        : Icons.push_pin_rounded,
                    color: AppColors.textPrimary,
                  ),
                  title: Text(
                    conversation.isPinned ? 'Unpin Chat' : 'Pin to Top',
                    style: AppTypography.titleSmall,
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    onPinToggle();
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.edit_outlined,
                    color: AppColors.textPrimary,
                  ),
                  title: const Text('Rename Chat', style: AppTypography.titleSmall),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _showRenameDialog(context);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red,
                  ),
                  title: const Text(
                    'Delete Chat',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    onDelete();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRenameDialog(BuildContext context) {
    final controller = TextEditingController(text: conversation.title);
    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Rename Conversation'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter new title',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newText = controller.text.trim();
                if (newText.isNotEmpty && onRename != null) {
                  onRename!(newText);
                }
                Navigator.of(dialogCtx).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
