import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/completion/completion_item.dart';
import 'package:pseudolearn_app/domain/model/editor/editor_key.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/engine/editing/profile_key_source.dart';
import 'package:pseudolearn_app/presentation/editor/components/editor_key_cap.dart';
import 'package:pseudolearn_app/presentation/editor/components/editor_template_row.dart';
import 'package:pseudolearn_app/presentation/editor/editor_key_bar.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/spacing.dart';

final _keys = const ProfileKeySource().keysFor(SyntaxProfileId.classicSpanish);

const _templates = [
  CompletionItem(
    label: 'Si Entonces',
    template: 'Si condicion Entonces\n  \nFinSi',
    caretOffset: 3,
    family: CompletionFamily.structured,
  ),
];

Widget _bar({
  required ValueChanged<EditorKey> onKeyPressed,
  List<CompletionItem> templates = _templates,
}) {
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
        body: Align(
          alignment: Alignment.bottomCenter,
          child: EditorKeyBar(
            keys: _keys,
            templates: templates,
            onKeyPressed: onKeyPressed,
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('EditorKeyBar', () {
    testWidgets('shows every key of the profile in one fixed row', (tester) async {
      await tester.pumpWidget(_bar(onKeyPressed: (_) {}));
      await tester.pumpAndSettle();

      for (final key in _keys) {
        expect(find.text(key.label), findsOneWidget);
      }
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('reports the key that was pressed', (tester) async {
      EditorKey? pressed;

      await tester.pumpWidget(_bar(onKeyPressed: (key) => pressed = key));
      await tester.pumpAndSettle();

      await tester.tap(find.text('<-'));
      await tester.pumpAndSettle();

      expect(pressed?.kind, EditorKeyKind.assignment);
    });

    testWidgets('every key announces what it inserts, not how it is spelled', (tester) async {
      await tester.pumpWidget(_bar(onKeyPressed: (_) {}));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Insertar asignación'), findsOneWidget);
      expect(find.bySemanticsLabel('Insertar sangría'), findsOneWidget);
      expect(find.bySemanticsLabel('Mostrar plantillas de estructura'), findsOneWidget);
    });

    testWidgets('the templates toggle leads the row, away from the exit actions', (tester) async {
      await tester.pumpWidget(_bar(onKeyPressed: (_) {}));
      await tester.pumpAndSettle();

      final toggleLeft = tester.getTopLeft(find.bySemanticsLabel('Mostrar plantillas de estructura')).dx;
      for (final key in _keys) {
        expect(toggleLeft, lessThan(tester.getTopLeft(find.text(key.label)).dx));
      }
    });

    testWidgets('every key is tappable over the full touch target, not just its face', (tester) async {
      await tester.pumpWidget(_bar(onKeyPressed: (_) {}));
      await tester.pumpAndSettle();

      for (final key in _keys) {
        final cap = find.ancestor(
          of: find.text(key.label),
          matching: find.byType(EditorKeyCap),
        );
        final size = tester.getSize(cap);
        expect(size.height, greaterThanOrEqualTo(SpacingTokens.targetTouchMin));
        expect(size.width, greaterThanOrEqualTo(SpacingTokens.targetTouchMin));
      }
    });

    testWidgets('the templates toggle also fills its touch target', (tester) async {
      await tester.pumpWidget(_bar(onKeyPressed: (_) {}));
      await tester.pumpAndSettle();

      final size = tester.getSize(find.bySemanticsLabel('Mostrar plantillas de estructura'));

      expect(size.height, greaterThanOrEqualTo(SpacingTokens.targetTouchMin));
      expect(size.width, greaterThanOrEqualTo(SpacingTokens.targetTouchMin));
    });

    testWidgets('a template chip is tappable above its visible height', (tester) async {
      await tester.pumpWidget(_bar(onKeyPressed: (_) {}));
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel('Mostrar plantillas de estructura'));
      await tester.pumpAndSettle();

      final chip = find.ancestor(
        of: find.text('Si Entonces'),
        matching: find.byType(InkWell),
      );

      expect(tester.getSize(chip).height, greaterThanOrEqualTo(SpacingTokens.targetTouchMin));
    });

    testWidgets('the templates row stays hidden until it is asked for', (tester) async {
      await tester.pumpWidget(_bar(onKeyPressed: (_) {}));
      await tester.pumpAndSettle();

      expect(find.byType(EditorTemplateRow), findsNothing);

      await tester.tap(find.bySemanticsLabel('Mostrar plantillas de estructura'));
      await tester.pumpAndSettle();

      expect(find.byType(EditorTemplateRow), findsOneWidget);
      expect(find.text('Si Entonces'), findsOneWidget);
      expect(find.bySemanticsLabel('Ocultar plantillas de estructura'), findsOneWidget);
    });

    testWidgets('a template reaches the caller as a template key', (tester) async {
      EditorKey? pressed;

      await tester.pumpWidget(_bar(onKeyPressed: (key) => pressed = key));
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel('Mostrar plantillas de estructura'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Si Entonces'));
      await tester.pumpAndSettle();

      expect(pressed?.kind, EditorKeyKind.template);
      expect(pressed?.insertion, 'Si condicion Entonces\n  \nFinSi');
      expect(pressed?.caretOffset, 3);
    });

    testWidgets('with no templates the row stays empty instead of breaking', (tester) async {
      await tester.pumpWidget(_bar(onKeyPressed: (_) {}, templates: const []));
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel('Mostrar plantillas de estructura'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(EditorTemplateRow), findsNothing);
    });
  });
}
