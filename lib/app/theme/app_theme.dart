import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/presentation/theme/app_colors.dart';
import '../../core/presentation/theme/app_radius.dart';
import '../../core/presentation/theme/app_spacing.dart';
import '../../core/presentation/theme/app_typography.dart';

abstract final class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.textOnPrimary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.textPrimary,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: AppColors.textOnPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        titleTextStyle: AppTypography.titleLarge,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          disabledBackgroundColor: AppColors.unavailableButtons,
          disabledForegroundColor: AppColors.textDisabled,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.roundedMd,
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          disabledForegroundColor: AppColors.textDisabled,
          side: const BorderSide(color: AppColors.dividers),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.roundedMd,
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.roundedSm,
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.textfields,
        prefixIconColor: AppColors.textfieldIcons,
        suffixIconColor: AppColors.textfieldIcons,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textTertiary,
        ),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.roundedMd,
          borderSide: BorderSide(color: AppColors.dividers),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.roundedMd,
          borderSide: BorderSide(color: AppColors.dividers),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.roundedMd,
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.roundedMd,
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.roundedMd,
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.dividers,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.primary,
        size: 24,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.roundedMd,
          side: BorderSide(color: AppColors.dividers),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.primary,
        contentTextStyle: TextStyle(color: AppColors.textOnPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.roundedMd,
        ),
      ),
    );
  }
}
