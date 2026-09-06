import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/analysis/analysis_report.dart';
import 'package:pseudolearn_app/domain/model/analysis/program_node_id.dart';
import 'package:pseudolearn_app/domain/model/analysis/source_range.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_focus.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/analysis/core_program_analyzer.dart';
import 'package:pseudolearn_app/presentation/editor/code_field.dart';
import 'package:pseudolearn_app/presentation/editor/highlight_controller.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

const _factorial = '''
Proceso Factorial
	Definir n Como Entero;
	Definir f Como Entero;
	n <- 5;
	f <- 1;
	Escribir "Factorial: ", f;
FinProceso
''';

AnalysisReport _report() => CoreProgramAnalyzer().analyze(
      sourceCode: _factorial,
      profileId: SyntaxProfileId.classicSpanish,
      languageId: UiLanguageId.spanish,
    );

ExecutionFocus _focusOnAssignment() {
  final start = _factorial.indexOf('n <- 5;');
  final end = start + 'n <- 5;'.length;
  return ExecutionFocus(
    nodeId: const ProgramNodeId(1),
    range: SourceRange(
      startOffset: start,
      endOffset: end,
      startLine: 4,
      startColumn: 2,
      endLine: 4,
      endColumn: 9,
    ),
    kind: ExecutionFocusKind.statement,
  );
}

Future<void> _pump(
  WidgetTester tester, {
  required Size size,
  required ThemeData theme,
  ExecutionFocus? focus,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: theme,
    locale: const Locale('es'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: DesignCanvas(
        child: CodeField(
          controller: HighlightController(text: _factorial),
          highlightSpans: _report().highlightSpans,
          focus: focus,
          isReadOnly: true,
        ),
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  group('CodeField focus goldens', () {
    testWidgets('no execution · light', (tester) async {
      await _pump(tester, size: const Size(700, 320), theme: AppTheme.light());
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('code_field_idle_light.png'));
    });

    testWidgets('focused statement · light', (tester) async {
      await _pump(tester, size: const Size(700, 320), theme: AppTheme.light(), focus: _focusOnAssignment());
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('code_field_focused_light.png'));
    });

    testWidgets('focused statement · dark', (tester) async {
      await _pump(tester, size: const Size(700, 320), theme: AppTheme.dark(), focus: _focusOnAssignment());
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('code_field_focused_dark.png'));
    });
  });
}
