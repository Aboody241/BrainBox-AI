import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/service_locator.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/presentation/responsive/responsive.dart';
import '../../../../core/presentation/theme/app_colors.dart';
import '../../../../core/presentation/theme/app_spacing.dart';
import '../../../../core/presentation/theme/app_typography.dart';
import '../viewmodels/auth_state.dart';
import '../viewmodels/auth_view_model.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> _handleSocialAuth(BuildContext context) async {
    final authVm = sl<AuthViewModel>();
    final success = await authVm.login('user@example.com', 'password123');

    if (!context.mounted) return;

    if (success) {
      context.go(AppRoutes.home);
    } else {
      final state = authVm.state;
      if (state is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.message)),
        );
      }
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
            vertical: AppSpacing.lg,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.xxs),
                // App Logo from assets/logos/Logo.svg
                Center(
                  child: SvgPicture.asset(
                    'assets/logos/Logo.svg',
                    width: 86,
                    height: 102,
                    colorFilter: const ColorFilter.mode(
                      AppColors.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                // Title
                Text(
                  'Welcome to',
                  textAlign: TextAlign.center,
                  style: AppTypography.displayMedium.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                Text(
                  'BrainBox',
                  textAlign: TextAlign.center,
                  style: AppTypography.displayMedium.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Main Log in Button -> Navigates to separated Login Form Screen
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => context.push(AppRoutes.loginForm),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: AppColors.primary.withValues(alpha: 0.3),
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      'Log in',
                      style: AppTypography.titleSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Sign up Button -> Navigates to Register Screen
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => context.push(AppRoutes.register),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE5E7EB),
                      foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                      elevation: 0,
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      'Sign up',
                      style: AppTypography.titleSmall.copyWith(
                        color: const Color.fromARGB(255, 0, 0, 0),
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Social login text
                Text(
                  'Continue With Accounts',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(
                    color: const Color(0xFF9CA3AF),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Social Buttons Row
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => _handleSocialAuth(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF8D7D0),
                            foregroundColor: const Color(0xFFD9534F),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/icons/icons8-google-96.png',
                                width: 20,
                                height: 20,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                'GOOGLE',
                                style: AppTypography.titleSmall.copyWith(
                                  color: const Color(0xFFD9534F),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => _handleSocialAuth(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD6E2F5),
                            foregroundColor: const Color(0xFF3B5998),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/icons/icons8-facebook-96.png',
                                width: 20,
                                height: 20,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                'FACEBOOK',
                                style: AppTypography.titleSmall.copyWith(
                                  color: const Color(0xFF3B5998),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
