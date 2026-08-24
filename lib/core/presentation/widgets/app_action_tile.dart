import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_card.dart';

/// A selectable action tile with leading circular icon badge (e.g. Email/Phone selection).
class AppActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget icon;
  final VoidCallback? onTap;
  final bool isSelected;
  final Widget? trailing;

  const AppActionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
    this.isSelected = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md + 2,
      ),
      borderRadius: AppRadius.roundedLg,
      border: isSelected
          ? Border.all(color: AppColors.primary, width: 1.5)
          : Border.all(color: AppColors.transparent),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFF0F1F3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: IconTheme(
                data: const IconThemeData(
                  color: AppColors.primary,
                  size: 22,
                ),
                child: icon,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
