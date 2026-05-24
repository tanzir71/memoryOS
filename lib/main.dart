import 'package:flutter/material.dart';
import 'screens/shell_page.dart';
import 'theme/app_theme.dart';
import 'services/capture_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CaptureService.instance.init();
  runApp(const MemoryOSApp());
}

class MemoryOSApp extends StatelessWidget {
  const MemoryOSApp({super.key});

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
