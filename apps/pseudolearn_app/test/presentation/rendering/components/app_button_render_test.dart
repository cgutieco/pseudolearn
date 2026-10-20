import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/components/button/app_button.dart';
import 'package:pseudolearn_app/presentation/components/button/app_icon_button.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

Widget _sampleColumn() {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppButton(
          label: 'Primary',
          variant: AppButtonVariant.primary,
          onPressed: () {},
        ),
        const SizedBox(height: 8),
        AppButton(
          label: 'Secondary',
          variant: AppButtonVariant.secondary,
          onPressed: () {},
        ),
        const SizedBox(height: 8),
        AppButton(
          label: 'Tertiary',
          variant: AppButtonVariant.tertiary,
          onPressed: () {},
        ),
        const SizedBox(height: 8),
        const AppButton(
          label: 'Disabled',
          variant: AppButtonVariant.primary,
          onPressed: null,
        ),
        const SizedBox(height: 8),
        AppButton(
          label: 'Delete',
          variant: AppButtonVariant.primary,
          destructive: true,
          icon: Icons.delete,
          onPressed: () {},
        ),
        const SizedBox(height: 8),
        AppIconButton(
          icon: Icons.close,
          semanticLabel: 'Close',
          variant: AppButtonVariant.tertiary,
          onPressed: () {},
        ),
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
  group('AppButton / AppIconButton render checks (RFC 003 §5)', () {
    testWidgets('variants and states at compact width · light', (tester) async {
      await _pump(tester, const Size(360, 460), AppTheme.light());
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('variants and states at compact width · dark', (tester) async {
      await _pump(tester, const Size(360, 460), AppTheme.dark());
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('same content at expanded width · light', (tester) async {
      await _pump(tester, const Size(960, 460), AppTheme.light());
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
