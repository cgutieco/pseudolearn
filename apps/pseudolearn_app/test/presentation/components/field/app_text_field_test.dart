import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/components/field/app_text_field.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/color_semantic.dart';

import '../component_test_harness.dart';

void main() {
  group('AppTextField (RFC 003 §2)', () {
    testWidgets('shows the label, placeholder and helper text', (tester) async {
      await pumpComponent(
        tester,
        const AppTextField(label: 'Name', placeholder: 'Ana', helperText: 'Your full name'),
      );
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Your full name'), findsOneWidget);
    });

    testWidgets('typing invokes onChanged', (tester) async {
      String? seen;
      await pumpComponent(
        tester,
        AppTextField(label: 'Name', onChanged: (value) => seen = value),
      );
      await tester.enterText(find.byType(TextField), 'hello');
      expect(seen, 'hello');
    });

    testWidgets('an empty field shows the placeholder and takes no exceptions', (tester) async {
      await pumpComponent(tester, const AppTextField(placeholder: 'Search'));
      expect(find.text('Search'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('error text replaces the helper text and the fill color stays default', (tester) async {
      await pumpComponent(
        tester,
        const AppTextField(label: 'Name', helperText: 'ignored while in error', errorText: 'Required'),
      );
      expect(find.text('Required'), findsOneWidget);
      expect(find.text('ignored while in error'), findsNothing);

      final field = tester.widget<TextField>(find.byType(TextField));
      const lightColors = AppSemanticColors.light();
      expect(field.decoration!.fillColor, lightColors.surfaces.defaultSurface);
    });

    testWidgets('the clear button invokes onClear', (tester) async {
      var cleared = false;
      await pumpComponent(
        tester,
        AppTextField(label: 'Search', onClear: () => cleared = true),
      );
      await tester.tap(find.byIcon(Icons.clear));
      expect(cleared, isTrue);
    });

    testWidgets('with no onClear, no clear button is shown', (tester) async {
      await pumpComponent(tester, const AppTextField(label: 'Search'));
      expect(find.byIcon(Icons.clear), findsNothing);
    });

    testWidgets('a disabled field does not accept text', (tester) async {
      await pumpComponent(tester, const AppTextField(label: 'Name', enabled: false));
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.enabled, isFalse);
    });

    testWidgets('compact size applies compact height and isDense decoration', (tester) async {
      await pumpComponent(
        tester,
        const AppTextField(label: 'Name', size: AppTextFieldSize.compact),
      );
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.decoration!.isDense, isTrue);

      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(of: find.byType(Semantics), matching: find.byType(SizedBox)).first,
      );
      expect(sizedBox.height, 36.0);
    });

    testWidgets('submitting invokes onSubmitted callback', (tester) async {
      String? submitted;
      await pumpComponent(
        tester,
        AppTextField(label: 'Name', onSubmitted: (val) => submitted = val),
      );
      await tester.enterText(find.byType(TextField), 'Test');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      expect(submitted, 'Test');
    });

    testWidgets('autofocus passes through to the underlying TextField', (tester) async {
      await pumpComponent(tester, const AppTextField(autofocus: true));
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.autofocus, isTrue);
    });
  });
}
