import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/service_locator.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/presentation/responsive/responsive.dart';
import '../../../../core/presentation/theme/app_colors.dart';
import '../../../../core/presentation/theme/app_spacing.dart';
import '../../../../core/presentation/theme/app_typography.dart';
import '../../../../core/presentation/widgets/widgets.dart';
import '../viewmodels/auth_state.dart';
import '../viewmodels/auth_view_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showForm = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_showForm) {
      setState(() => _showForm = true);
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final authVm = sl<AuthViewModel>();
    final success = await authVm.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      context.go(AppRoutes.home);
    } else {
      final state = authVm.state;
      if (state is AuthError) {
        AppSnackBar.showError(context, message: state.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVm = sl<AuthViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AppCenteredContent(
          maxWidth: AppBreakpoints.maxFormWidth,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          child: ListenableBuilder(
            listenable: authVm,
            builder: (context, _) {
              final isLoading = authVm.state is AuthLoading;

              return Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.xl),
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

                      // Optional Form fields
                      if (_showForm) ...[
                        AppTextField(
                          controller: _emailController,
                          hintText: 'Email Address',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(
                            Icons.mail_outline,
                            color: AppColors.textfieldIcons,
                          ),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          controller: _passwordController,
                          hintText: 'Password',
                          isPassword: true,
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: AppColors.textfieldIcons,
                          ),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],

                      // Main Log in Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shadowColor: AppColors.primary.withValues(alpha: 0.3),
                            shape: const StadiumBorder(),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  _showForm ? 'Sign In' : 'Log in',
                                  style: AppTypography.titleSmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Sign up Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () => context.push(AppRoutes.register),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE5E7EB),
                            foregroundColor: const Color(0xFF9CA3AF),
                            elevation: 0,
                            shape: const StadiumBorder(),
                          ),
                          child: Text(
                            'Sign up',
                            style: AppTypography.titleSmall.copyWith(
                              color: const Color(0xFF9CA3AF),
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
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Mock Google Auth
                                  _emailController.text = 'user@example.com';
                                  _passwordController.text = 'password123';
                                  _handleLogin();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF8D7D0),
                                  foregroundColor: const Color(0xFFD9534F),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  'GOOGLE',
                                  style: AppTypography.titleSmall.copyWith(
                                    color: const Color(0xFFD9534F),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Mock Facebook Auth
                                  _emailController.text = 'user@example.com';
                                  _passwordController.text = 'password123';
                                  _handleLogin();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD6E2F5),
                                  foregroundColor: const Color(0xFF3B5998),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  'FACEBOOK',
                                  style: AppTypography.titleSmall.copyWith(
                                    color: const Color(0xFF3B5998),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
