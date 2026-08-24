import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/presentation/responsive/responsive.dart';
import '../../../../core/presentation/theme/app_colors.dart';
import '../../../../core/presentation/theme/app_spacing.dart';
import '../../../../core/presentation/theme/app_typography.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  // 'email' or 'phone'
  String _selectedOption = 'email';

  void _handleNext() {
    if (_selectedOption == 'phone') {
      context.push(AppRoutes.enterPhone);
    } else {
      context.push(
        AppRoutes.verifyOtp,
        extra: <String, dynamic>{
          'target': 'user@example.com',
          'isEmail': true,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AppCenteredContent(
          maxWidth: AppBreakpoints.maxFormWidth,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.xs),
                // Top Back Button Card
                Container(
                  width: 44,
                  height: 44,
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
                    icon: const Icon(
                      Icons.chevron_left,
                      size: 26,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: () => context.pop(),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Heading Title
                Text(
                  'Forget Password',
                  style: AppTypography.displayMedium.copyWith(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Select which contact details should we use to reset your password',
                  style: AppTypography.bodySmall.copyWith(
                    color: const Color(0xFF9CA3AF),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Email Option Tile
                _buildOptionTile(
                  id: 'email',
                  icon: Icons.mail_outline,
                  title: 'Email',
                  subtitle: 'Code Send to your email',
                ),
                const SizedBox(height: AppSpacing.md),

                // Phone Option Tile
                _buildOptionTile(
                  id: 'phone',
                  icon: Icons.phone_outlined,
                  title: 'Phone',
                  subtitle: 'Code Send to your email',
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Main Next Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _handleNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: AppColors.primary.withValues(alpha: 0.3),
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      'Next',
                      style: AppTypography.titleSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required String id,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedOption == id;

    return InkWell(
      onTap: () => setState(() => _selectedOption = id),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.textPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: const Color(0xFF9CA3AF),
                      fontSize: 13,
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
