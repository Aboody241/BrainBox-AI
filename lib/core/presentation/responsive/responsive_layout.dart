import 'package:flutter/material.dart';

enum DeviceType {
  mobile,
  tablet,
  desktop,
}

/// Standardized responsive breakpoints for BrainBox AI.
abstract final class AppBreakpoints {
  static const double mobileMax = 599.0;
  static const double tabletMin = 600.0;
  static const double tabletMax = 1023.0;
  static const double desktopMin = 1024.0;
  static const double maxContentWidth = 1200.0;
  static const double maxFormWidth = 480.0;
}

/// Helper extension on BuildContext for quick responsive checks and value pickers.
extension AppResponsiveContextX on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  DeviceType get deviceType {
    final width = screenWidth;
    if (width >= AppBreakpoints.desktopMin) {
      return DeviceType.desktop;
    } else if (width >= AppBreakpoints.tabletMin) {
      return DeviceType.tablet;
    } else {
      return DeviceType.mobile;
    }
  }

  bool get isMobile => deviceType == DeviceType.mobile;
  bool get isTablet => deviceType == DeviceType.tablet;
  bool get isDesktop => deviceType == DeviceType.desktop;

  T responsiveValue<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    switch (deviceType) {
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.mobile:
        return mobile;
    }
  }
}

/// A responsive widget switcher that renders appropriate layouts based on device screen width.
class AppResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const AppResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width >= AppBreakpoints.desktopMin && desktop != null) {
          return desktop!;
        }
        if (width >= AppBreakpoints.tabletMin && tablet != null) {
          return tablet!;
        }
        return mobile;
      },
    );
  }
}

/// Enforces maximum width constraints for centered web/desktop content presentation.
class AppCenteredContent extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const AppCenteredContent({
    super.key,
    required this.child,
    this.maxWidth = AppBreakpoints.maxContentWidth,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}
