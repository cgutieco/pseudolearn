import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/components/typography/app_text.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/typography.dart';

import '../component_test_harness.dart';

void main() {
  group('AppText (RFC 003 §6)', () {
    testWidgets('renders the given text', (tester) async {
      await pumpComponent(tester, const AppText('hello', variant: AppTextVariant.bodyDefault));
      expect(find.text('hello'), findsOneWidget);
    });

    testWidgets('renders an empty string without throwing', (tester) async {
      await pumpComponent(tester, const AppText('', variant: AppTextVariant.bodyDefault));
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders a single-character string', (tester) async {
      await pumpComponent(tester, const AppText('a', variant: AppTextVariant.label));
      expect(find.text('a'), findsOneWidget);
    });

    testWidgets('bodyDefault uses the compact scale at a compact width', (tester) async {
      await pumpComponent(
        tester,
        const AppText('sample', variant: AppTextVariant.bodyDefault),
        size: const Size(360, 800),
      );
      final text = tester.widget<Text>(find.text('sample'));
      expect(text.style!.fontSize, const AppTypography.compact().bodyDefault.fontSize);
    });

    testWidgets('bodyDefault uses the expanded scale at an expanded width', (tester) async {
      await pumpComponent(
        tester,
        const AppText('sample', variant: AppTextVariant.bodyDefault),
        size: const Size(960, 900),
      );
      final text = tester.widget<Text>(find.text('sample'));
      expect(text.style!.fontSize, const AppTypography.expanded().bodyDefault.fontSize);
    });

    testWidgets('a ui-family variant inherits the ambient (clamped) text scaler', (tester) async {
      await pumpComponent(tester, const AppText('scales', variant: AppTextVariant.bodyDefault));
      final text = tester.widget<Text>(find.text('scales'));
      expect(text.textScaler, isNull);
    });

    testWidgets('codeEditor opts out of the system text scaler', (tester) async {
      await pumpComponent(tester, const AppText('code', variant: AppTextVariant.codeEditor));
      final text = tester.widget<Text>(find.text('code'));
      expect(text.textScaler, TextScaler.noScaling);
    });

    testWidgets('codeCaption opts out of the system text scaler and uses tabular figures', (tester) async {
      await pumpComponent(tester, const AppText('42', variant: AppTextVariant.codeCaption));
      final text = tester.widget<Text>(find.text('42'));
      expect(text.textScaler, TextScaler.noScaling);
      expect(text.style!.fontFeatures, contains(const FontFeature.tabularFigures()));
    });

    testWidgets('overline with four words fails its assertion', (tester) async {
      await pumpComponent(
        tester,
        const AppText('one two three four', variant: AppTextVariant.overline),
      );
      expect(tester.takeException(), isAssertionError);
    });

    testWidgets('overline with exactly three words does not assert', (tester) async {
      await pumpComponent(tester, const AppText('one two three', variant: AppTextVariant.overline));
      expect(tester.takeException(), isNull);
    });

    testWidgets('an explicit color overrides the default text color', (tester) async {
      await pumpComponent(
        tester,
        const AppText('tinted', variant: AppTextVariant.bodyDefault, color: Color(0xFFFF0000)),
      );
      final text = tester.widget<Text>(find.text('tinted'));
      expect(text.style!.color, const Color(0xFFFF0000));
    });
  });
}
