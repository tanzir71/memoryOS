import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memoryos/main.dart';
import 'package:memoryos/models/memory_node.dart';
import 'package:memoryos/screens/shell_page.dart';
import 'package:memoryos/screens/summary_page.dart';
import 'package:memoryos/screens/sources_page.dart';
import 'package:memoryos/screens/timeline_page.dart';
import 'package:memoryos/services/app_category_registry.dart';
import 'package:memoryos/services/capture_service.dart';
import 'package:memoryos/services/database_service.dart';
import 'package:memoryos/widgets/memory_os_logo.dart';

void main() {
  testWidgets('MemoryOS Shell renders before native persistence responds', (
    WidgetTester tester,
  ) async {
    const persistentChannel = MethodChannel('com.memoryos.memoryos/persistent');
    final nativePersistenceCompleter = Completer<void>();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          persistentChannel,
          (_) => nativePersistenceCompleter.future,
        );
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(persistentChannel, null);
      if (!nativePersistenceCompleter.isCompleted) {
        nativePersistenceCompleter.complete();
      }
    });

    await tester.pumpWidget(const MemoryOSApp());
    await tester.pump();

    expect(find.text('MemoryOS'), findsOneWidget);
    expect(find.text('Timeline'), findsOneWidget);

    nativePersistenceCompleter.complete();
    await tester.pump();
  });

  testWidgets('MemoryOS Shell boots and displays secure enclave title', (
    WidgetTester tester,
  ) async {
    // Disable clipboard scanning timer for the test to avoid pending timers
    CaptureService.instance.setSourceToggle('reading', false);

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MemoryOSApp());

    // Allow database and assets to initialize and transition frames
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify that the title is consistently formatted as 'MemoryOS'
    expect(find.text('MemoryOS'), findsOneWidget);
    expect(find.text('Memory OS'), findsNothing);

    // Verify that the timeline navigation item is displayed
    expect(find.text('Timeline'), findsOneWidget);
    expect(find.text('Sources'), findsOneWidget);
    expect(find.text('Threads'), findsOneWidget);
  });

  testWidgets('shell lazily builds and caches tab pages', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ShellPage()));
    await tester.pump();

    expect(find.text('Timeline'), findsOneWidget);
    expect(find.text('Personal Insights', skipOffstage: false), findsNothing);
    expect(find.text('Enclave Integration', skipOffstage: false), findsNothing);
    expect(find.text('ASK LOCAL CONTEXT', skipOffstage: false), findsNothing);

    await tester.tap(find.text('Insights'));
    await tester.pump();
    expect(find.text('Personal Insights'), findsOneWidget);

    await tester.tap(find.text('Sources'));
    await tester.pump();
    expect(find.text('Enclave Integration'), findsOneWidget);

    await tester.tap(find.text('Threads'));
    await tester.pump();
    expect(find.text('ASK LOCAL CONTEXT'), findsOneWidget);

    await tester.tap(find.text('Timeline'));
    await tester.pump();
    expect(find.text('Personal Insights', skipOffstage: false), findsOneWidget);
    expect(
      find.text('Enclave Integration', skipOffstage: false),
      findsOneWidget,
    );
    expect(find.text('ASK LOCAL CONTEXT', skipOffstage: false), findsOneWidget);
  });

  testWidgets('disabled clipboard source alone does not show setup banner', (
    WidgetTester tester,
  ) async {
    final previousSourceToggles = Map<String, bool>.from(
      CaptureService.instance.sourceToggles,
    );
    CaptureService.instance.sourceToggles.updateAll((_, _) => true);
    CaptureService.instance.sourceToggles['reading'] = false;
    addTearDown(() {
      CaptureService.instance.sourceToggles
        ..clear()
        ..addAll(previousSourceToggles);
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TimelinePage(
            initialNodes: [
              MemoryNode(
                timestamp: DateTime.now(),
                title: 'Check-in',
                content: 'Manual context check-in.',
                source: 'document',
                metadata: const {'isManual': true},
                trail: 'none',
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Permissions Onboarding Setup'), findsNothing);
  });

  testWidgets('MemoryOSLogo defaults to solid black', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: MemoryOSLogo())),
      ),
    );

    final customPaint = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byType(MemoryOSLogo),
        matching: find.byType(CustomPaint),
      ),
    );
    final dynamic painter = customPaint.painter;
    expect(painter.color, Colors.black);
  });

  testWidgets('timeline header uses one overflow menu on narrow screens', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final previousSourceToggles = Map<String, bool>.from(
      CaptureService.instance.sourceToggles,
    );
    CaptureService.instance.sourceToggles.updateAll((_, _) => true);
    addTearDown(() {
      CaptureService.instance.sourceToggles
        ..clear()
        ..addAll(previousSourceToggles);
    });

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: TimelinePage())),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Deleted'), findsNothing);
    expect(find.byTooltip('Timeline actions'), findsOneWidget);

    await tester.tap(find.byTooltip('Timeline actions'));
    await tester.pumpAndSettle();

    expect(find.text('Recover deleted'), findsOneWidget);
    expect(find.text('Delete day memories'), findsOneWidget);
  });

  testWidgets(
    'sources registry group pill opens editable default and custom aliases',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await DatabaseService.instance.saveAppCategoryRegistry(
        const AppCategoryRegistry(),
      );
      addTearDown(() async {
        await DatabaseService.instance.saveAppCategoryRegistry(
          const AppCategoryRegistry(),
        );
      });

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SourcesPage(isActive: false))),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(
        find.byTooltip('Edit Food registry'),
        260,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.byTooltip('Edit Food registry'), findsOneWidget);

      await tester.tap(find.byTooltip('Edit Food registry'));
      await tester.pumpAndSettle();

      expect(find.text('Food Registry'), findsOneWidget);
      expect(find.text('Talabat'), findsOneWidget);
      expect(find.byTooltip('Remove Talabat'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'com.local.tiffinbox');
      await tester.tap(find.byTooltip('Add alias'));
      await tester.pumpAndSettle();

      expect(find.text('com.local.tiffinbox'), findsOneWidget);
      expect(find.byTooltip('Remove com.local.tiffinbox'), findsOneWidget);
    },
  );

  testWidgets('summary export asks for period before save location', (
    WidgetTester tester,
  ) async {
    final nodes = [
      MemoryNode(
        timestamp: DateTime.now(),
        title: 'Lameh proposal review',
        content: 'Lameh proposal review with client proposal notes.',
        source: 'notification',
        metadata: const {'packageName': 'com.google.android.gm'},
        trail: 'work',
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: SummaryPage(isActive: false, initialNodes: nodes)),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.text('Export as Markdown'),
      320,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Export as Markdown'));
    await tester.pumpAndSettle();

    expect(find.text('Select export period'), findsOneWidget);
    expect(find.text('This week'), findsOneWidget);
    expect(find.text('This month'), findsOneWidget);
    expect(find.text('Last month'), findsOneWidget);
    expect(find.text('Last 3 months'), findsOneWidget);
    expect(find.text('Last 6 months'), findsOneWidget);
    expect(find.text('Last year'), findsOneWidget);
    expect(find.text('All time'), findsOneWidget);
  });

  testWidgets('timeline health controls are compact on narrow screens', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final nodes = [
      MemoryNode(
        timestamp: DateTime.now(),
        title: 'Foodpanda',
        content: 'Lunch arrived.',
        source: 'notification',
        metadata: const {'packageName': 'com.global.foodpanda.android'},
        trail: 'health',
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TimelinePage(isActive: false, initialNodes: nodes),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Health Report'), findsNothing);
    expect(find.byTooltip('1 health event'), findsOneWidget);
    expect(find.byTooltip('Health report'), findsOneWidget);
  });

  testWidgets('bottom navigation clears Android system navigation inset', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const bottomInset = 48.0;
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) {
          final mediaQuery = MediaQuery.of(context);
          return MediaQuery(
            data: mediaQuery.copyWith(
              padding: const EdgeInsets.only(bottom: bottomInset),
              viewPadding: const EdgeInsets.only(bottom: bottomInset),
            ),
            child: child!,
          );
        },
        home: const ShellPage(),
      ),
    );
    await tester.pump();

    final navBarRect = tester.getRect(
      find.byKey(const Key('shell-bottom-navigation-bar')),
    );
    final timelineLabelRect = tester.getRect(find.text('Timeline'));

    expect(navBarRect.height, greaterThanOrEqualTo(64 + bottomInset));
    expect(844 - timelineLabelRect.bottom, greaterThan(bottomInset));
  });
}
