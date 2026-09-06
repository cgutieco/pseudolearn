import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/editor/editor_key.dart';
import 'package:pseudolearn_app/presentation/editor/components/editor_key_cap.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

Widget _cap({required EditorKey editorKey, required VoidCallback onPressed}) {
  return MaterialApp(
    theme: AppTheme.light(),
    locale: const Locale('es'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: DesignCanvas(
      child: Scaffold(
        body: EditorKeyCap(editorKey: editorKey, onPressed: onPressed),
      ),
    ),
  );
}

const _assignment = EditorKey(
  label: '<-',
  insertion: '<- ',
  kind: EditorKeyKind.assignment,
);

void main() {
  group('EditorKeyCap', () {
    testWidgets('shows the lexeme and announces what it inserts', (tester) async {
      await tester.pumpWidget(_cap(editorKey: _assignment, onPressed: () {}));
      await tester.pumpAndSettle();

      expect(find.text('<-'), findsOneWidget);
      expect(find.bySemanticsLabel('Insertar asignación'), findsOneWidget);
    });

    testWidgets('reports the press', (tester) async {
      var presses = 0;

      await tester.pumpWidget(_cap(editorKey: _assignment, onPressed: () => presses++));
      await tester.pumpAndSettle();

      await tester.tap(find.text('<-'));
      await tester.pumpAndSettle();

      expect(presses, 1);
    });

    testWidgets('a template has no fixed wording and announces its own label', (tester) async {
      await tester.pumpWidget(_cap(
        editorKey: const EditorKey.template(
          label: 'Si Entonces',
          insertion: 'Si condicion Entonces\n  \nFinSi',
          caretOffset: 3,
        ),
        onPressed: () {},
      ));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Si Entonces'), findsOneWidget);
    });

    testWidgets('an empty label still renders instead of breaking', (tester) async {
      await tester.pumpWidget(_cap(editorKey: const EditorKey.indent(), onPressed: () {}));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.bySemanticsLabel('Insertar sangría'), findsOneWidget);
    });
  });
}
