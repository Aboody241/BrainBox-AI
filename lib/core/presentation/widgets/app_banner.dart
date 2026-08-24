import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

enum AppBannerVariant {
  info,
  error,
  success,
  warning,
}

/// An inline notification banner for error/info message presentation.
class AppBanner extends StatelessWidget {
  final String title;
  final String? message;
  final AppBannerVariant variant;
  final VoidCallback? onClose;

  const AppBanner({
    super.key,
    required this.title,
    this.message,
    this.variant = AppBannerVariant.info,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color borderAndIconColor;
    IconData iconData;

    switch (variant) {
      case AppBannerVariant.info:
        backgroundColor = const Color(0xFFF0F4FF);
        borderAndIconColor = const Color(0xFF3B82F6);
        iconData = Icons.info_outline;
      case AppBannerVariant.error:
        backgroundColor = const Color(0xFFFFF0F0);
        borderAndIconColor = const Color(0xFFEF4444);
        iconData = Icons.error_outline;
      case AppBannerVariant.success:
        backgroundColor = const Color(0xFFF0FDF4);
        borderAndIconColor = const Color(0xFF22C55E);
        iconData = Icons.check_circle_outline;
      case AppBannerVariant.warning:
        backgroundColor = const Color(0xFFFFFBEB);
        borderAndIconColor = const Color(0xFFF59E0B);
        iconData = Icons.warning_amber_rounded;
    }

    final messageText = message;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadius.roundedLg,
        border: Border.all(color: borderAndIconColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(iconData, color: borderAndIconColor, size: 20),
          const SizedBox(width: AppSpacing.sm + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (messageText != null && messageText.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    messageText,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onClose != null)
            GestureDetector(
              onTap: onClose,
              child: const Icon(
                Icons.close,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}
