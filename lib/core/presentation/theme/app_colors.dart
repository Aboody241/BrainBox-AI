import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand & Core Tokens from Design Specification
  static const Color primary = Color(0xFF141718);
  static const Color secondary = Color(0xFFF7F7F8);
  static const Color background = Color(0xFFF7F8FA);
  static const Color textfields = Color(0xFFFFFFFF);
  static const Color textfieldIcons = Color(0xFFC2C3CB);
  static const Color dividers = Color(0xFFC2C3CB);
  static const Color unavailableButtons = Color(0xFFE3E3E3);

  // Text Colors
  static const Color textPrimary = Color(0xFF141718);
  static const Color textSecondary = Color(0xFF6C7275);
  static const Color textTertiary = Color(0xFFA0A3BD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textDisabled = Color(0xFF9E9E9E);

  // Surface & Cards
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color userBubble = Color(0xFF141718);
  static const Color aiBubble = Color(0xFFF7F7F8);

  // Status & Feedback Colors
  static const Color error = Color(0xFFE53935);
  static const Color errorBackground = Color(0xFFFFEBEE);
  static const Color success = Color(0xFF43A047);
  static const Color successBackground = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFFB8C00);
  static const Color warningBackground = Color(0xFFFFF3E0);
  static const Color info = Color(0xFF1E88E5);

  // Interactive & State
  static const Color transparent = Colors.transparent;
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
}
