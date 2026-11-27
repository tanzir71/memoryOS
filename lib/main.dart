import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'app/providers.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'capture/background_worker.dart';
import 'data/database.dart';
import 'data/legacy_migration.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = await MemoryDatabase.openDefault();
  await _runLegacyMigrationIfPresent(db);
  await initializeBackgroundWorker();

  runApp(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const MemoryOSApp(),
    ),
  );
}

Future<void> _runLegacyMigrationIfPresent(MemoryDatabase db) async {
  try {
    final docsDir = await getApplicationDocumentsDirectory();
    final legacyCandidates = <File>[
      File(p.join(docsDir.path, 'memoryos.db')),
      if (Platform.isAndroid)
        File(p.join(docsDir.parent.path, 'databases', 'memoryos.db')),
    ];
    for (final file in legacyCandidates) {
      if (await file.exists()) {
        await migrateLegacyDatabase(legacyFile: file, targetDb: db);
      }
    }
  } catch (_) {
    // Non-fatal if legacy directory is inaccessible.
  }
}

class MemoryOSApp extends StatelessWidget {
  const MemoryOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MemoryOS',
      debugShowCheckedModeBanner: false,
      theme: buildMemoryTheme(),
      routerConfig: buildMemoryRouter(),
    );
  }
}
