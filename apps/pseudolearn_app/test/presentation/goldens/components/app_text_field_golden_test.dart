import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/components/field/app_text_field.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

Widget _sampleColumn() {
  return const Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppTextField(label: 'Name', placeholder: 'Ana'),
        SizedBox(height: 16),
        AppTextField(label: 'Search', placeholder: 'Search…', helperText: 'Type to filter'),
        SizedBox(height: 16),
        AppTextField(label: 'Email', errorText: 'This field is required'),
        SizedBox(height: 16),
        AppTextField(label: 'Disabled', enabled: false, placeholder: 'Not editable'),
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
  group('AppTextField goldens (RFC 003 §2)', () {
    testWidgets('states at compact width · light', (tester) async {
      await _pump(tester, const Size(360, 460), AppTheme.light());
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('app_text_field_compact_light.png'));
    });

    testWidgets('states at compact width · dark', (tester) async {
      await _pump(tester, const Size(360, 460), AppTheme.dark());
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('app_text_field_compact_dark.png'));
    });

    testWidgets('same content at expanded width · light', (tester) async {
      await _pump(tester, const Size(960, 460), AppTheme.light());
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('app_text_field_expanded_light.png'));
    });
  });
}
