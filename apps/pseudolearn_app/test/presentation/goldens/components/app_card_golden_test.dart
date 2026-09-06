import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/components/card/app_card.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

Widget _sampleColumn() {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppCard(onTap: () {}, child: const Text('Tappable card')),
        const SizedBox(height: 16),
        const AppCard(child: Text('Static card')),
        const SizedBox(height: 16),
        AppCard(isNested: true, onTap: () {}, child: const Text('Nested card')),
      ],
    ),
  );
}

Future<void> _pump(WidgetTester tester, Size size, ThemeData theme) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      home: Scaffold(body: DesignCanvas(child: _sampleColumn())),
    ),
  );
}

void main() {
  group('AppCard goldens (RFC 003 §1)', () {
    testWidgets('resting state at compact width · light', (tester) async {
      await _pump(tester, const Size(360, 420), AppTheme.light());
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('app_card_compact_light.png'));
    });

    testWidgets('resting state at compact width · dark', (tester) async {
      await _pump(tester, const Size(360, 420), AppTheme.dark());
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('app_card_compact_dark.png'));
    });

    testWidgets('same content at expanded width · light', (tester) async {
      await _pump(tester, const Size(960, 420), AppTheme.light());
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('app_card_expanded_light.png'));
    });
  });
}
