import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/diagram/diagram_state.dart';
import 'package:pseudolearn_app/domain/model/analysis/program_node_id.dart';
import 'package:pseudolearn_app/domain/model/analysis/source_range.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_notation.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_program.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_scene.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_focus.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/diagram/flowchart_layout.dart';
import 'package:pseudolearn_app/engine/structogram/structogram_layout.dart';
import 'package:pseudolearn_app/presentation/diagram/execution_overlay_painter.dart';
import 'package:pseudolearn_app/presentation/diagram/flowchart_painter.dart';
import 'package:pseudolearn_app/presentation/diagram/flowchart_tab_view.dart';
import 'package:pseudolearn_app/presentation/diagram/structogram_painter.dart';
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

DiagramState _stateOf(
  String source, {
  DiagramNotation notation = DiagramNotation.flowchart,
}) =>
    DiagramState(
      flowchart: _flowchartOf(source),
      structogram: _structogramOf(source),
      classDiagram: const DiagramScene.empty(),
      notation: notation,
      hasValidAst: true,
    );

ExecutionFocus _focusOn(ProgramNodeId nodeId) => ExecutionFocus(
      nodeId: nodeId,
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

ProgramNodeId _idSaying(DiagramScene scene, String text) {
  for (final node in scene.nodes) {
    if (node.lines.join(' ').contains(text) && node.nodeId != null) {
      return node.nodeId!;
    }
  }
  throw StateError('no cell says $text');
}

Future<void> _pump(
  WidgetTester tester,
  DiagramState state, {
  ExecutionFocus? focus,
  Size size = const Size(900, 800),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      locale: const Locale('es'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: DesignCanvas(child: FlowchartTabView(state: state, focus: focus)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

CustomPainter _structurePainter(WidgetTester tester) {
  final painters = tester.widgetList<CustomPaint>(find.byType(CustomPaint));
  for (final paint in painters) {
    if (paint.painter is FlowchartPainter || paint.painter is StructogramPainter) {
      return paint.painter!;
    }
  }
  throw StateError('no structure painter in the tree');
}

double _currentScale(WidgetTester tester) {
  final viewer = tester.widget<InteractiveViewer>(find.byType(InteractiveViewer));
  return viewer.transformationController!.value.getMaxScaleOnAxis();
}

void main() {
  group('the notation switch', () {
    testWidgets('offers both notations and marks the active one', (tester) async {
      await _pump(tester, _stateOf(_factorial));
      expect(find.text('Ordinograma'), findsOneWidget);
      expect(find.text('Estructograma'), findsOneWidget);
    });

    testWidgets('changes which painter draws the structure layer', (tester) async {
      await _pump(tester, _stateOf(_factorial));
      expect(_structurePainter(tester), isA<FlowchartPainter>());

      await _pump(
        tester,
        _stateOf(_factorial, notation: DiagramNotation.structogram),
      );
      expect(_structurePainter(tester), isA<StructogramPainter>());
    });

    testWidgets('keeps the zoom and the framing when the notation changes',
        (tester) async {
      await _pump(tester, _stateOf(_factorial));
      await tester.tap(find.byIcon(Icons.zoom_in));
      await tester.pumpAndSettle();
      final zoomed = _currentScale(tester);

      await _pump(
        tester,
        _stateOf(_factorial, notation: DiagramNotation.structogram),
      );
      expect(_currentScale(tester), closeTo(zoomed, 0.0001));
    });
  });

  group('the structure layer', () {
    test('ignores a change of execution step', () {
      final scene = _structogramOf(_factorial).sceneFor(null);
      final colors = AppTheme.light().extension<AppThemeExtension>()!.colors;
      final painter = StructogramPainter(scene: scene, colors: colors);
      expect(
        painter.shouldRepaint(StructogramPainter(scene: scene, colors: colors)),
        isFalse,
      );
    });

    test('repaints when the scene changes', () {
      final colors = AppTheme.light().extension<AppThemeExtension>()!.colors;
      final painter = StructogramPainter(
        scene: _structogramOf(_factorial).sceneFor(null),
        colors: colors,
      );
      expect(
        painter.shouldRepaint(StructogramPainter(
          scene: const DiagramScene.empty(),
          colors: colors,
        )),
        isTrue,
      );
    });
  });

  group('the highlight layer', () {
    test('repaints when the step moves, over the very same scene', () {
      final scene = _structogramOf(_factorial).sceneFor(null);
      final colors = AppTheme.light().extension<AppThemeExtension>()!.colors;
      final painter = ExecutionOverlayPainter(
        scene: scene,
        focus: _focusOn(_idSaying(scene, 'f <- f * i')),
        colors: colors,
      );
      expect(
        painter.shouldRepaint(ExecutionOverlayPainter(
          scene: scene,
          focus: _focusOn(_idSaying(scene, 'n <- 5')),
          colors: colors,
        )),
        isTrue,
      );
    });

    testWidgets('draws over the structogram without disturbing it',
        (tester) async {
      final scene = _structogramOf(_factorial).sceneFor(null);
      await _pump(
        tester,
        _stateOf(_factorial, notation: DiagramNotation.structogram),
        focus: _focusOn(_idSaying(scene, 'f <- f * i')),
      );
      expect(_structurePainter(tester), isA<StructogramPainter>());
      expect(tester.takeException(), isNull);
    });
  });

  group('the empty state', () {
    testWidgets('names the structogram when that is the active notation',
        (tester) async {
      await _pump(
        tester,
        const DiagramState.initial().copyWith(
          notation: DiagramNotation.structogram,
        ),
      );
      expect(
        find.text(
          'El estructograma estará disponible cuando el código no tenga errores.',
        ),
        findsOneWidget,
      );
      expect(find.byType(InteractiveViewer), findsNothing);
    });

    testWidgets('names the flowchart when that is the active notation',
        (tester) async {
      await _pump(tester, const DiagramState.initial());
      expect(
        find.text(
          'El ordinograma estará disponible cuando el código no tenga errores.',
        ),
        findsOneWidget,
      );
    });
  });
}
