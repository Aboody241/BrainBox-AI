import 'dart:ui';

import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/di/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Catch synchronous and framework-level errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  // Catch asynchronous errors in the root isolate
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    return true;
  };

  // Initialize composition root dependencies
  await ServiceLocator.init();

  runApp(const BrainBoxApp());
}
