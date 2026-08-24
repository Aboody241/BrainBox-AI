import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_button.dart';

enum AppEmptyStateType {
  generic,
  noMessages,
  noNetwork,
  noResult,
  noCards,
}

/// A comprehensive Empty State component for handling missing content, network drops, empty search, etc.
class AppEmptyState extends StatelessWidget {
  final AppEmptyStateType type;
  final String? title;
  final String? subtitle;
  final Widget? customIllustration;
  final String? actionButtonText;
  final VoidCallback? onActionTap;

  const AppEmptyState({
    super.key,
    this.type = AppEmptyStateType.generic,
    this.title,
    this.subtitle,
    this.customIllustration,
    this.actionButtonText,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTitle = title ?? _defaultTitle(type);
    final effectiveSubtitle = subtitle ?? _defaultSubtitle(type);
    final iconData = _defaultIcon(type);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (customIllustration != null)
            customIllustration!
          else
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Color(0xFFF0F1F3),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  iconData,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            effectiveTitle,
            textAlign: TextAlign.center,
            style: AppTypography.displayMedium.copyWith(
              fontSize: 20,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (effectiveSubtitle != null && effectiveSubtitle.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              effectiveSubtitle,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
          if (actionButtonText != null && onActionTap != null) ...[
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: 200,
              child: AppButton.primary(
                text: actionButtonText!,
                onPressed: onActionTap,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _defaultTitle(AppEmptyStateType type) {
    switch (type) {
      case AppEmptyStateType.generic:
        return 'No Data Found';
      case AppEmptyStateType.noMessages:
        return 'No Messages Yet';
      case AppEmptyStateType.noNetwork:
        return 'No Connection';
      case AppEmptyStateType.noResult:
        return 'No Results Found';
      case AppEmptyStateType.noCards:
        return 'No Cards Added';
    }
  }

  String? _defaultSubtitle(AppEmptyStateType type) {
    switch (type) {
      case AppEmptyStateType.generic:
        return 'There is nothing to display here right now.';
      case AppEmptyStateType.noMessages:
        return 'Start a conversation with BrainBox AI to see your chat history here.';
      case AppEmptyStateType.noNetwork:
        return 'Please check your internet connection and try again.';
      case AppEmptyStateType.noResult:
        return 'We couldn\'t find any matches for your query. Try a different search.';
      case AppEmptyStateType.noCards:
        return 'You haven\'t attached any credit or debit cards yet.';
    }
  }

  IconData _defaultIcon(AppEmptyStateType type) {
    switch (type) {
      case AppEmptyStateType.generic:
        return Icons.inbox_outlined;
      case AppEmptyStateType.noMessages:
        return Icons.chat_bubble_outline_rounded;
      case AppEmptyStateType.noNetwork:
        return Icons.wifi_off_rounded;
      case AppEmptyStateType.noResult:
        return Icons.search_off_rounded;
      case AppEmptyStateType.noCards:
        return Icons.credit_card_off_rounded;
    }
  }
}
