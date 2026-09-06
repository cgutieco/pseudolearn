import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/editor/editor_state.dart';
import 'package:pseudolearn_app/application/execution/execution_state.dart';
import 'package:pseudolearn_app/domain/model/analysis/analysis_report.dart';
import 'package:pseudolearn_app/domain/model/analysis/program_node_id.dart';
import 'package:pseudolearn_app/domain/model/analysis/source_range.dart';
import 'package:pseudolearn_app/domain/model/completion/completion_item.dart';
import 'package:pseudolearn_app/domain/model/editor/caret_range.dart';
import 'package:pseudolearn_app/domain/model/editor/editor_key.dart';
import 'package:pseudolearn_app/domain/model/editor/source_edit.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_focus.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_step.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/engine/editing/profile_key_source.dart';
import 'package:pseudolearn_app/presentation/editor/code_field.dart';
import 'package:pseudolearn_app/presentation/editor/components/keyboard_exit_actions.dart';
import 'package:pseudolearn_app/presentation/editor/editor_key_bar.dart';
import 'package:pseudolearn_app/presentation/editor/editor_surface.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

const _compact = Size(390, 844);
const _wideTablet = Size(1024, 768);

final _keys = const ProfileKeySource().keysFor(SyntaxProfileId.classicSpanish);

const _completions = [
  CompletionItem(
    label: 'Si Entonces',
    template: 'Si condicion Entonces\n  \nFinSi',
    caretOffset: 3,
    family: CompletionFamily.structured,
  ),
];

EditorState _state({
  required String sourceCode,
  SourceEdit? pendingEdit,
  bool showsKeyBar = true,
  bool hasKeys = true,
  bool isExecutable = true,
}) {
  return EditorState(
    document: null,
    sourceCode: sourceCode,
    report: isExecutable
        ? const AnalysisReport.empty()
        : const AnalysisReport(
            isExecutable: false, diagnostics: [], highlightSpans: []),
    completions: _completions,
    keys: hasKeys ? _keys : const [],
    pendingEdit: pendingEdit,
    showsKeyBar: showsKeyBar,
  );
}

Widget _surface({
  required EditorState editorState,
  required EditorKeyPressed onKeyPressed,
  Size size = _compact,
  double keyboardInset = 320,
  ExecutionState executionState = const ExecutionState.initial(),
  VoidCallback onRun = _ignoreRun,
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
            editorState: editorState,
            executionState: executionState,
            onCodeChanged: (_) {},
            onDiagnosticSelected: (_) {},
            onKeyPressed: onKeyPressed,
            onRun: onRun,
          ),
        ),
      ),
    ),
  );
}

void _ignoreRun() {}

bool _fieldHasFocus(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField)).focusNode!.hasFocus;

Finder _barKey(String label) => find.descendant(
      of: find.byType(EditorKeyBar),
      matching: find.text(label),
    );

