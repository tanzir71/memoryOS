import 'dart:async';

import 'package:flutter/material.dart';
import 'screens/shell_page.dart';
import 'theme/app_theme.dart';
import 'services/capture_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MemoryOSApp());
}

class MemoryOSApp extends StatefulWidget {
  const MemoryOSApp({super.key});

  @override
  State<MemoryOSApp> createState() => _MemoryOSAppState();
}

class _MemoryOSAppState extends State<MemoryOSApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_initializeCaptureService());
    });
  }

  Future<void> _initializeCaptureService() async {
    try {
      await CaptureService.instance.init();
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'memoryos startup',
          context: ErrorDescription('initializing CaptureService'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MemoryOS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const ShellPage(),
    );
  }
}
