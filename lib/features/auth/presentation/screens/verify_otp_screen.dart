import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/presentation/responsive/responsive.dart';
import '../../../../core/presentation/theme/app_colors.dart';
import '../../../../core/presentation/theme/app_spacing.dart';
import '../../../../core/presentation/theme/app_typography.dart';
import '../../../../core/presentation/widgets/widgets.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String target;
  final bool isEmail;

  const VerifyOtpScreen({
    super.key,
    required this.target,
    this.isEmail = true,
  });

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  String _enteredCode = '';
  bool _isSubmitting = false;

  Future<void> _handleVerify() async {
    if (_enteredCode.length < 4) {
      AppSnackBar.showError(context, message: 'Please enter 4-digit code.');
      return;
    }

    setState(() => _isSubmitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    AppSnackBar.showSuccess(context, message: 'Verification successful!');
    context.go(AppRoutes.home);
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
                // Top Reusable Back Button
                const AppBackButton(),
                const SizedBox(height: AppSpacing.xl),

                Text(
                  widget.isEmail ? 'Verify Email' : 'Verify Phone',
                  style: AppTypography.displayMedium.copyWith(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'We Have Sent Code To Your ${widget.isEmail ? "Email" : "Phone Number"}',
                  style: AppTypography.bodySmall.copyWith(
                    color: const Color(0xFF9CA3AF),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.target,
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // OTP Inputs
                AppOtpInput(
                  length: 4,
                  onChanged: (code) => _enteredCode = code,
                  onCompleted: (code) {
                    _enteredCode = code;
                    _handleVerify();
                  },
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Verify Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleVerify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: AppColors.primary.withValues(alpha: 0.3),
                      shape: const StadiumBorder(),
                    ),
                    child: _isSubmitting
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
                            'Verify',
                            style: AppTypography.titleSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Send Again Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      AppSnackBar.showInfo(
                        context,
                        message: 'Code resent to ${widget.target}',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE5E7EB),
                      foregroundColor: const Color(0xFF9CA3AF),
                      elevation: 0,
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      'Send Again',
                      style: AppTypography.titleSmall.copyWith(
                        color: const Color(0xFF9CA3AF),
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
}
