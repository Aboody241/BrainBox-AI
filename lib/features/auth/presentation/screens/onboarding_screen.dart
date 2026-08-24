import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/presentation/responsive/responsive.dart';
import '../../../../core/presentation/theme/app_colors.dart';
import '../../../../core/presentation/theme/app_radius.dart';
import '../../../../core/presentation/theme/app_spacing.dart';
import '../../../../core/presentation/theme/app_typography.dart';

class OnboardingItem {
  final String imagePath;
  final String title;
  final String subtitle;

  const OnboardingItem({
    required this.imagePath,
    required this.title,
    required this.subtitle,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  static const List<OnboardingItem> _items = [
    OnboardingItem(
      imagePath: 'assets/onboard/onboard1.png',
      title: 'Unlock the Power\nOf Future AI',
      subtitle:
          'Chat with the smartest AI Future\nExperience power of AI with us',
    ),
    OnboardingItem(
      imagePath: 'assets/onboard/onboard2.png',
      title: 'Chat & Generate\nWith AI Assistance',
      subtitle:
          'Effortlessly solve complex problems\nand boost your daily workflow',
    ),
    OnboardingItem(
      imagePath: 'assets/onboard/onboard3.png',
      title: 'Your Personal\nSmart AI Companion',
      subtitle:
          'Always ready to assist you anywhere,\nanytime with extreme speed',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentIndex < _items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _previousPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _finishOnboarding() {
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AppCenteredContent(
          maxWidth: AppBreakpoints.maxFormWidth,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              // Top Action: Skip
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: AppSpacing.xs,
                    right: AppSpacing.lg,
                  ),
                  child: TextButton(
                    onPressed: _finishOnboarding,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                    ),
                    child: Text(
                      'Skip',
                      style: AppTypography.titleSmall.copyWith(
                        color: const Color(0xFFC2C3CB),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentIndex = index);
                  },
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return Column(
                      children: [
                        // Full width Hero Image with rounded corners and shadow
                        Expanded(
                          flex: 6,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x30000000),
                                    blurRadius: 28,
                                    offset: Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(32),
                                child: Image.asset(
                                  item.imagePath,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        // Dots indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _items.length,
                            (dotIndex) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              width: _currentIndex == dotIndex ? 10 : 8,
                              height: _currentIndex == dotIndex ? 10 : 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentIndex == dotIndex
                                    ? AppColors.primary
                                    : const Color(0xFFC2C3CB),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        // Title
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                          ),
                          child: Text(
                            item.title,
                            textAlign: TextAlign.center,
                            style: AppTypography.displayMedium.copyWith(
                              fontSize: 24,
                              height: 1.25,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        // Subtitle
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                          ),
                          child: Text(
                            item.subtitle,
                            textAlign: TextAlign.center,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                    );
                  },
                ),
              ),
              // Floating navigation pill control
              Padding(
                padding: const EdgeInsets.only(
                  bottom: AppSpacing.xl,
                  top: AppSpacing.xs,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadius.roundedFull,
                    border: Border.all(
                      color: AppColors.dividers.withValues(alpha: 0.4),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0E000000),
                        blurRadius: 20,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: _currentIndex > 0 ? _previousPage : null,
                        icon: Icon(
                          Icons.arrow_back,
                          color: _currentIndex > 0
                              ? AppColors.textPrimary
                              : AppColors.textfieldIcons.withValues(alpha: 0.4),
                          size: 20,
                        ),
                      ),
                      Container(
                        height: 20,
                        width: 1,
                        color: AppColors.dividers.withValues(alpha: 0.6),
                      ),
                      IconButton(
                        onPressed: _nextPage,
                        icon: const Icon(
                          Icons.arrow_forward,
                          color: AppColors.textPrimary,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
