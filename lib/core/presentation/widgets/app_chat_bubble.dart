import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// A sleek chat message bubble component supporting both User and AI responses.
class AppChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final String? timestamp;
  final Widget? avatar;
  final List<Widget>? actions;

  const AppChatBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.timestamp,
    this.avatar,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isUser ? AppColors.primary : AppColors.surface;
    final textColor = isUser ? AppColors.textOnPrimary : AppColors.textPrimary;
    final alignment = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final actionsList = actions;

    final borderRadius = isUser
        ? const BorderRadius.only(
            topLeft: Radius.circular(AppRadius.lg),
            topRight: Radius.circular(AppRadius.lg),
            bottomLeft: Radius.circular(AppRadius.lg),
            bottomRight: Radius.circular(4),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(AppRadius.lg),
            topRight: Radius.circular(AppRadius.lg),
            bottomRight: Radius.circular(AppRadius.lg),
            bottomLeft: Radius.circular(4),
          );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                avatar ?? _defaultAiAvatar(),
                const SizedBox(width: AppSpacing.sm),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: borderRadius,
                    border: isUser
                        ? null
                        : Border.all(
                            color: AppColors.dividers.withValues(alpha: 0.5)),
                    boxShadow: isUser
                        ? null
                        : const [
                            BoxShadow(
                              color: Color(0x05000000),
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Text(
                    message,
                    style: AppTypography.bodyMedium.copyWith(
                      color: textColor,
                      height: 1.45,
                    ),
                  ),
                ),
              ),
              if (isUser) ...[
                const SizedBox(width: AppSpacing.sm),
                avatar ?? _defaultUserAvatar(),
              ],
            ],
          ),
          if (timestamp != null || (actionsList != null && actionsList.isNotEmpty)) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                if (!isUser) const SizedBox(width: 40),
                if (timestamp != null)
                  Text(
                    timestamp!,
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                if (actionsList != null && actionsList.isNotEmpty) ...[
                  const SizedBox(width: AppSpacing.sm),
                  ...actionsList,
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _defaultAiAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(
          Icons.auto_awesome,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }

  Widget _defaultUserAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: Color(0xFFE8ECEF),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(
          Icons.person_outline,
          color: AppColors.primary,
          size: 18,
        ),
      ),
    );
  }
}
