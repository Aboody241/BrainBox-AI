import 'package:flutter/material.dart';

import '../../../../core/presentation/theme/app_typography.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BrainBox AI'),
      ),
      body: const Center(
        child: Text(
          'Recent Conversations',
          style: AppTypography.titleMedium,
        ),
      ),
    );
  }
}
