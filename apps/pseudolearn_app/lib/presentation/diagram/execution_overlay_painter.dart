import 'package:flutter/material.dart';
import '../../domain/model/diagram/diagram_scene.dart';
import '../../domain/model/execution/execution_branch.dart';
import '../../domain/model/execution/execution_focus.dart';
import '../theme/tokens/color_semantic.dart';
import '../theme/tokens/editor_metrics.dart';
import 'flowchart_shapes.dart';

final class ExecutionOverlayPainter extends CustomPainter {
  final DiagramScene scene;
  final ExecutionFocus? focus;
  final AppSemanticColors colors;

  const ExecutionOverlayPainter({
    required this.scene,
    required this.focus,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final active = focus;
    if (active == null) return;

    final highlight = Paint()
      ..color = colors.borders.focus
      ..style = PaintingStyle.stroke
      ..strokeWidth = EditorMetricsTokens.flowExecutionActiveBorderWidth;

    for (final node in scene.nodes) {
      if (node.nodeId != active.nodeId) continue;
      canvas.drawPath(
        FlowchartShapes.outlineOf(node.shape, _rectOf(node)),
        highlight,
      );
      _paintTakenEdge(canvas, nodeId: node.id, branch: active.branch, stroke: highlight);
    }
  }

  @override
  bool shouldRepaint(covariant ExecutionOverlayPainter oldDelegate) {
    return oldDelegate.focus != focus ||
        oldDelegate.scene != scene ||
        oldDelegate.colors != colors;
  }

  void _paintTakenEdge(
    Canvas canvas, {
    required String nodeId,
    required ExecutionBranch? branch,
    required Paint stroke,
  }) {
    if (branch == null) return;
    final edge = _takenEdge(nodeId, branch);
    if (edge == null || edge.points.length < 2) return;
    final path = Path()..moveTo(edge.points.first.x, edge.points.first.y);
    for (var index = 1; index < edge.points.length; index++) {
      path.lineTo(edge.points[index].x, edge.points[index].y);
    }
    canvas.drawPath(path, stroke);
  }

  DiagramEdge? _takenEdge(String nodeId, ExecutionBranch branch) {
    var caseOrdinal = 0;
    DiagramEdge? lastCase;
    for (final edge in scene.edges) {
      if (edge.fromId != nodeId) continue;
      if (_isMatch(edge, branch, caseOrdinal)) return edge;
      if (edge.kind == DiagramEdgeKind.branchCase) {
        caseOrdinal++;
        lastCase = edge;
      }
    }
    return branch.kind == ExecutionBranchKind.defaultCase ? lastCase : null;
  }

  bool _isMatch(DiagramEdge edge, ExecutionBranch branch, int caseOrdinal) {
    return switch (branch.kind) {
      ExecutionBranchKind.affirmative => edge.kind == DiagramEdgeKind.branchTrue,
      ExecutionBranchKind.negative => edge.kind != DiagramEdgeKind.branchTrue,
      ExecutionBranchKind.selectedCase =>
        edge.kind == DiagramEdgeKind.branchCase && caseOrdinal == branch.caseIndex,
      ExecutionBranchKind.defaultCase => false,
    };
  }

  Rect _rectOf(DiagramNode node) => Rect.fromLTWH(
        node.x,
        node.y,
        node.width,
        node.height,
      );
}
