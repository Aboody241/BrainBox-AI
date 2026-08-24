import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/presentation/responsive/responsive.dart';
import '../../../../core/presentation/theme/app_colors.dart';
import '../../../../core/presentation/theme/app_radius.dart';
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: AppCenteredContent(
          maxWidth: AppBreakpoints.maxFormWidth,
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: SingleChildScrollView(
            child: AppCard(
              borderRadius: AppRadius.roundedXl,
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.isEmail ? 'Verify Email' : 'Verify Phone',
                    textAlign: TextAlign.center,
                    style: AppTypography.displayMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'We Have Sent Code To Your ${widget.isEmail ? "Email" : "Phone Number"}',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.target,
                    textAlign: TextAlign.center,
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  AppOtpInput(
                    length: 4,
                    onChanged: (code) => _enteredCode = code,
                    onCompleted: (code) {
                      _enteredCode = code;
                      _handleVerify();
                    },
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  AppButton.primary(
                    text: 'Verify',
                    isLoading: _isSubmitting,
                    onPressed: _handleVerify,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton.secondary(
                    text: 'Send Again',
                    onPressed: () {
                      AppSnackBar.showInfo(
                        context,
                        message: 'Code resent to ${widget.target}',
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
