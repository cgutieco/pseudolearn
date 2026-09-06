import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/components/field/app_text_field.dart';
import 'package:pseudolearn_app/presentation/document/components/inline_title_field.dart';
import '../../components/component_test_harness.dart';

void main() {
  group('InlineTitleField', () {
    testWidgets('renders title display chip initially', (tester) async {
      await pumpComponent(
        tester,
        InlineTitleField(title: 'Mi Algoritmo', onTitleChanged: (_) {}),
      );

      expect(find.text('Mi Algoritmo'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byType(AppTextField), findsNothing);
    });

    testWidgets('tapping chip switches to edit mode with compact AppTextField', (tester) async {
      await pumpComponent(
        tester,
        InlineTitleField(title: 'Mi Algoritmo', onTitleChanged: (_) {}),
      );

      await tester.tap(find.text('Mi Algoritmo'));
      await tester.pumpAndSettle();

      expect(find.byType(AppTextField), findsOneWidget);
      final appTextField = tester.widget<AppTextField>(find.byType(AppTextField));
      expect(appTextField.size, AppTextFieldSize.compact);
      expect(appTextField.autofocus, isTrue);
    });

    testWidgets('submitting new text invokes onTitleChanged and exits edit mode', (tester) async {
      String? changed;
      await pumpComponent(
        tester,
        InlineTitleField(
          title: 'Antiguo',
          onTitleChanged: (value) => changed = value,
        ),
      );

      await tester.tap(find.text('Antiguo'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Nuevo Titulo');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(changed, 'Nuevo Titulo');
      expect(find.byType(AppTextField), findsNothing);
    });

    testWidgets('submitting empty or whitespace text does not invoke onTitleChanged', (tester) async {
      var invoked = false;
      await pumpComponent(
        tester,
        InlineTitleField(
          title: 'Original',
          onTitleChanged: (_) => invoked = true,
        ),
      );

      await tester.tap(find.text('Original'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '   ');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(invoked, isFalse);
      expect(find.text('Original'), findsOneWidget);
      expect(find.byType(AppTextField), findsNothing);
    });

    testWidgets('tapping outside exits edit mode', (tester) async {
      await pumpComponent(
        tester,
        InlineTitleField(title: 'Algoritmo', onTitleChanged: (_) {}),
      );

      await tester.tap(find.text('Algoritmo'));
      await tester.pumpAndSettle();
      expect(find.byType(AppTextField), findsOneWidget);

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.byType(AppTextField), findsNothing);
      expect(find.text('Algoritmo'), findsOneWidget);
    });
  });
}
