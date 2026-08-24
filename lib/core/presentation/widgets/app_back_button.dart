import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';

class AppBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final double size;

  const AppBackButton({
    super.key,
    this.onPressed,
    this.icon = Icons.chevron_left,
    this.size = 44.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          icon,
          size: size * 0.58,
          color: AppColors.textPrimary,
        ),
        onPressed: onPressed ?? () => context.pop(),
      ),
    );
  }
}
