import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// A feature list tile component with leading/trailing badges matching the pricing/plan aesthetic.
class AppFeatureTile extends StatelessWidget {
  final String title;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final Color backgroundColor;

  const AppFeatureTile({
    super.key,
    required this.title,
    this.leadingIcon,
    this.trailingIcon,
    this.backgroundColor = const Color(0xFFF7F9FC),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md - 2,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadius.roundedFull,
      ),
      child: Row(
        children: [
          if (leadingIcon != null) ...[
            leadingIcon!,
            const SizedBox(width: AppSpacing.md),
          ] else ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF00C076), width: 1.5),
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Color(0xFF00C076),
                size: 16,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Text(
              title,
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
          if (trailingIcon != null)
            trailingIcon!
          else
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFF00C076),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 16,
              ),
            ),
        ],
      ),
    );
  }
}
