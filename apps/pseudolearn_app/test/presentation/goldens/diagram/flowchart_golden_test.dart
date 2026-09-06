import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/analysis/source_range.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_branch.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_focus.dart';
import 'package:pseudolearn_app/application/diagram/diagram_state.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_program.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_scene.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/diagram/flowchart_layout.dart';
import 'package:pseudolearn_app/engine/structogram/structogram_layout.dart';
import 'package:pseudolearn_app/presentation/diagram/flowchart_tab_view.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

const String _factorial = '''
Proceso Factorial
    Definir n Como Entero;
    Definir f Como Entero;
    Definir i Como Entero;
    n <- 5;
    f <- 1;
    Para i <- 1 Hasta n Con Paso 1 Hacer
        f <- f * i;
    FinPara
    Escribir "Factorial: ", f;
FinProceso
''';

const String _conditional = '''
Proceso Comparar
    Definir a Como Entero;
    Definir b Como Entero;
    Leer a, b;
    Si a = b Entonces
        Escribir "son iguales";
    SiNo
        Si a > b Entonces
            Escribir "el mayor es ", a;
        SiNo
            Escribir "el mayor es ", b;
        FinSi
    FinSi
FinProceso
''';

const String _loops = '''
Proceso Bucles
    Definir k Como Entero;
    k <- 0;
    Mientras k < 10 Hacer
        k <- k + 1;
    FinMientras
    Repetir
        k <- k - 1;
    Hasta Que k = 0
FinProceso
''';

const String _selection = '''
Proceso Menu
    Definir eleccion Como Entero;
    Leer eleccion;
    Segun eleccion Hacer
        1:
            Escribir "uno";
        2:
            Escribir "dos";
        De Otro Modo:
            Escribir "otro";
    FinSegun
FinProceso
''';

DiagramProgram _programOf(String source) => FlowchartLayout().buildDiagram(
      sourceCode: source,
      profileId: SyntaxProfileId.classicSpanish,
      languageId: UiLanguageId.spanish,
    );

DiagramScene _sceneOf(String source) => _programOf(source).sceneFor(null);

ExecutionFocus? _focusOnStatement(String source, int line) {
  for (final node in _sceneOf(source).nodes) {
    if (node.sourceLine != line || node.nodeId == null) continue;
    return ExecutionFocus(
      nodeId: node.nodeId!,
      range: SourceRange(
        startOffset: 0,
        endOffset: 1,
        startLine: line,
        startColumn: 1,
        endLine: line,
        endColumn: 2,
      ),
      kind: ExecutionFocusKind.statement,
    );
  }
  return null;
}

ExecutionFocus? _focusOnDecision(String source, int line, ExecutionBranchKind branch) {
  final statementFocus = _focusOnStatement(source, line);
  if (statementFocus == null) return null;
  return ExecutionFocus(
    nodeId: statementFocus.nodeId,
    range: statementFocus.range,
    kind: ExecutionFocusKind.decision,
    branch: ExecutionBranch(kind: branch),
  );
}

Future<void> _pump(
  WidgetTester tester, {
  required Size size,
  required ThemeData theme,
  required String source,
  ExecutionFocus? focus,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
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
          child: FlowchartTabView(
            state: DiagramState(
              flowchart: _programOf(source),
              structogram: StructogramLayout().buildDiagram(
                sourceCode: source,
                profileId: SyntaxProfileId.classicSpanish,
                languageId: UiLanguageId.spanish,
              ),
              classDiagram: const DiagramScene.empty(),
              hasValidAst: true,
            ),
            focus: focus,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('flowchart goldens', () {
    testWidgets('factorial · compact · light', (tester) async {
      await _pump(tester, size: const Size(420, 900), theme: AppTheme.light(), source: _factorial);
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('flowchart_factorial_compact_light.png'));
    });

    testWidgets('factorial · medium · dark', (tester) async {
      await _pump(tester, size: const Size(760, 900), theme: AppTheme.dark(), source: _factorial);
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('flowchart_factorial_medium_dark.png'));
    });

    testWidgets('factorial · expanded · light', (tester) async {
      await _pump(tester, size: const Size(1280, 900), theme: AppTheme.light(), source: _factorial);
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('flowchart_factorial_expanded_light.png'));
    });

    testWidgets('factorial · expanded · light · executing', (tester) async {
      await _pump(
        tester,
        size: const Size(1280, 900),
        theme: AppTheme.light(),
        source: _factorial,
        focus: _focusOnStatement(_factorial, 8),
      );
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('flowchart_factorial_active_light.png'));
    });

    testWidgets('factorial · expanded · light · loop turning', (tester) async {
      await _pump(
        tester,
        size: const Size(1280, 900),
        theme: AppTheme.light(),
        source: _factorial,
        focus: _focusOnDecision(_factorial, 7, ExecutionBranchKind.affirmative),
      );
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('flowchart_factorial_turning_light.png'));
    });

    testWidgets('factorial · expanded · light · loop leaving', (tester) async {
      await _pump(
        tester,
        size: const Size(1280, 900),
        theme: AppTheme.light(),
        source: _factorial,
        focus: _focusOnDecision(_factorial, 7, ExecutionBranchKind.negative),
      );
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('flowchart_factorial_leaving_light.png'));
    });

    testWidgets('nested conditionals · light', (tester) async {
      await _pump(tester, size: const Size(1280, 900), theme: AppTheme.light(), source: _conditional);
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('flowchart_conditional_light.png'));
    });

    testWidgets('nested conditionals · dark', (tester) async {
      await _pump(tester, size: const Size(1280, 900), theme: AppTheme.dark(), source: _conditional);
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('flowchart_conditional_dark.png'));
    });

    testWidgets('while and repeat · light', (tester) async {
      await _pump(tester, size: const Size(1280, 900), theme: AppTheme.light(), source: _loops);
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('flowchart_loops_light.png'));
    });

    testWidgets('selection · light', (tester) async {
      await _pump(tester, size: const Size(1280, 900), theme: AppTheme.light(), source: _selection);
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('flowchart_selection_light.png'));
    });
  });
}
