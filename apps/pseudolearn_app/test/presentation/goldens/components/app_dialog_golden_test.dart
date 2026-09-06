import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/components/button/app_button.dart';
import 'package:pseudolearn_app/presentation/components/dialog/app_dialog.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

Widget _sampleDialog() {
  return AppDialog(
    icon: Icons.delete_outline,
    title: 'Delete document?',
    body: 'This document will be permanently removed. This action cannot be undone.',
    actions: [
      AppButton(label: 'Cancel', variant: AppButtonVariant.tertiary, onPressed: () {}),
      AppButton(
        label: 'Delete',
        variant: AppButtonVariant.primary,
        destructive: true,
        onPressed: () {},
      ),
    ],
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
      home: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: DesignCanvas(child: Center(child: _sampleDialog())),
      ),
    ),
  );
}

void main() {
  group('AppDialog goldens (RFC 003 §4)', () {
    testWidgets('with icon and two actions at compact width · light', (tester) async {
      await _pump(tester, const Size(360, 460), AppTheme.light());
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('app_dialog_compact_light.png'));
    });

    testWidgets('with icon and two actions at compact width · dark', (tester) async {
      await _pump(tester, const Size(360, 460), AppTheme.dark());
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('app_dialog_compact_dark.png'));
    });

    testWidgets('same content at expanded width · light', (tester) async {
      await _pump(tester, const Size(960, 460), AppTheme.light());
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('app_dialog_expanded_light.png'));
    });
  });
}
