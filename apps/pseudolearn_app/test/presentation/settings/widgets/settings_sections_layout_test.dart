import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/settings/widgets/settings_sections_layout.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

const Key _primaryKey = Key('primary');
const Key _secondaryKey = Key('secondary');

Future<void> _pumpLayout(WidgetTester tester, {required double width}) async {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: const Scaffold(
        body: DesignCanvas(
          child: SettingsSectionsLayout(
            primary: SizedBox(key: _primaryKey, height: 100),
            secondary: SizedBox(key: _secondaryKey, height: 100),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('SettingsSectionsLayout', () {
    testWidgets('compact stacks the sections one under the other', (tester) async {
      await _pumpLayout(tester, width: 360);

      final primary = tester.getRect(find.byKey(_primaryKey));
      final secondary = tester.getRect(find.byKey(_secondaryKey));

      expect(secondary.top, greaterThanOrEqualTo(primary.bottom));
      expect(secondary.left, equals(primary.left));
    });

    testWidgets('medium still stacks: two columns there would be too narrow', (tester) async {
      await _pumpLayout(tester, width: 600);

      final primary = tester.getRect(find.byKey(_primaryKey));
      final secondary = tester.getRect(find.byKey(_secondaryKey));

      expect(secondary.top, greaterThanOrEqualTo(primary.bottom));
    });

    testWidgets('expanded puts the sections side by side', (tester) async {
      await _pumpLayout(tester, width: 1200);

      final primary = tester.getRect(find.byKey(_primaryKey));
      final secondary = tester.getRect(find.byKey(_secondaryKey));

      expect(secondary.top, equals(primary.top));
      expect(secondary.left, greaterThan(primary.right));
      expect(secondary.width, moreOrLessEquals(primary.width, epsilon: 0.5));
    });
  });
}
