import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

enum AppBadgeVariant {
  primary,
  secondary,
  success,
}

/// A pill badge component (e.g. "Most Popular" or status indicators).
class AppBadge extends StatelessWidget {
  final String text;
  final AppBadgeVariant variant;
  final Widget? icon;

  const AppBadge({
    super.key,
    required this.text,
    this.variant = AppBadgeVariant.primary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color foregroundColor;

    switch (variant) {
      case AppBadgeVariant.primary:
        backgroundColor = AppColors.primary;
        foregroundColor = AppColors.textOnPrimary;
      case AppBadgeVariant.secondary:
        backgroundColor = const Color(0xFFE8ECEF);
        foregroundColor = AppColors.textPrimary;
      case AppBadgeVariant.success:
        backgroundColor = const Color(0xFF00C076);
        foregroundColor = AppColors.textOnPrimary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadius.roundedFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            text,
            style: AppTypography.labelMedium.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
