import '../../domain/model/analysis/program_node_id.dart';
import '../../domain/model/diagram/diagram_focus_frame.dart';
import '../../domain/model/diagram/diagram_notation.dart';
import '../../domain/model/diagram/diagram_scene.dart';
import '../../domain/model/execution/execution_focus.dart';
import 'diagram_state.dart';

final class FocusFrameProjection {
  const FocusFrameProjection._();

  static DiagramFocusFrame? frameOf({
    required DiagramState state,
    required ExecutionFocus? focus,
  }) {
    return switch (state.notation) {
      DiagramNotation.flowchart || DiagramNotation.structogram =>
        _frameOfNode(state.scene, focus?.nodeId),
      DiagramNotation.classDiagram =>
        _frameOfRow(state.scene, state.focusedMemberNodeId),
    };
  }

  static DiagramFocusFrame? _frameOfNode(
    DiagramScene scene,
    ProgramNodeId? nodeId,
  ) {
    if (nodeId == null) return null;
    for (final node in scene.nodes) {
      if (node.nodeId != nodeId) continue;
      return _frameOf(node);
    }
    return null;
  }

  static DiagramFocusFrame? _frameOfRow(
    DiagramScene scene,
    ProgramNodeId? nodeId,
  ) {
    if (nodeId == null) return null;
    for (final node in scene.nodes) {
      if (node.shape != DiagramShape.classRow) continue;
      if (node.nodeId != nodeId) continue;
      return _frameOf(node);
    }
    return null;
  }

  static DiagramFocusFrame _frameOf(DiagramNode node) => DiagramFocusFrame(
        x: node.x,
        y: node.y,
        width: node.width,
        height: node.height,
      );
}
