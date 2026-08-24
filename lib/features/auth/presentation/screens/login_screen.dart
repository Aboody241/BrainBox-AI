import 'package:flutter/material.dart';

import '../../../../core/presentation/theme/app_typography.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Login',
          style: AppTypography.titleLarge,
        ),
      ),
    );
  }
}
