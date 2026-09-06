import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/diagram/diagram_state.dart';
import 'package:pseudolearn_app/domain/model/analysis/source_range.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_notation.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_program.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_scene.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_focus.dart';
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
    Para k <- 1 Hasta 3 Hacer
        Escribir k;
    FinPara
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

const String _exit = '''
Proceso P
    Definir z Como Entero;
FinProceso
SubProceso Buscar(objetivo Como Entero) Como Entero
    Definir i Como Entero;
    Si objetivo > 0 Entonces
        Retornar objetivo;
    FinSi
    Retornar 0;
FinSubProceso
''';

const String _deep = '''
Proceso Profundo
    Definir i Como Entero;
    Definir j Como Entero;
    Si i > 0 Entonces
        Si j > 0 Entonces
            Si i > j Entonces
                Escribir "a";
            SiNo
                Escribir "b";
            FinSi
        SiNo
            Escribir "c";
        FinSi
    SiNo
        Escribir "d";
    FinSi
FinProceso
''';

DiagramProgram _flowchartOf(String source) => FlowchartLayout().buildDiagram(
      sourceCode: source,
      profileId: SyntaxProfileId.classicSpanish,
      languageId: UiLanguageId.spanish,
    );

DiagramProgram _structogramOf(String source) =>
    StructogramLayout().buildDiagram(
      sourceCode: source,
      profileId: SyntaxProfileId.classicSpanish,
      languageId: UiLanguageId.spanish,
    );

DiagramState _stateOf(String source, {String? unitId}) => DiagramState(
      flowchart: _flowchartOf(source),
      structogram: _structogramOf(source),
      classDiagram: const DiagramScene.empty(),
      notation: DiagramNotation.structogram,
      selectedUnitId: unitId,
      hasValidAst: true,
    );

ExecutionFocus? _focusOn(String source, String text) {
  final scene = _structogramOf(source).sceneFor(null);
  for (final node in scene.nodes) {
    if (!node.lines.join(' ').contains(text) || node.nodeId == null) continue;
    return ExecutionFocus(
      nodeId: node.nodeId!,
      range: const SourceRange(
        startOffset: 0,
        endOffset: 1,
        startLine: 1,
        startColumn: 1,
        endLine: 1,
        endColumn: 2,
      ),
      kind: ExecutionFocusKind.statement,
    );
  }
  return null;
}

Future<void> _pump(
  WidgetTester tester, {
  required Size size,
  required ThemeData theme,
  required DiagramState state,
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
          child: FlowchartTabView(state: state, focus: focus),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('structogram goldens', () {
    testWidgets('factorial · compact · light', (tester) async {
      await _pump(
        tester,
        size: const Size(420, 900),
        theme: AppTheme.light(),
        state: _stateOf(_factorial),
      );
      await expectLater(find.byType(MaterialApp),
          matchesGoldenFile('structogram_factorial_compact_light.png'));
    });

    testWidgets('factorial · medium · dark', (tester) async {
      await _pump(
        tester,
        size: const Size(760, 900),
        theme: AppTheme.dark(),
        state: _stateOf(_factorial),
      );
      await expectLater(find.byType(MaterialApp),
          matchesGoldenFile('structogram_factorial_medium_dark.png'));
    });

    testWidgets('factorial · expanded · light', (tester) async {
      await _pump(
        tester,
        size: const Size(1280, 900),
        theme: AppTheme.light(),
        state: _stateOf(_factorial),
      );
      await expectLater(find.byType(MaterialApp),
          matchesGoldenFile('structogram_factorial_expanded_light.png'));
    });

    testWidgets('factorial · expanded · dark', (tester) async {
      await _pump(
        tester,
        size: const Size(1280, 900),
        theme: AppTheme.dark(),
        state: _stateOf(_factorial),
      );
      await expectLater(find.byType(MaterialApp),
          matchesGoldenFile('structogram_factorial_expanded_dark.png'));
    });

    testWidgets('factorial · expanded · light · executing', (tester) async {
      await _pump(
        tester,
        size: const Size(1280, 900),
        theme: AppTheme.light(),
        state: _stateOf(_factorial),
        focus: _focusOn(_factorial, 'f <- f * i'),
      );
      await expectLater(find.byType(MaterialApp),
          matchesGoldenFile('structogram_factorial_active_light.png'));
    });

    testWidgets('nested conditionals · light', (tester) async {
      await _pump(
        tester,
        size: const Size(1280, 900),
        theme: AppTheme.light(),
        state: _stateOf(_conditional),
      );
      await expectLater(find.byType(MaterialApp),
          matchesGoldenFile('structogram_conditional_light.png'));
    });

    testWidgets('the three loops · light', (tester) async {
      await _pump(
        tester,
        size: const Size(1280, 900),
        theme: AppTheme.light(),
        state: _stateOf(_loops),
      );
      await expectLater(find.byType(MaterialApp),
          matchesGoldenFile('structogram_loops_light.png'));
    });

    testWidgets('multiple selection · light', (tester) async {
      await _pump(
        tester,
        size: const Size(1280, 900),
        theme: AppTheme.light(),
        state: _stateOf(_selection),
      );
      await expectLater(find.byType(MaterialApp),
          matchesGoldenFile('structogram_selection_light.png'));
    });

    testWidgets('early exit · light', (tester) async {
      await _pump(
        tester,
        size: const Size(1280, 900),
        theme: AppTheme.light(),
        state: _stateOf(_exit, unitId: 'sub_Buscar'),
      );
      await expectLater(find.byType(MaterialApp),
          matchesGoldenFile('structogram_exit_light.png'));
    });

    testWidgets('deep nesting · light', (tester) async {
      await _pump(
        tester,
        size: const Size(1280, 900),
        theme: AppTheme.light(),
        state: _stateOf(_deep),
      );
      await expectLater(find.byType(MaterialApp),
          matchesGoldenFile('structogram_deep_light.png'));
    });
  });
}
