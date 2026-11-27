import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memoryos/app/theme.dart';
import 'package:memoryos/widgets/app_button.dart';
import 'package:memoryos/widgets/app_switch.dart';
import 'package:memoryos/widgets/capture_pill.dart';
import 'package:memoryos/widgets/decision_control.dart';
import 'package:memoryos/widgets/glyph.dart';
import 'package:memoryos/widgets/nav_bar.dart';
import 'package:memoryos/widgets/rail_entry.dart';
import 'package:memoryos/widgets/section_header.dart';
import 'package:memoryos/widgets/tags.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: buildMemoryTheme(),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  testWidgets('Glyph renders all 11 kinds', (tester) async {
    await tester.pumpWidget(
      _wrap(
        Wrap(
          children: GlyphKind.values.map((k) => Glyph(kind: k)).toList(),
        ),
      ),
    );
    expect(find.byType(Glyph), findsNWidgets(GlyphKind.values.length));
  });

  testWidgets('IntentTag renders all intent labels', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IntentTag(kind: IntentKind.asksYou),
            IntentTag(kind: IntentKind.youSaid),
            IntentTag(kind: IntentKind.plan),
            IntentTag(kind: IntentKind.confirms),
            IntentTag(kind: IntentKind.fyi),
          ],
        ),
      ),
    );
    expect(find.text('Asks you'), findsOneWidget);
    expect(find.text('You said'), findsOneWidget);
    expect(find.text('Plan'), findsOneWidget);
    expect(find.text('Confirms'), findsOneWidget);
    expect(find.text('FYI'), findsOneWidget);
  });

  testWidgets('CertaintyTag renders all certainty labels', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CertaintyTag(kind: CertaintyKind.stated),
            CertaintyTag(kind: CertaintyKind.learned),
            CertaintyTag(kind: CertaintyKind.guess),
          ],
        ),
      ),
    );
    expect(find.text('Stated'), findsOneWidget);
    expect(find.text('Learned'), findsOneWidget);
    expect(find.text('Guess'), findsOneWidget);
  });

  testWidgets('DecisionControl supports none selected and invokes callback', (
    tester,
  ) async {
    DecisionChoice? picked;
    await tester.pumpWidget(
      _wrap(
        DecisionControl(
          selected: null,
          onChanged: (value) => picked = value,
        ),
      ),
    );
    expect(find.text('Show'), findsOneWidget);
    expect(find.text('Track quietly'), findsOneWidget);
    expect(find.text('Drop'), findsOneWidget);

    await tester.tap(find.text('Track quietly'));
    expect(picked, DecisionChoice.quiet);
    await tester.tap(find.text('Drop'));
    expect(picked, DecisionChoice.drop);
  });

  testWidgets('AppButton renders primary, quiet, and text variants', (
    tester,
  ) async {
    var tapped = 0;
    await tester.pumpWidget(
      _wrap(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton(label: 'Primary', onPressed: () => tapped++),
            AppButton(
              label: 'Quiet',
              variant: AppButtonVariant.quiet,
              onPressed: () => tapped++,
            ),
            AppButton(
              label: 'Text',
              variant: AppButtonVariant.text,
              onPressed: () => tapped++,
            ),
          ],
        ),
      ),
    );
    await tester.tap(find.text('Primary'));
    await tester.tap(find.text('Quiet'));
    await tester.tap(find.text('Text'));
    expect(tapped, 3);
  });

  testWidgets('CapturePill renders capturing and paused states', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CapturePill(isCapturing: true),
            CapturePill(isCapturing: false, pausedUntilLabel: '4:00 pm'),
          ],
        ),
      ),
    );
    expect(find.text('Capturing'), findsOneWidget);
    expect(find.text('Paused until 4:00 pm'), findsOneWidget);
  });

  testWidgets('AppSwitch toggles value on tap', (tester) async {
    var value = false;
    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) {
            return AppSwitch(
              value: value,
              onChanged: (next) => setState(() => value = next),
            );
          },
        ),
      ),
    );
    await tester.tap(find.byType(AppSwitch));
    await tester.pumpAndSettle();
    expect(value, isTrue);
  });

  testWidgets('MemoryNavBar shows Today, Threads, People, Ahead and switches', (
    tester,
  ) async {
    var selected = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildMemoryTheme(),
        home: Scaffold(
          bottomNavigationBar: MemoryNavBar(
            currentIndex: selected,
            onTap: (i) => selected = i,
          ),
        ),
      ),
    );
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Threads'), findsOneWidget);
    expect(find.text('People'), findsOneWidget);
    expect(find.text('Ahead'), findsOneWidget);
    await tester.tap(find.text('Ahead'));
    expect(selected, 3);
  });

  testWidgets('RailEntry renders glyph, time, title and subtitle', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const RailEntry(
          glyphKind: GlyphKind.meeting,
          timeLabel: '3:00 pm',
          title: 'Design sync',
          subtitle: 'Google Meet',
          showRail: true,
        ),
      ),
    );
    expect(find.text('3:00 pm'), findsOneWidget);
    expect(find.text('Design sync'), findsOneWidget);
    expect(find.text('Google Meet'), findsOneWidget);
  });

  testWidgets('SectionHeader shows title and trailing text', (tester) async {
    await tester.pumpWidget(
      _wrap(const SectionHeader(title: 'Needs you', trailing: '2 open')),
    );
    expect(find.text('Needs you'), findsOneWidget);
    expect(find.text('2 open'), findsOneWidget);
  });
}
