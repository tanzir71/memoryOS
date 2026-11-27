import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memoryos/app/providers.dart';
import 'package:memoryos/data/database.dart';
import 'package:memoryos/main.dart';

void main() {
  testWidgets('MemoryOS shell boots with Today, Threads, People, Ahead tabs', (
    WidgetTester tester,
  ) async {
    final db = MemoryDatabase.inMemory();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MemoryOSApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Threads'), findsOneWidget);
    expect(find.text('People'), findsOneWidget);
    expect(find.text('Ahead'), findsOneWidget);
    expect(find.text('Capturing'), findsOneWidget);
    expect(find.text('Nothing worth keeping yet today'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
    await db.close();
  });
}
