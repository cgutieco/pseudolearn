import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/components/list/app_list_item.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

Widget _sampleColumn() {
  return const Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      AppListItem(icon: Icons.person, label: 'Profile', trailing: AppListItemTrailingKind.chevron),
      AppListItem(
        icon: Icons.language,
        label: 'Language',
        trailing: AppListItemTrailingKind.value,
        trailingValueText: 'English',
      ),
      AppListItem(
        label: 'Spanish',
        trailing: AppListItemTrailingKind.check,
        selected: true,
      ),
      AppListItem(label: 'No trailing'),
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
      home: Scaffold(body: DesignCanvas(child: _sampleColumn())),
    ),
  );
}

void main() {
  group('AppListItem goldens (RFC 003 §3)', () {
    testWidgets('trailing kinds at compact width · light', (tester) async {
      await _pump(tester, const Size(360, 260), AppTheme.light());
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('app_list_item_compact_light.png'));
    });

    testWidgets('trailing kinds at compact width · dark', (tester) async {
      await _pump(tester, const Size(360, 260), AppTheme.dark());
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('app_list_item_compact_dark.png'));
    });

    testWidgets('same content at expanded width · light', (tester) async {
      await _pump(tester, const Size(960, 260), AppTheme.light());
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('app_list_item_expanded_light.png'));
    });
  });
}
