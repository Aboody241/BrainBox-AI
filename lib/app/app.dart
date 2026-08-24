import 'package:flutter/material.dart';

import 'theme/app_theme.dart';

class BrainBoxApp extends StatelessWidget {
  const BrainBoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BrainBox AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const Scaffold(
        body: Center(
          child: Text('BrainBox AI'),
        ),
      ),
    );
  }
}
