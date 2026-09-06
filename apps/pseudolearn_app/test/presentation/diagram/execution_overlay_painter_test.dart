import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/analysis/program_node_id.dart';
import 'package:pseudolearn_app/domain/model/analysis/source_range.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_scene.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_focus.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/diagram/flowchart_layout.dart';
import 'package:pseudolearn_app/presentation/diagram/execution_overlay_painter.dart';
import 'package:pseudolearn_app/presentation/diagram/flowchart_painter.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/color_semantic.dart';

const String _source = 'Proceso P\na <- 1;\nb <- 2;\nFinProceso\n';

DiagramScene _scene() => FlowchartLayout()
    .buildDiagram(
      sourceCode: _source,
      profileId: SyntaxProfileId.classicSpanish,
      languageId: UiLanguageId.spanish,
    )
    .sceneFor(null);

AppSemanticColors _colors() => const AppThemeExtension.light().colors;

ExecutionFocus _focusOn(ProgramNodeId nodeId) => ExecutionFocus(
      nodeId: nodeId,
      range: const SourceRange(
        startOffset: 0,
        endOffset: 5,
        startLine: 2,
        startColumn: 1,
        endLine: 2,
        endColumn: 6,
      ),
      kind: ExecutionFocusKind.statement,
    );

ProgramNodeId _firstStatementNode(DiagramScene scene) {
  for (final node in scene.nodes) {
    if (node.nodeId != null) return node.nodeId!;
  }
  throw StateError('the scene carries no program node identity');
}

void main() {
  group('ExecutionOverlayPainter', () {
    test('every statement symbol carries its program node identity', () {
      final scene = _scene();
      expect(_firstStatementNode(scene), isNotNull);
    });

    test('repaints when the focus moves to another node', () {
      final scene = _scene();
      final colors = _colors();
      final previous = ExecutionOverlayPainter(scene: scene, focus: _focusOn(const ProgramNodeId(1)), colors: colors);
      final next = ExecutionOverlayPainter(scene: scene, focus: _focusOn(const ProgramNodeId(2)), colors: colors);
      expect(next.shouldRepaint(previous), isTrue);
    });

    test('does not repaint when nothing changed', () {
      final scene = _scene();
      final colors = _colors();
      final focus = _focusOn(const ProgramNodeId(1));
      final previous = ExecutionOverlayPainter(scene: scene, focus: focus, colors: colors);
      final next = ExecutionOverlayPainter(scene: scene, focus: focus, colors: colors);
      expect(next.shouldRepaint(previous), isFalse);
    });

    test('no focus means nothing to repaint against', () {
      final scene = _scene();
      final colors = _colors();
      final previous = ExecutionOverlayPainter(scene: scene, focus: null, colors: colors);
      final next = ExecutionOverlayPainter(scene: scene, focus: null, colors: colors);
      expect(next.shouldRepaint(previous), isFalse);
    });

    test('the structure layer ignores a change of focus', () {
      final scene = _scene();
      final colors = _colors();
      final previous = FlowchartPainter(scene: scene, colors: colors);
      final next = FlowchartPainter(scene: scene, colors: colors);
      expect(next.shouldRepaint(previous), isFalse);
    });

    test('paints highlight over the exact active node', () {
      final scene = _scene();
      final colors = _colors();
      final focus = _focusOn(_firstStatementNode(scene));
      final painter = ExecutionOverlayPainter(scene: scene, focus: focus, colors: colors);
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      painter.paint(canvas, const Size(800, 600));
      expect(recorder.endRecording(), isNotNull);
    });
  });
}
