import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/components/button/app_button.dart';
import 'package:pseudolearn_app/presentation/components/button/app_icon_button.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/button_metrics.dart';

import '../component_test_harness.dart';

void main() {
  group('AppButton (RFC 003 §5)', () {
    testWidgets('renders its label', (tester) async {
      await pumpComponent(
        tester,
        AppButton(label: 'Continue', variant: AppButtonVariant.primary, onPressed: () {}),
      );
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('tapping invokes onPressed', (tester) async {
      var tapped = false;
      await pumpComponent(
        tester,
        AppButton(label: 'Go', variant: AppButtonVariant.primary, onPressed: () => tapped = true),
      );
      await tester.tap(find.byType(AppButton));
      expect(tapped, isTrue);
    });

    testWidgets('a null onPressed disables the button', (tester) async {
      await pumpComponent(tester, const AppButton(label: 'Disabled', variant: AppButtonVariant.primary, onPressed: null));
      final button = tester.widget<TextButton>(find.byType(TextButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('meets the minimum width for a short label', (tester) async {
      await pumpComponent(tester, AppButton(label: 'Ok', variant: AppButtonVariant.tertiary, onPressed: () {}));
      final size = tester.getSize(find.byType(AppButton));
      expect(size.width, greaterThanOrEqualTo(ButtonMetricsTokens.buttonMinWidth));
    });

    testWidgets('each of the three variants renders without throwing', (tester) async {
      for (final variant in AppButtonVariant.values) {
        await pumpComponent(tester, AppButton(label: 'v', variant: variant, onPressed: () {}));
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('the destructive channel combines with any variant', (tester) async {
      await pumpComponent(
        tester,
        AppButton(label: 'Delete', variant: AppButtonVariant.primary, destructive: true, onPressed: () {}),
      );
      expect(find.text('Delete'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders with a leading icon', (tester) async {
      await pumpComponent(
        tester,
        AppButton(label: 'Save', variant: AppButtonVariant.secondary, icon: Icons.save, onPressed: () {}),
      );
      expect(find.byIcon(Icons.save), findsOneWidget);
    });
  });

  group('AppIconButton (RFC 003 §5.2 icon-only)', () {
    testWidgets('renders the icon and reaches the minimum square size', (tester) async {
      await pumpComponent(
        tester,
        AppIconButton(
          icon: Icons.close,
          semanticLabel: 'Close',
          variant: AppButtonVariant.tertiary,
          onPressed: () {},
        ),
      );
      final size = tester.getSize(find.byType(AppIconButton));
      expect(size.width, greaterThanOrEqualTo(ButtonMetricsTokens.buttonIconOnlyMinSize));
      expect(size.height, greaterThanOrEqualTo(ButtonMetricsTokens.buttonIconOnlyMinSize));
    });

    testWidgets('tapping invokes onPressed', (tester) async {
      var tapped = false;
      await pumpComponent(
        tester,
        AppIconButton(
          icon: Icons.close,
          semanticLabel: 'Close',
          variant: AppButtonVariant.tertiary,
          onPressed: () => tapped = true,
        ),
      );
      await tester.tap(find.byType(AppIconButton));
      expect(tapped, isTrue);
    });

    testWidgets('a null onPressed disables the icon button', (tester) async {
      await pumpComponent(
        tester,
        const AppIconButton(
          icon: Icons.close,
          semanticLabel: 'Close',
          variant: AppButtonVariant.tertiary,
          onPressed: null,
        ),
      );
      final button = tester.widget<IconButton>(find.byType(IconButton));
      expect(button.onPressed, isNull);
    });
  });
}
