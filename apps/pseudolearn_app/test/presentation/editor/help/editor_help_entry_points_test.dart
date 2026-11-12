import 'package:cupertino_ui/cupertino_ui.dart' show GlobalCupertinoLocalizations;
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart' show GlobalWidgetsLocalizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/editor/editor_state.dart';
import 'package:pseudolearn_app/application/execution/execution_state.dart';
import 'package:pseudolearn_app/domain/model/analysis/source_range.dart';
import 'package:pseudolearn_app/domain/model/editor/caret_range.dart';
import 'package:pseudolearn_app/presentation/editor/editor_surface.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

const _source = 'Algoritmo P\n  Mientras 1 = 1 Hacer\nFinAlgoritmo\n';

const _whileKeyword = SourceRange(
  startOffset: 14,
  endOffset: 22,
  startLine: 2,
  startColumn: 3,
  endLine: 2,
  endColumn: 11,
);

const _chipLabel = 'Explicar el elemento bajo el cursor';

Widget _surface({
  ValueChanged<CaretRange>? onHelpRequested,
  SourceRange? helpKeyword,
  Size size = const Size(1024, 768),
  double keyboardInset = 0,
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
    home: MediaQuery(
      data: MediaQueryData(
        size: size,
        viewInsets: EdgeInsets.only(bottom: keyboardInset),
      ),
      child: DesignCanvas(
        child: Scaffold(
          body: EditorSurface(
            editorState: const EditorState.initial().copyWith(
              sourceCode: _source,
            ),
            executionState: const ExecutionState.initial(),
            onCodeChanged: (_, _) {},
            onDiagnosticSelected: (_) {},
            onKeyPressed: (_, _) {},
            onRun: () {},
            onHelpRequested: onHelpRequested,
            helpKeyword: helpKeyword,
          ),
        ),
      ),
    ),
  );
}

Future<void> _placeCaret(WidgetTester tester, int offset) async {
  await tester.tap(find.byType(TextField));
  await tester.pump();
  tester.widget<EditableText>(find.byType(EditableText)).controller.selection =
      TextSelection.collapsed(offset: offset);
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('without a help callback no explain affordance is offered', (
    tester,
  ) async {
    await tester.pumpWidget(_surface(helpKeyword: _whileKeyword));
    await _placeCaret(tester, 16);
    expect(find.text('Explicar'), findsNothing);
    expect(find.bySemanticsLabel(_chipLabel), findsNothing);
  });

  testWidgets('the editor no longer reserves a row for an explain button', (
    tester,
  ) async {
    await tester.pumpWidget(_surface(onHelpRequested: (_) {}));
    expect(find.text('Explicar'), findsNothing);
  });

  testWidgets('a caret resting on a keyword offers the help chip', (
    tester,
  ) async {
    CaretRange? requested;
    await tester.pumpWidget(
      _surface(
        onHelpRequested: (caret) => requested = caret,
        helpKeyword: _whileKeyword,
      ),
    );
    await _placeCaret(tester, 16);

    expect(find.bySemanticsLabel(_chipLabel), findsOneWidget);
    await tester.tap(find.bySemanticsLabel(_chipLabel));
    await tester.pump();
    expect(requested?.lower, 14);
    expect(requested?.isCollapsed, isTrue);
  });

  testWidgets('a caret outside the keyword hides the help chip', (
    tester,
  ) async {
    await tester.pumpWidget(
      _surface(onHelpRequested: (_) {}, helpKeyword: _whileKeyword),
    );
    await _placeCaret(tester, 30);

    expect(find.bySemanticsLabel(_chipLabel), findsNothing);
  });

  testWidgets('a selection spanning the keyword hides the help chip', (
    tester,
  ) async {
    await tester.pumpWidget(
      _surface(onHelpRequested: (_) {}, helpKeyword: _whileKeyword),
    );
    await tester.tap(find.byType(TextField));
    await tester.pump();
    tester.widget<EditableText>(find.byType(EditableText)).controller.selection =
        const TextSelection(baseOffset: 14, extentOffset: 22);
    await tester.pump();
    await tester.pump();

    expect(find.bySemanticsLabel(_chipLabel), findsNothing);
  });

  testWidgets('a keyword at the very start of the program keeps the chip on screen', (
    tester,
  ) async {
    const first = SourceRange(
      startOffset: 0,
      endOffset: 9,
      startLine: 1,
      startColumn: 1,
      endLine: 1,
      endColumn: 10,
    );
    await tester.pumpWidget(
      _surface(onHelpRequested: (_) {}, helpKeyword: first),
    );
    await _placeCaret(tester, 0);

    final chip = tester.getRect(find.bySemanticsLabel(_chipLabel));
    expect(chip.top, greaterThanOrEqualTo(0));
    expect(chip.left, greaterThanOrEqualTo(0));
    expect(tester.takeException(), isNull);
  });

  testWidgets('a cramped compact screen with keyboard keeps F1, not the row', (
    tester,
  ) async {
    var requests = 0;
    await tester.pumpWidget(
      _surface(
        onHelpRequested: (_) => requests++,
        size: const Size(360, 640),
        keyboardInset: 300,
      ),
    );
    expect(find.text('Explicar'), findsNothing);
    await tester.tap(find.byType(TextField));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.f1);
    expect(requests, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('F1 requests help from the focused field', (tester) async {
    var requests = 0;
    await tester.pumpWidget(_surface(onHelpRequested: (_) => requests++));
    await tester.tap(find.byType(TextField));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.f1);
    expect(requests, 1);
  });

  testWidgets('the context menu offers explain next to the standard actions', (
    tester,
  ) async {
    CaretRange? requested;
    await tester.pumpWidget(_surface(onHelpRequested: (c) => requested = c));
    await tester.longPress(find.byType(TextField));
    await tester.pumpAndSettle();
    expect(find.text('Explicar'), findsWidgets);
    await tester.tap(find.text('Explicar').last);
    await tester.pump();
    expect(requested, isNotNull);
  });
}
