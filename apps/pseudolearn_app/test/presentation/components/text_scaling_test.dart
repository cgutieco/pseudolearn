import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/components/button/app_button.dart';
import 'package:pseudolearn_app/presentation/components/card/app_card.dart';
import 'package:pseudolearn_app/presentation/components/field/app_text_field.dart';
import 'package:pseudolearn_app/presentation/components/list/app_list_item.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/typography.dart';

Future<void> _pumpAtSystemScale(WidgetTester tester, Widget child, double scale) async {
  tester.view.physicalSize = const Size(360, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(size: const Size(360, 900), textScaler: TextScaler.linear(scale)),
      child: MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: DesignCanvas(child: child)),
      ),
    ),
  );
}

void main() {
  group('Text scaling contract up to text.scale.max (RFC 003 §6.4)', () {
    testWidgets('AppButton does not overflow at the maximum system text scale', (tester) async {
      await _pumpAtSystemScale(
        tester,
        AppButton(label: 'Continue', variant: AppButtonVariant.primary, onPressed: () {}),
        TypographyTokens.textScaleMax,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('AppTextField does not overflow at the maximum system text scale', (tester) async {
      await _pumpAtSystemScale(
        tester,
        const AppTextField(label: 'Name', helperText: 'Your full legal name'),
        TypographyTokens.textScaleMax,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('AppListItem does not overflow at the maximum system text scale', (tester) async {
      await _pumpAtSystemScale(
        tester,
        const AppListItem(
          icon: Icons.language,
          label: 'Language',
          trailing: AppListItemTrailingKind.value,
          trailingValueText: 'English',
        ),
        TypographyTokens.textScaleMax,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('AppCard does not overflow at the maximum system text scale', (tester) async {
      await _pumpAtSystemScale(
        tester,
        const AppCard(child: Text('A card with some body text inside it')),
        TypographyTokens.textScaleMax,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('a scale far above the system maximum is still clamped and does not overflow', (tester) async {
      await _pumpAtSystemScale(
        tester,
        AppButton(label: 'Continue', variant: AppButtonVariant.primary, onPressed: () {}),
        5.0,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
