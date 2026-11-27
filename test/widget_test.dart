import 'package:flutter_test/flutter_test.dart';
import 'package:memoryos/main.dart';

void main() {
  testWidgets('MemoryOS shell boots with Timeline and Sources tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MemoryOSApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('MemoryOS'), findsOneWidget);
    expect(find.text('Timeline'), findsOneWidget);
    expect(find.text('Sources'), findsOneWidget);
  });
}
