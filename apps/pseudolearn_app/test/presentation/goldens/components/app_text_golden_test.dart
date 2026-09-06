import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/components/typography/app_text.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

Widget _sampleColumn() {
  return const Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText('Display', variant: AppTextVariant.display),
        AppText('Heading 1', variant: AppTextVariant.heading1),
        AppText('Heading 2', variant: AppTextVariant.heading2),
        AppText('Body default', variant: AppTextVariant.bodyDefault),
        AppText('Label', variant: AppTextVariant.label),
        AppText('Caption', variant: AppTextVariant.caption),
        AppText('OVERLINE', variant: AppTextVariant.overline),
        AppText('let mut x = 1', variant: AppTextVariant.codeEditor),
        AppText('42', variant: AppTextVariant.codeCaption),
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
  group('AppText goldens (RFC 003 §6)', () {
    testWidgets('variants at compact width · light', (tester) async {
      await _pump(tester, const Size(360, 620), AppTheme.light());
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('app_text_compact_light.png'));
    });

    testWidgets('variants at compact width · dark', (tester) async {
      await _pump(tester, const Size(360, 620), AppTheme.dark());
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('app_text_compact_dark.png'));
    });

    testWidgets('same content across the three widths · light', (tester) async {
      await _pump(tester, const Size(960, 620), AppTheme.light());
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('app_text_expanded_light.png'));
    });
  });
}
