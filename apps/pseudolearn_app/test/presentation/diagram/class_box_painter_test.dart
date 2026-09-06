import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/diagram/diagram_state.dart';
import 'package:pseudolearn_app/domain/model/analysis/program_node_id.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_notation.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_program.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_scene.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/classdiagram/core_class_diagram_builder.dart';
import 'package:pseudolearn_app/engine/diagram/flowchart_layout.dart';
import 'package:pseudolearn_app/engine/structogram/structogram_layout.dart';
import 'package:pseudolearn_app/presentation/diagram/class_box_painter.dart';
import 'package:pseudolearn_app/presentation/diagram/class_execution_overlay_painter.dart';
import 'package:pseudolearn_app/presentation/diagram/flowchart_painter.dart';
import 'package:pseudolearn_app/presentation/diagram/flowchart_tab_view.dart';
import 'package:pseudolearn_app/presentation/diagram/structogram_painter.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

const String _vehicles = '''
Clase Vehiculo
    Publico Definir marca Como Cadena
    Privado Definir velocidad Como Entero

    Publico Metodo Acelerar(delta Como Entero)
        Este.velocidad <- Este.velocidad + delta
    FinMetodo
FinClase

Clase Motocicleta Hereda De Vehiculo
    Publico Definir cilindrada Como Entero
FinClase

Proceso Principal
    Definir moto Como Motocicleta
    Escribir 1
FinProceso
''';

const String _noClasses = '''
Proceso Principal
    Definir n Como Entero
    Escribir n
FinProceso
''';

DiagramScene _classSceneOf(String source) =>
    CoreClassDiagramBuilder().buildDiagram(
      sourceCode: source,
      profileId: SyntaxProfileId.classicSpanish,
    );

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
  DiagramNotation notation = DiagramNotation.classDiagram,
  ProgramNodeId? focusedMemberNodeId,
}) =>
    DiagramState(
      flowchart: _flowchartOf(source),
      structogram: _structogramOf(source),
      classDiagram: _classSceneOf(source),
      notation: notation,
      focusedMemberNodeId: focusedMemberNodeId,
      hasValidAst: true,
    );

ProgramNodeId _rowIdSaying(DiagramScene scene, String text) {
  for (final node in scene.nodes) {
    if (node.shape != DiagramShape.classRow) continue;
    if (node.lines.first.contains(text) && node.nodeId != null) {
      return node.nodeId!;
    }
  }
  throw StateError('no row says $text');
}

Future<void> _pump(
  WidgetTester tester,
  DiagramState state, {
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
      home: Scaffold(body: DesignCanvas(child: FlowchartTabView(state: state))),
    ),
  );
  await tester.pumpAndSettle();
}

CustomPainter _structurePainter(WidgetTester tester) {
  final painters = tester.widgetList<CustomPaint>(find.byType(CustomPaint));
  for (final paint in painters) {
    final painter = paint.painter;
    if (painter is FlowchartPainter ||
        painter is StructogramPainter ||
        painter is ClassBoxPainter) {
      return painter!;
    }
  }
  throw StateError('no structure painter in the tree');
}

void main() {
  final colors = AppTheme.light().extension<AppThemeExtension>()!.colors;

  group('the notation switch with three options', () {
    testWidgets('offers the class diagram and draws it', (tester) async {
      await _pump(tester, _stateOf(_vehicles));

      expect(find.text('Ordinograma'), findsOneWidget);
      expect(find.text('Estructograma'), findsOneWidget);
      expect(find.text('Diagrama de clases'), findsOneWidget);
      expect(_structurePainter(tester), isA<ClassBoxPainter>());
    });

    testWidgets('hides the unit selector in the class diagram', (tester) async {
      await _pump(tester, _stateOf(_vehicles));

      expect(find.text('Algoritmo Principal'), findsNothing);
    });
  });

  group('the empty state of the class diagram', () {
    testWidgets('says the document declares no class', (tester) async {
      await _pump(tester, _stateOf(_noClasses));

      expect(find.text('Este documento no declara ninguna clase.'),
          findsOneWidget);
    });

    testWidgets('says the code has errors when there is no ast',
        (tester) async {
      await _pump(
        tester,
        const DiagramState(
          flowchart: DiagramProgram.empty(),
          structogram: DiagramProgram.empty(),
          classDiagram: DiagramScene.empty(),
          notation: DiagramNotation.classDiagram,
          hasValidAst: false,
        ),
      );

      expect(
        find.text(
          'El diagrama de clases estará disponible cuando el código no tenga errores.',
        ),
        findsOneWidget,
      );
    });
  });

  group('the class structure layer', () {
    test('ignores a change of execution step', () {
      final scene = _classSceneOf(_vehicles);
      final painter = ClassBoxPainter(scene: scene, colors: colors);

      expect(
        painter.shouldRepaint(ClassBoxPainter(scene: scene, colors: colors)),
        isFalse,
      );
    });

    test('repaints when the scene changes', () {
      final painter = ClassBoxPainter(
        scene: _classSceneOf(_vehicles),
        colors: colors,
      );

      expect(
        painter.shouldRepaint(
          ClassBoxPainter(scene: const DiagramScene.empty(), colors: colors),
        ),
        isTrue,
      );
    });
  });

  group('the class highlight layer', () {
    test('repaints when the member in execution changes', () {
      final scene = _classSceneOf(_vehicles);
      final painter = ClassExecutionOverlayPainter(
        scene: scene,
        memberNodeId: _rowIdSaying(scene, 'Acelerar'),
        colors: colors,
      );

      expect(
        painter.shouldRepaint(ClassExecutionOverlayPainter(
          scene: scene,
          memberNodeId: null,
          colors: colors,
        )),
        isTrue,
      );
    });

    test('does not repaint over the same member and the same scene', () {
      final scene = _classSceneOf(_vehicles);
      final member = _rowIdSaying(scene, 'Acelerar');
      final painter = ClassExecutionOverlayPainter(
        scene: scene,
        memberNodeId: member,
        colors: colors,
      );

      expect(
        painter.shouldRepaint(ClassExecutionOverlayPainter(
          scene: scene,
          memberNodeId: member,
          colors: colors,
        )),
        isFalse,
      );
    });

    testWidgets('paints the highlight of a method without failing',
        (tester) async {
      final scene = _classSceneOf(_vehicles);

      await _pump(
        tester,
        _stateOf(
          _vehicles,
          focusedMemberNodeId: _rowIdSaying(scene, 'Acelerar'),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    test('paints frame and member highlight without errors', () {
      final scene = _classSceneOf(_vehicles);
      final member = _rowIdSaying(scene, 'Acelerar');
      final painter = ClassExecutionOverlayPainter(
        scene: scene,
        memberNodeId: member,
        colors: colors,
      );
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      painter.paint(canvas, const Size(800, 600));
      expect(recorder.endRecording(), isNotNull);
    });
  });
}
