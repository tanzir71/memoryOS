import 'package:flutter_test/flutter_test.dart';
import 'package:memoryos/main.dart';
import 'package:memoryos/services/capture_service.dart';

void main() {
  testWidgets('MemoryOS Shell boots and displays secure enclave title', (WidgetTester tester) async {
    // Disable clipboard scanning timer for the test to avoid pending timers
    CaptureService.instance.setSourceToggle('reading', false);

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MemoryOSApp());

    // Allow database and assets to initialize and transition frames
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify that the title 'Memory OS' is displayed
    expect(find.text('Memory OS'), findsOneWidget);

    // Verify that the timeline navigation item is displayed
    expect(find.text('Timeline'), findsOneWidget);
    expect(find.text('Sources'), findsOneWidget);
    expect(find.text('Threads'), findsOneWidget);
  });
}
