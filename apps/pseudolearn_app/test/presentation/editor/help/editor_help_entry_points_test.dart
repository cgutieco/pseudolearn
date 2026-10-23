import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/editor/editor_state.dart';
import 'package:pseudolearn_app/application/execution/execution_state.dart';
import 'package:pseudolearn_app/domain/model/editor/caret_range.dart';
import 'package:pseudolearn_app/presentation/editor/editor_surface.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

const _source = 'Algoritmo P\n  Mientras 1 = 1 Hacer\nFinAlgoritmo\n';

Widget _surface({
  ValueChanged<CaretRange>? onHelpRequested,
  Widget? helpPanel,
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
            helpPanel: helpPanel,
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('without a help callback no explain action is offered', (
    tester,
  ) async {
    await tester.pumpWidget(_surface());
    expect(find.text('Explicar'), findsNothing);
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

  testWidgets('the explain button reports the current selection', (
    tester,
  ) async {
    CaretRange? requested;
    await tester.pumpWidget(_surface(onHelpRequested: (c) => requested = c));
    await tester.tap(find.text('Explicar'));
    expect(requested, isNotNull);
  });

  testWidgets('F1 requests help from the focused field', (tester) async {
    var requests = 0;
    await tester.pumpWidget(_surface(onHelpRequested: (_) => requests++));
    await tester.tap(find.byType(TextField));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.f1);
    expect(requests, 1);
  });

  testWidgets('the explain button is exposed as a labelled semantic button', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_surface(onHelpRequested: (_) {}));
    expect(
      tester.getSemantics(find.bySemanticsLabel('Explicar el elemento bajo el cursor')),
      matchesSemantics(
        label: 'Explicar el elemento bajo el cursor',
        isButton: true,
        hasTapAction: true,
        hasEnabledState: false,
      ),
    );
    handle.dispose();
  });

  testWidgets('the panel slot renders below the field', (tester) async {
    await tester.pumpWidget(
      _surface(
        onHelpRequested: (_) {},
        helpPanel: const Text('panel-visible'),
      ),
    );
    expect(find.text('panel-visible'), findsOneWidget);
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
