import 'package:flutter/material.dart';
import '../../domain/model/analysis/program_node_id.dart';
import '../../domain/model/diagram/diagram_scene.dart';
import '../theme/tokens/color_semantic.dart';
import '../theme/tokens/editor_metrics.dart';

final class ClassExecutionOverlayPainter extends CustomPainter {
  final DiagramScene scene;
  final ProgramNodeId? memberNodeId;
  final AppSemanticColors colors;

  const ClassExecutionOverlayPainter({
    required this.scene,
    required this.memberNodeId,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final member = memberNodeId;
    if (member == null) return;
    final row = _rowOf(member);
    if (row == null) return;
    canvas.drawRect(row, _rowFill);
    final frame = _frameContaining(row);
    if (frame != null) canvas.drawRect(frame, _highlight);
  }

  @override
  bool shouldRepaint(covariant ClassExecutionOverlayPainter oldDelegate) {
    return oldDelegate.memberNodeId != memberNodeId ||
        oldDelegate.scene != scene ||
        oldDelegate.colors != colors;
  }

  Paint get _highlight => Paint()
    ..color = colors.borders.focus
    ..style = PaintingStyle.stroke
    ..strokeWidth = EditorMetricsTokens.flowExecutionActiveBorderWidth;

  Paint get _rowFill => Paint()..color = colors.borders.focus.withAlpha(48);

  Rect? _rowOf(ProgramNodeId member) {
    for (final node in scene.nodes) {
      if (node.shape != DiagramShape.classRow) continue;
      if (node.nodeId != member) continue;
      return _rectOf(node);
    }
    return null;
  }

  Rect? _frameContaining(Rect row) {
    for (final node in scene.nodes) {
      if (node.shape != DiagramShape.classFrame) continue;
      final frame = _rectOf(node);
      if (!frame.contains(row.center)) continue;
      return frame;
    }
    return null;
  }

  Rect _rectOf(DiagramNode node) =>
      Rect.fromLTWH(node.x, node.y, node.width, node.height);
}
