import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/diagram/diagram_state.dart';
import 'package:pseudolearn_app/domain/model/analysis/program_node_id.dart';
import 'package:pseudolearn_app/domain/model/analysis/source_range.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_focus_frame.dart';
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
import 'package:pseudolearn_app/presentation/diagram/flowchart_viewport.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/component_metrics.dart';

const String _wideProgram = '''
Proceso Ancho
    Definir a Como Entero;
    Definir b Como Entero;
    Leer a, b;
    Si a = b Entonces
        Escribir "los dos valores recibidos son exactamente iguales";
    SiNo
        Si a > b Entonces
            Escribir "el primer valor recibido es el mayor de los dos", a;
        SiNo
            Escribir "el segundo valor recibido es el mayor de los dos", b;
        FinSi
    FinSi
FinProceso
''';

const String _tallProgram = '''
Proceso Termostato
    Definir temperatura Como Entero;
    Definir lecturas Como Entero;
    temperatura <- 30;
    lecturas <- 0;
    Mientras temperatura > 24 Hacer
        temperatura <- temperatura - 3;
        lecturas <- lecturas + 1;
        Escribir "Lectura ", lecturas, ": ", temperatura;
    FinMientras
    Escribir "Confort alcanzado tras ", lecturas, " lecturas";
FinProceso
''';

DiagramProgram _programOf(String source) => FlowchartLayout().buildDiagram(
      sourceCode: source,
      profileId: SyntaxProfileId.classicSpanish,
      languageId: UiLanguageId.spanish,
    );

DiagramProgram _structogramOf(String source) => StructogramLayout().buildDiagram(
      sourceCode: source,
      profileId: SyntaxProfileId.classicSpanish,
      languageId: UiLanguageId.spanish,
    );

DiagramState _stateOf(
  String source, {
  DiagramNotation notation = DiagramNotation.flowchart,
}) =>
    DiagramState(
      flowchart: _programOf(source),
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

DiagramNode _nodeSaying(DiagramScene scene, String text) {
  for (final node in scene.nodes) {
    if (node.nodeId == null) continue;
    if (!node.lines.join(' ').contains(text)) continue;
    return node;
  }
  throw StateError('no node says $text');
}

Matrix4 _currentMatrix(WidgetTester tester) {
  final viewer = tester.widget<InteractiveViewer>(
    find.byType(InteractiveViewer),
  );
  return viewer.transformationController!.value;
}

Offset _nodeCentreOnScreen(
  WidgetTester tester,
  DiagramScene scene,
  DiagramNode node,
  Size viewport,
) {
  final flow = FlowchartViewport(scene: scene, viewport: viewport);
  final origin = Offset(
    (flow.childSize.width - scene.width) / 2,
    (flow.childSize.height - scene.height) / 2,
  );
  final matrix = _currentMatrix(tester);
  final scale = matrix.getMaxScaleOnAxis();
  final translation = matrix.getTranslation();
  return Offset(
    (node.x + node.width / 2 + origin.dx) * scale + translation.x,
    (node.y + node.height / 2 + origin.dy) * scale + translation.y,
  );
}

Future<void> _pump(
  WidgetTester tester,
  DiagramState state, {
  Size size = const Size(900, 700),
  bool framesSceneOnLayout = false,
  bool followsExecutionFocus = false,
  ExecutionFocus? focus,
  bool settles = true,
  ValueChanged<DiagramNotation>? onNotationSelected,
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
        body: DesignCanvas(
          child: FlowchartTabView(
            state: state,
            focus: focus,
            framesSceneOnLayout: framesSceneOnLayout,
            followsExecutionFocus: followsExecutionFocus,
            onNotationSelected: onNotationSelected,
          ),
        ),
      ),
    ),
  );
  if (settles) await tester.pumpAndSettle();
}

double _currentScale(WidgetTester tester) {
  final viewer = tester.widget<InteractiveViewer>(
    find.byType(InteractiveViewer),
  );
  return viewer.transformationController!.value.getMaxScaleOnAxis();
}

Future<void> _tapControl(
  WidgetTester tester,
  IconData icon, {
  int times = 1,
}) async {
  for (var press = 0; press < times; press++) {
    await tester.tap(find.byIcon(icon));
    await tester.pumpAndSettle();
  }
}

