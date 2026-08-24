import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// A styled surface container card matching the BrainBox design system.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final BorderRadius? borderRadius;
  final Border? border;
  final List<BoxShadow>? shadows;
  final double? width;
  final double? height;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.onTap,
    this.backgroundColor = AppColors.surface,
    this.borderRadius,
    this.border,
    this.shadows,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? AppRadius.roundedXl;

    final Widget content = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: effectiveRadius,
        border: border,
        boxShadow: shadows ??
            const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 20,
                offset: Offset(0, 4),
              ),
            ],
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: AppColors.transparent,
        borderRadius: effectiveRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveRadius,
          child: content,
        ),
      );
    }

    return content;
  }
}
