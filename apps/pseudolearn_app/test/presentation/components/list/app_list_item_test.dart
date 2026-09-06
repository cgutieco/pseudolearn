import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/components/list/app_list_item.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/list_item_metrics.dart';

import '../component_test_harness.dart';

void main() {
  group('AppListItem (RFC 003 §3)', () {
    testWidgets('renders its label', (tester) async {
      await pumpComponent(tester, const AppListItem(label: 'Spanish'));
      expect(find.text('Spanish'), findsOneWidget);
    });

    testWidgets('tapping invokes onTap', (tester) async {
      var tapped = false;
      await pumpComponent(tester, AppListItem(label: 'Item', onTap: () => tapped = true));
      await tester.tap(find.byType(AppListItem));
      expect(tapped, isTrue);
    });

    testWidgets('the chevron trailing kind shows a chevron icon', (tester) async {
      await pumpComponent(
        tester,
        const AppListItem(label: 'Contact', trailing: AppListItemTrailingKind.chevron),
      );
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('the check trailing kind shows a check icon, never a chevron', (tester) async {
      await pumpComponent(
        tester,
        const AppListItem(label: 'English', trailing: AppListItemTrailingKind.check, selected: true),
      );
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });

    testWidgets('the value trailing kind shows the given text', (tester) async {
      await pumpComponent(
        tester,
        const AppListItem(
          label: 'Language',
          trailing: AppListItemTrailingKind.value,
          trailingValueText: 'English',
        ),
      );
      expect(find.text('English'), findsOneWidget);
    });

    testWidgets('the none trailing kind shows neither icon nor value', (tester) async {
      await pumpComponent(tester, const AppListItem(label: 'Plain'));
      expect(find.byIcon(Icons.chevron_right), findsNothing);
      expect(find.byIcon(Icons.check), findsNothing);
    });

    test('a value trailing kind without trailingValueText fails its assertion', () {
      expect(
        () => AppListItem(label: 'Missing', trailing: AppListItemTrailingKind.value),
        throwsAssertionError,
      );
    });

    testWidgets('the trailing value sits flush against the right edge of the row', (tester) async {
      await pumpComponent(
        tester,
        const AppListItem(
          label: 'Language',
          trailing: AppListItemTrailingKind.value,
          trailingValueText: 'System language',
        ),
      );

      final row = tester.getRect(find.byType(AppListItem));
      final value = tester.getRect(find.text('System language'));

      expect(
        value.right,
        moreOrLessEquals(row.right - ListItemMetricsTokens.paddingHorizontal, epsilon: 0.5),
      );
    });

    testWidgets('a chevron leaves the label every pixel it does not need', (tester) async {
      await pumpComponent(
        tester,
        const AppListItem(label: 'Restart', trailing: AppListItemTrailingKind.chevron),
      );

      final row = tester.getRect(find.byType(AppListItem));
      final label = tester.getRect(find.text('Restart'));
      const takenByTrailing =
          ListItemMetricsTokens.gapLabelToTrailing + ListItemMetricsTokens.trailingChevronSize;

      expect(
        label.width,
        moreOrLessEquals(
          row.width - ListItemMetricsTokens.paddingHorizontal * 2 - takenByTrailing,
          epsilon: 0.5,
        ),
      );
    });

    testWidgets('with no trailing the label spans the whole row', (tester) async {
      await pumpComponent(tester, const AppListItem(label: 'Plain'));

      final row = tester.getRect(find.byType(AppListItem));
      final label = tester.getRect(find.text('Plain'));

      expect(
        label.width,
        moreOrLessEquals(row.width - ListItemMetricsTokens.paddingHorizontal * 2, epsilon: 0.5),
      );
    });

    testWidgets('a value longer than its maximum stops there instead of pushing the label out',
        (tester) async {
      await pumpComponent(
        tester,
        AppListItem(
          label: 'Language',
          trailing: AppListItemTrailingKind.value,
          trailingValueText: 'x' * 200,
        ),
      );

      final value = tester.getRect(find.text('x' * 200));

      expect(tester.takeException(), isNull);
      expect(value.width, moreOrLessEquals(ListItemMetricsTokens.trailingValueMaxWidth, epsilon: 0.5));
      expect(tester.getRect(find.text('Language')).width, greaterThan(0));
    });

    testWidgets('a long label truncates instead of overflowing the row', (tester) async {
      await pumpComponent(
        tester,
        AppListItem(label: 'a' * 200, trailing: AppListItemTrailingKind.chevron),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