void main() {
  group('EditorSurface · caret', () {
    testWidgets('reports the caret sitting in the field when a key is pressed',
        (tester) async {
      EditorKey? pressedKey;
      CaretRange? pressedCaret;

      await tester.pumpWidget(_surface(
        editorState: _state(sourceCode: 'Proceso P\nFinProceso'),
        onKeyPressed: (key, caret) {
          pressedKey = key;
          pressedCaret = caret;
        },
      ));
      await tester.pumpAndSettle();

      final field = tester.widget<TextField>(find.byType(TextField));
      field.controller!.selection = const TextSelection.collapsed(offset: 9);

      await tester.tap(_barKey('<-'));
      await tester.pumpAndSettle();

      expect(pressedKey?.kind, EditorKeyKind.assignment);
      expect(pressedCaret, const CaretRange(start: 9, end: 9));
    });

    testWidgets(
        'falls back to the end of the document when the field was never focused',
        (tester) async {
      CaretRange? pressedCaret;

      await tester.pumpWidget(_surface(
        editorState: _state(sourceCode: 'Proceso P'),
        onKeyPressed: (_, caret) => pressedCaret = caret,
      ));
      await tester.pumpAndSettle();

      await tester.tap(_barKey('<-'));
      await tester.pumpAndSettle();

      expect(pressedCaret, const CaretRange(start: 9, end: 9));
    });

    testWidgets(
        'applies a pending edit once and leaves the caret where it says',
        (tester) async {
      await tester.pumpWidget(_surface(
        editorState: _state(sourceCode: 'Proceso P'),
        onKeyPressed: (_, __) {},
      ));
      await tester.pumpAndSettle();

      await tester.pumpWidget(_surface(
        editorState: _state(
          sourceCode: 'Proceso P<-',
          pendingEdit: const SourceEdit(
            sourceCode: 'Proceso P<-',
            caret: CaretRange.collapsed(11),
            revision: 1,
          ),
        ),
        onKeyPressed: (_, __) {},
      ));
      await tester.pumpAndSettle();

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, 'Proceso P<-');
      expect(field.controller!.selection.baseOffset, 11);
    });

    testWidgets(
        'remounting keeps text typed after a pending edit instead of replaying it',
        (tester) async {
      const staleEdit = SourceEdit(
        sourceCode: 'Proceso P<-',
        caret: CaretRange.collapsed(11),
        revision: 1,
      );

      await tester.pumpWidget(_surface(
        editorState: _state(sourceCode: 'Proceso P<-', pendingEdit: staleEdit),
        onKeyPressed: (_, __) {},
      ));
      await tester.pumpAndSettle();

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();

      await tester.pumpWidget(_surface(
        editorState:
            _state(sourceCode: 'Proceso P<- 6', pendingEdit: staleEdit),
        onKeyPressed: (_, __) {},
      ));
      await tester.pumpAndSettle();

      await tester.pumpWidget(_surface(
        editorState:
            _state(sourceCode: 'Proceso P<- 6', pendingEdit: staleEdit),
        onKeyPressed: (_, __) {},
        executionState: const ExecutionState.initial().copyWith(
          isOutputPanelExpanded: true,
        ),
      ));
      await tester.pumpAndSettle();

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, 'Proceso P<- 6');
    });

    testWidgets('undoing after a pressed key restores the previous text',
        (tester) async {
      await tester.pumpWidget(_surface(
        editorState: _state(sourceCode: 'Proceso P'),
        onKeyPressed: (_, __) {},
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 600));

      await tester.pumpWidget(_surface(
        editorState: _state(
          sourceCode: 'Proceso P<-',
          pendingEdit: const SourceEdit(
            sourceCode: 'Proceso P<-',
            caret: CaretRange.collapsed(11),
            revision: 1,
          ),
        ),
        onKeyPressed: (_, __) {},
      ));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 600));

      final controller =
          tester.widget<TextField>(find.byType(TextField)).controller!;
      expect(controller.text, 'Proceso P<-');

      Actions.invoke(
        primaryFocus!.context!,
        const UndoTextIntent(SelectionChangedCause.keyboard),
      );
      await tester.pumpAndSettle();

      expect(controller.text, 'Proceso P');
    });
  });

  group('EditorSurface · when the key bar appears', () {
    testWidgets('compact with the keyboard up shows it', (tester) async {
      await tester.pumpWidget(_surface(
        editorState: _state(sourceCode: 'Proceso P'),
        onKeyPressed: (_, __) {},
      ));
      await tester.pumpAndSettle();

      expect(find.byType(EditorKeyBar), findsOneWidget);
    });

    testWidgets('no keyboard hides it', (tester) async {
      await tester.pumpWidget(_surface(
        editorState: _state(sourceCode: 'Proceso P'),
        onKeyPressed: (_, __) {},
        keyboardInset: 0,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(EditorKeyBar), findsNothing);
    });

    testWidgets('a wide tablet writing on screen still shows it',
        (tester) async {
      await tester.pumpWidget(_surface(
        editorState: _state(sourceCode: 'Proceso P'),
        onKeyPressed: (_, __) {},
        size: _wideTablet,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(EditorKeyBar), findsOneWidget);
    });

    testWidgets('a machine that types on a physical keyboard never shows it',
        (tester) async {
      await tester.pumpWidget(_surface(
        editorState: _state(sourceCode: 'Proceso P', showsKeyBar: false),
        onKeyPressed: (_, __) {},
        size: _wideTablet,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(EditorKeyBar), findsNothing);
    });

    testWidgets('a profile with no keys yet shows nothing', (tester) async {
      await tester.pumpWidget(_surface(
        editorState: _state(sourceCode: 'Proceso P', hasKeys: false),
        onKeyPressed: (_, __) {},
      ));
      await tester.pumpAndSettle();

      expect(find.byType(EditorKeyBar), findsNothing);
    });

    testWidgets('a run in flight hides it', (tester) async {
      await tester.pumpWidget(_surface(
        editorState: _state(sourceCode: 'Proceso P'),
        onKeyPressed: (_, __) {},
        executionState: const ExecutionState.initial().copyWith(
          status: ExecutionStatus.running,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(EditorKeyBar), findsNothing);
    });
  });

  group('EditorSurface · diagnostics panel', () {
    testWidgets('collapses to its count line in compact with the keyboard up',
        (tester) async {
      await tester.pumpWidget(_surface(
        editorState: _state(sourceCode: 'Proceso P'),
        onKeyPressed: (_, __) {},
      ));
      await tester.pumpAndSettle();

      expect(find.byTooltip('Expandir'), findsNothing);
    });

    testWidgets('keeps its toggle when the keyboard is down', (tester) async {
      await tester.pumpWidget(_surface(
        editorState: _state(sourceCode: 'Proceso P'),
        onKeyPressed: (_, __) {},
        keyboardInset: 0,
      ));
      await tester.pumpAndSettle();

      expect(find.byTooltip('Expandir'), findsOneWidget);
    });
  });

  group('EditorSurface · leaving the keyboard', () {
    testWidgets('compact with the keyboard up offers running and hiding',
        (tester) async {
      await tester.pumpWidget(_surface(
        editorState: _state(sourceCode: 'Proceso P'),
        onKeyPressed: (_, __) {},
      ));
      await tester.pumpAndSettle();

      expect(find.byType(KeyboardExitActions), findsOneWidget);
      expect(find.byTooltip('Ejecutar'), findsOneWidget);
      expect(find.byTooltip('Ocultar teclado'), findsOneWidget);
    });

    testWidgets('no keyboard leaves them to the execution footer',
        (tester) async {
      await tester.pumpWidget(_surface(
        editorState: _state(sourceCode: 'Proceso P'),
        onKeyPressed: (_, __) {},
        keyboardInset: 0,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(KeyboardExitActions), findsNothing);
    });

    testWidgets('a wide canvas keeps its footer and needs no exit actions',
        (tester) async {
      await tester.pumpWidget(_surface(
        editorState: _state(sourceCode: 'Proceso P'),
        onKeyPressed: (_, __) {},
        size: _wideTablet,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(KeyboardExitActions), findsNothing);
    });

    testWidgets('running drops the focus before asking for the run',
        (tester) async {
      var runs = 0;

      await tester.pumpWidget(_surface(
        editorState: _state(sourceCode: 'Proceso P'),
        onKeyPressed: (_, __) {},
        onRun: () => runs++,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      expect(_fieldHasFocus(tester), isTrue);

      await tester.tap(find.byTooltip('Ejecutar'));
      await tester.pumpAndSettle();

      expect(runs, 1);
      expect(_fieldHasFocus(tester), isFalse);
    });

    testWidgets('a program that does not compile cannot be run from here',
        (tester) async {
      var runs = 0;

      await tester.pumpWidget(_surface(
        editorState: _state(sourceCode: 'Proceso P', isExecutable: false),
        onKeyPressed: (_, __) {},
        onRun: () => runs++,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Ejecutar'));
      await tester.pumpAndSettle();

      expect(runs, 0);
    });

    testWidgets('a run already in flight cannot be started again',
        (tester) async {
      var runs = 0;

      await tester.pumpWidget(_surface(
        editorState: _state(sourceCode: 'Proceso P'),
        onKeyPressed: (_, __) {},
        onRun: () => runs++,
        executionState: const ExecutionState.initial().copyWith(
          status: ExecutionStatus.running,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Ejecutar'));
      await tester.pumpAndSettle();

      expect(runs, 0);
    });

    testWidgets('hiding the keyboard drops the focus without running',
        (tester) async {
      var runs = 0;

      await tester.pumpWidget(_surface(
        editorState: _state(sourceCode: 'Proceso P'),
        onKeyPressed: (_, __) {},
        onRun: () => runs++,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      expect(_fieldHasFocus(tester), isTrue);

      await tester.tap(find.byTooltip('Ocultar teclado'));
      await tester.pumpAndSettle();

      expect(_fieldHasFocus(tester), isFalse);
      expect(runs, 0);
    });

    testWidgets('tapping the diagnostics strip drops the focus too',
        (tester) async {
      await tester.pumpWidget(_surface(
        editorState: _state(sourceCode: 'Proceso P'),
        onKeyPressed: (_, __) {},
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      expect(_fieldHasFocus(tester), isTrue);

      await tester.tap(find.text('Sin problemas'));
      await tester.pumpAndSettle();

      expect(_fieldHasFocus(tester), isFalse);
    });

    testWidgets('tapping the code field keeps writing instead of hiding',
        (tester) async {
      await tester.pumpWidget(_surface(
        editorState: _state(sourceCode: 'Proceso P'),
        onKeyPressed: (_, __) {},
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      expect(_fieldHasFocus(tester), isTrue);
    });
  });

  group('EditorSurface · physical keyboard', () {
    testWidgets('the tab key enters through the same port as the drawn one',
        (tester) async {
      EditorKey? pressedKey;
      CaretRange? pressedCaret;

      await tester.pumpWidget(_surface(
        editorState: _state(sourceCode: 'Proceso P', showsKeyBar: false),
        onKeyPressed: (key, caret) {
          pressedKey = key;
          pressedCaret = caret;
        },
        size: _wideTablet,
        keyboardInset: 0,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      final field = tester.widget<TextField>(find.byType(TextField));
      field.controller!.selection = const TextSelection.collapsed(offset: 4);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      expect(pressedKey?.kind, EditorKeyKind.indent);
      expect(pressedCaret, const CaretRange(start: 4, end: 4));
      expect(find.byType(EditorKeyBar), findsNothing);
    });

    testWidgets('shift and tab asks for a dedent', (tester) async {
      EditorKey? pressedKey;

      await tester.pumpWidget(_surface(
        editorState: _state(sourceCode: 'Proceso P', showsKeyBar: false),
        onKeyPressed: (key, _) => pressedKey = key,
        size: _wideTablet,
        keyboardInset: 0,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pumpAndSettle();

      expect(pressedKey?.kind, EditorKeyKind.dedent);
    });

    testWidgets('CodeField only receives focus when execution isInFlight',
        (tester) async {
      const focus = ExecutionFocus(
        nodeId: ProgramNodeId(1),
        range: SourceRange(
            startOffset: 0,
            endOffset: 7,
            startLine: 1,
            startColumn: 1,
            endLine: 1,
            endColumn: 8),
        kind: ExecutionFocusKind.statement,
      );
      const finishedStep = ExecutionStep(
        stepNumber: 1,
        scopeName: 'global',
        scopeDepth: 1,
        focus: focus,
        isFinished: true,
      );
      final finishedExecState = const ExecutionState.initial().copyWith(
        status: ExecutionStatus.finishedSuccess,
        currentStep: finishedStep,
      );

      await tester.pumpWidget(_surface(
        editorState: _state(sourceCode: 'Proceso P'),
        executionState: finishedExecState,
        onKeyPressed: (_, __) {},
      ));
      await tester.pumpAndSettle();

      var codeField = tester.widget<CodeField>(find.byType(CodeField));
      expect(codeField.focus, isNull);

      final inFlightExecState = const ExecutionState.initial().copyWith(
        status: ExecutionStatus.pausedAtStatement,
        currentStep: finishedStep,
      );
      await tester.pumpWidget(_surface(
        editorState: _state(sourceCode: 'Proceso P'),
        executionState: inFlightExecState,
        onKeyPressed: (_, __) {},
      ));
      await tester.pumpAndSettle();

      codeField = tester.widget<CodeField>(find.byType(CodeField));
      expect(codeField.focus, focus);
    });
  });
}
