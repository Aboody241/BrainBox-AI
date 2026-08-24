import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Standardized SnackBar utility for displaying pop-up alerts and notifications.
class AppSnackBar {
  const AppSnackBar._();

  static void showError(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 4),
  }) {
    _show(
      context,
      message: message,
      title: title ?? 'Error',
      backgroundColor: const Color(0xFF1E1010),
      accentColor: const Color(0xFFEF4444),
      icon: Icons.error_outline,
      duration: duration,
    );
  }

  static void showSuccess(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message: message,
      title: title ?? 'Success',
      backgroundColor: const Color(0xFF0F1B14),
      accentColor: const Color(0xFF22C55E),
      icon: Icons.check_circle_outline,
      duration: duration,
    );
  }

  static void showInfo(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message: message,
      title: title,
      backgroundColor: AppColors.primary,
      accentColor: const Color(0xFF3B82F6),
      icon: Icons.info_outline,
      duration: duration,
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    String? title,
    required Color backgroundColor,
    required Color accentColor,
    required IconData icon,
    required Duration duration,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        duration: duration,
        elevation: 6,
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.roundedLg,
          side: BorderSide(color: accentColor.withValues(alpha: 0.4), width: 1),
        ),
        margin: const EdgeInsets.all(AppSpacing.lg),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        content: Row(
          children: [
            Icon(icon, color: accentColor, size: 22),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null && title.isNotEmpty)
                    Text(
                      title,
                      style: AppTypography.titleSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  Text(
                    message,
                    style: AppTypography.bodyMedium.copyWith(
                      color: const Color(0xFFD1D5DB),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