void main() {
  group('empty state', () {
    testWidgets('shows the reason instead of an empty canvas', (tester) async {
      await _pump(tester, const DiagramState.initial());
      expect(find.text('Diagramas'), findsOneWidget);
      expect(
        find.text(
          'El ordinograma estará disponible cuando el código no tenga errores.',
        ),
        findsOneWidget,
      );
      expect(find.byType(InteractiveViewer), findsNothing);
    });

    testWidgets('shows notation switch in empty state and triggers callback',
        (tester) async {
      DiagramNotation? selected;
      await _pump(
        tester,
        const DiagramState.initial(),
        onNotationSelected: (notation) => selected = notation,
      );

      expect(find.text('Ordinograma'), findsOneWidget);
      expect(find.text('Estructograma'), findsOneWidget);
      expect(find.text('Diagrama de clases'), findsOneWidget);

      await tester.tap(find.text('Diagrama de clases'));
      await tester.pumpAndSettle();

      expect(selected, DiagramNotation.classDiagram);
    });

    testWidgets(
        'shows class diagram empty message with notation switch when program has no classes',
        (tester) async {
      DiagramNotation? selected;
      final state = DiagramState(
        flowchart: _programOf(_wideProgram),
        structogram: _structogramOf(_wideProgram),
        classDiagram: const DiagramScene.empty(),
        notation: DiagramNotation.classDiagram,
        hasValidAst: true,
      );

      await _pump(
        tester,
        state,
        onNotationSelected: (notation) => selected = notation,
      );

      expect(
        find.text('Este documento no declara ninguna clase.'),
        findsOneWidget,
      );
      expect(find.text('Ordinograma'), findsOneWidget);
      expect(find.text('Estructograma'), findsOneWidget);
      expect(find.text('Diagrama de clases'), findsOneWidget);

      await tester.tap(find.text('Ordinograma'));
      await tester.pumpAndSettle();

      expect(selected, DiagramNotation.flowchart);
    });
  });

  group('assisted camera', () {
    const viewport = Size(390, 700);
    const half = Duration(milliseconds: 120);

    testWidgets('leaves the framing alone when the assistance is off',
        (tester) async {
      final state = _stateOf(_tallProgram);
      final target = _nodeSaying(state.scene, 'Confort');
      await _pump(tester, state, size: viewport);
      final before = _currentMatrix(tester).clone();

      await _pump(
        tester,
        state,
        size: viewport,
        focus: _focusOn(target.nodeId!),
      );

      expect(_currentMatrix(tester), equals(before));
    });

    testWidgets('brings the active block to the centre of the panel',
        (tester) async {
      final state = _stateOf(_tallProgram);
      final target = _nodeSaying(state.scene, 'lecturas <- lecturas + 1');
      await _pump(tester, state, size: viewport);
      final restingScale = _currentScale(tester);

      await _pump(
        tester,
        state,
        size: viewport,
        followsExecutionFocus: true,
        focus: _focusOn(target.nodeId!),
      );

      final centre = _nodeCentreOnScreen(tester, state.scene, target, viewport);
      expect(centre.dx, closeTo(viewport.width / 2, 1.0));
      expect(centre.dy, closeTo(viewport.height / 2, 1.0));
      expect(_currentScale(tester), greaterThan(restingScale));
    });

    testWidgets('travels through the diagram instead of appearing on the step',
        (tester) async {
      final state = _stateOf(_tallProgram);
      final first = _nodeSaying(state.scene, 'temperatura <- 30');
      final last = _nodeSaying(state.scene, 'Confort');
      await _pump(
        tester,
        state,
        size: viewport,
        followsExecutionFocus: true,
        focus: _focusOn(first.nodeId!),
      );
      final departure = _currentMatrix(tester).clone();

      await _pump(
        tester,
        state,
        size: viewport,
        followsExecutionFocus: true,
        focus: _focusOn(last.nodeId!),
        settles: false,
      );
      await tester.pump(half);
      final midway = _currentMatrix(tester).clone();
      await tester.pumpAndSettle();
      final arrival = _currentMatrix(tester).clone();

      expect(midway, isNot(equals(departure)));
      expect(midway, isNot(equals(arrival)));
      expect(
        midway.getTranslation().y,
        inExclusiveRange(
          arrival.getTranslation().y,
          departure.getTranslation().y,
        ),
      );
    });

    testWidgets('a step arriving mid-travel carries on from where it is',
        (tester) async {
      final state = _stateOf(_tallProgram);
      final first = _nodeSaying(state.scene, 'temperatura <- 30');
      final middle = _nodeSaying(state.scene, 'lecturas <- lecturas + 1');
      final last = _nodeSaying(state.scene, 'Confort');
      await _pump(
        tester,
        state,
        size: viewport,
        followsExecutionFocus: true,
        focus: _focusOn(first.nodeId!),
      );
      final departure = _currentMatrix(tester).getTranslation().y;

      await _pump(
        tester,
        state,
        size: viewport,
        followsExecutionFocus: true,
        focus: _focusOn(last.nodeId!),
        settles: false,
      );
      await tester.pump(half);
      final interrupted = _currentMatrix(tester).getTranslation().y;

      await _pump(
        tester,
        state,
        size: viewport,
        followsExecutionFocus: true,
        focus: _focusOn(middle.nodeId!),
        settles: false,
      );
      final resumed = _currentMatrix(tester).getTranslation().y;

      expect(resumed, closeTo(interrupted, 20.0));
      expect((resumed - departure).abs(), greaterThan(20.0));
    });

    testWidgets('a hand on the canvas takes the camera off the rails',
        (tester) async {
      final state = _stateOf(_tallProgram);
      final first = _nodeSaying(state.scene, 'temperatura <- 30');
      final last = _nodeSaying(state.scene, 'Confort');
      await _pump(
        tester,
        state,
        size: viewport,
        followsExecutionFocus: true,
        focus: _focusOn(first.nodeId!),
      );

      await _pump(
        tester,
        state,
        size: viewport,
        followsExecutionFocus: true,
        focus: _focusOn(last.nodeId!),
        settles: false,
      );
      await tester.pump(half);
      await tester.drag(find.byType(InteractiveViewer), const Offset(0, -60));
      await tester.pumpAndSettle();

      final centre = _nodeCentreOnScreen(tester, state.scene, last, viewport);
      expect((centre.dy - viewport.height / 2).abs(), greaterThan(10.0));
    });

    testWidgets('pulls back to the whole diagram when the execution ends',
        (tester) async {
      final state = _stateOf(_tallProgram);
      final target = _nodeSaying(state.scene, 'Confort');
      await _pump(
        tester,
        state,
        size: viewport,
        followsExecutionFocus: true,
        focus: _focusOn(target.nodeId!),
      );
      final whileRunning = _currentScale(tester);

      await _pump(
        tester,
        state,
        size: viewport,
        followsExecutionFocus: true,
      );

      final fitted = FlowchartViewport(scene: state.scene, viewport: viewport)
          .fitMatrix()
          .getMaxScaleOnAxis();
      expect(_currentScale(tester), closeTo(fitted, 0.001));
      expect(_currentScale(tester), lessThan(whileRunning));
    });

    testWidgets('arrives already framed when the notation changes',
        (tester) async {
      final flowchartState = _stateOf(_tallProgram);
      final structogramState =
          _stateOf(_tallProgram, notation: DiagramNotation.structogram);
      final symbol = _nodeSaying(flowchartState.scene, 'Confort');
      final cell = _nodeSaying(structogramState.scene, 'Confort');
      await _pump(
        tester,
        flowchartState,
        size: viewport,
        followsExecutionFocus: true,
        focus: _focusOn(symbol.nodeId!),
      );

      await _pump(
        tester,
        structogramState,
        size: viewport,
        followsExecutionFocus: true,
        focus: _focusOn(cell.nodeId!),
        settles: false,
      );

      final framed = FlowchartViewport(
        scene: structogramState.scene,
        viewport: viewport,
      ).matrixForFrame(
        DiagramFocusFrame(
          x: cell.x,
          y: cell.y,
          width: cell.width,
          height: cell.height,
        ),
      );
      expect(_currentMatrix(tester), equals(framed));
    });

    testWidgets('does not move for a step that stays on the same block',
        (tester) async {
      final state = _stateOf(_tallProgram);
      final header = _nodeSaying(state.scene, 'temperatura > 24');
      await _pump(
        tester,
        state,
        size: viewport,
        followsExecutionFocus: true,
        focus: _focusOn(header.nodeId!),
      );
      final settled = _currentMatrix(tester).clone();

      await _pump(
        tester,
        state,
        size: viewport,
        followsExecutionFocus: true,
        focus: _focusOn(header.nodeId!),
        settles: false,
      );
      await tester.pump(half);

      expect(_currentMatrix(tester), equals(settled));
    });
  });

  group('canvas', () {
    testWidgets('renders the scene when the program is valid', (tester) async {
      await _pump(tester, _stateOf(_wideProgram));
      expect(find.byType(InteractiveViewer), findsOneWidget);
      expect(
        find.text(
          'El ordinograma estará disponible cuando el código no tenga errores.',
        ),
        findsNothing,
      );
    });

    testWidgets('zooming in past the top stays at the top', (tester) async {
      await _pump(tester, _stateOf(_wideProgram));
      await _tapControl(tester, Icons.zoom_in, times: 12);
      expect(
        _currentScale(tester),
        closeTo(ComponentMetricsTokens.flowCanvasZoomMax, 0.001),
      );
    });

    testWidgets('zooming out past the bottom stays at the bottom', (
      tester,
    ) async {
      await _pump(tester, _stateOf(_wideProgram));
      await _tapControl(tester, Icons.zoom_out, times: 12);
      expect(
        _currentScale(tester),
        closeTo(ComponentMetricsTokens.flowCanvasZoomMin, 0.001),
      );
    });

    testWidgets('a diagram wider than the window fits entirely after reframing',
        (tester) async {
      final scene = _programOf(_wideProgram).sceneFor(null);
      const viewport = Size(400, 700);
      await _pump(
        tester,
        _stateOf(_wideProgram),
        size: viewport,
      );
      expect(scene.width, greaterThan(viewport.width));

      await _tapControl(tester, Icons.center_focus_strong);
      final scale = _currentScale(tester);

      expect(scale, lessThan(1.0));
      expect(scene.width * scale, lessThanOrEqualTo(viewport.width + 0.001));
      expect(scene.height * scale, lessThanOrEqualTo(viewport.height + 0.001));
    });

    testWidgets(
        'reframing a diagram smaller than the window does not shrink it', (
      tester,
    ) async {
      await _pump(
        tester,
        _stateOf('Proceso P\nFinProceso\n'),
        size: const Size(1200, 900),
      );
      await _tapControl(tester, Icons.center_focus_strong);
      expect(_currentScale(tester), closeTo(1.0, 0.001));
    });

    testWidgets(
      'a diagram taller than twice the window fits entirely, below the static zoom floor',
      (tester) async {
        final scene = _programOf(_wideProgram).sceneFor(null);
        const tinyViewport = Size(400, 120);
        await _pump(
          tester,
          _stateOf(_wideProgram),
          size: tinyViewport,
        );
        expect(scene.height, greaterThan(tinyViewport.height * 2));

        await _tapControl(tester, Icons.center_focus_strong);
        final scale = _currentScale(tester);

        expect(scale, lessThan(ComponentMetricsTokens.flowCanvasZoomMin));
        expect(
          scene.width * scale,
          lessThanOrEqualTo(tinyViewport.width + 0.001),
        );
        expect(
          scene.height * scale,
          lessThanOrEqualTo(tinyViewport.height + 0.001),
        );
      },
    );

    testWidgets(
      'zooming out on a diagram taller than the window goes past the static floor',
      (tester) async {
        const tinyViewport = Size(400, 120);
        await _pump(
          tester,
          _stateOf(_wideProgram),
          size: tinyViewport,
        );

        await _tapControl(tester, Icons.zoom_out, times: 12);
        final scale = _currentScale(tester);

        expect(scale, lessThan(ComponentMetricsTokens.flowCanvasZoomMin));
        expect(
          scale,
          greaterThanOrEqualTo(ComponentMetricsTokens.flowCanvasZoomFloor),
        );
      },
    );

    testWidgets(
        'panning after fitting a tall diagram reaches its bottom-most node', (
      tester,
    ) async {
      final scene = _programOf(_wideProgram).sceneFor(null);
      const tinyViewport = Size(400, 120);
      await _pump(
        tester,
        _stateOf(_wideProgram),
        size: tinyViewport,
      );
      await _tapControl(tester, Icons.center_focus_strong);

      await tester.drag(
        find.byType(InteractiveViewer),
        const Offset(0, -100000),
      );
      await tester.pumpAndSettle();

      final viewer = tester.widget<InteractiveViewer>(
        find.byType(InteractiveViewer),
      );
      final matrix = viewer.transformationController!.value;
      final scale = matrix.getMaxScaleOnAxis();
      final visibleBottom = -matrix.getTranslation().y + tinyViewport.height;

      expect(visibleBottom, greaterThanOrEqualTo(scene.height * scale));
      expect(
        visibleBottom,
        closeTo(
          (scene.height + ComponentMetricsTokens.flowCanvasPanMargin) * scale,
          1.0,
        ),
      );
    });

    testWidgets('a shared panel frames the whole scene as soon as it is laid out',
        (tester) async {
      await _pump(
        tester,
        _stateOf(_wideProgram),
        size: const Size(360, 200),
        framesSceneOnLayout: true,
      );

      expect(_currentScale(tester), lessThan(1.0));
    });

    testWidgets('shrinking the panel refits the scene into what is left',
        (tester) async {
      await _pump(tester, _stateOf(_wideProgram), size: const Size(900, 900));
      final beforeShrink = _currentScale(tester);

      tester.view.physicalSize = const Size(360, 200);
      await tester.pumpAndSettle();

      expect(_currentScale(tester), lessThan(beforeShrink));
    });

    testWidgets('a panel that keeps its size keeps the reader zoom',
        (tester) async {
      await _pump(tester, _stateOf(_wideProgram), size: const Size(900, 900));

      await tester.tap(find.byIcon(Icons.zoom_in));
      await tester.pumpAndSettle();
      final zoomed = _currentScale(tester);

      await tester.pumpAndSettle();

      expect(_currentScale(tester), closeTo(zoomed, 0.001));
    });

    testWidgets(
        'panning at normal scale on a tall diagram reaches its bottom-most node',
        (tester) async {
      final scene = _programOf(_wideProgram).sceneFor(null);
      const tinyViewport = Size(400, 120);
      await _pump(
        tester,
        _stateOf(_wideProgram),
        size: tinyViewport,
      );

      expect(_currentScale(tester), closeTo(1.0, 0.001));
      expect(scene.height, greaterThan(tinyViewport.height * 2));

      await tester.drag(
        find.byType(InteractiveViewer),
        const Offset(0, -100000),
      );
      await tester.pumpAndSettle();

      final viewer = tester.widget<InteractiveViewer>(
        find.byType(InteractiveViewer),
      );
      final matrix = viewer.transformationController!.value;
      final visibleBottom = -matrix.getTranslation().y + tinyViewport.height;

      expect(visibleBottom, greaterThanOrEqualTo(scene.height));
      expect(
        visibleBottom,
        closeTo(scene.height + ComponentMetricsTokens.flowCanvasPanMargin, 1.0),
      );
    });

    testWidgets(
        'panning at normal scale on a wide diagram reaches its right-most edge',
        (tester) async {
      final scene = _programOf(_wideProgram).sceneFor(null);
      const narrowViewport = Size(100, 400);
      await _pump(
        tester,
        _stateOf(_wideProgram),
        size: narrowViewport,
      );

      expect(_currentScale(tester), closeTo(1.0, 0.001));
      expect(scene.width, greaterThan(narrowViewport.width * 2));

      await tester.drag(
        find.byType(InteractiveViewer),
        const Offset(-100000, 0),
      );
      await tester.pumpAndSettle();

      final viewer = tester.widget<InteractiveViewer>(
        find.byType(InteractiveViewer),
      );
      final matrix = viewer.transformationController!.value;
      final visibleRight = -matrix.getTranslation().x + narrowViewport.width;

      expect(visibleRight, greaterThanOrEqualTo(scene.width));
      expect(
        visibleRight,
        closeTo(scene.width + ComponentMetricsTokens.flowCanvasPanMargin, 1.0),
      );
    });
  });
}
