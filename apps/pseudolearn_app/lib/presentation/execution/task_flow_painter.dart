import 'package:flutter/material.dart';
import '../../domain/model/execution/task_flow_scene.dart';
import '../theme/tokens/color_semantic.dart';

final class TaskFlowPainter extends CustomPainter {
  final TaskFlowScene scene;
  final AppSemanticColors colors;

  const TaskFlowPainter({required this.scene, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    _paintLanes(canvas);
    for (final connector in scene.connectors) {
      _paintConnector(canvas, connector);
    }
  }

  @override
  bool shouldRepaint(covariant TaskFlowPainter oldDelegate) =>
      oldDelegate.scene != scene || oldDelegate.colors != colors;

  void _paintLanes(Canvas canvas) {
    final paint = Paint()
      ..color = colors.borders.subtle
      ..strokeWidth = 1;
    for (final lane in scene.lanes) {
      canvas.drawLine(
        Offset(100, lane.y),
        Offset(scene.width - 16, lane.y),
        paint,
      );
    }
  }

  void _paintConnector(Canvas canvas, TaskFlowConnector connector) {
    final isCreation = connector.targetKind == 'creation';
    final paint = Paint()
      ..color = isCreation ? colors.borders.strong : colors.text.link
      ..strokeWidth = 2;
    if (isCreation) {
      canvas.drawLine(
        Offset(connector.startX, connector.startY),
        Offset(connector.endX, connector.endY),
        paint,
      );
      return;
    }
    _paintDashedConnector(canvas, connector, paint);
  }

  void _paintDashedConnector(
    Canvas canvas,
    TaskFlowConnector connector,
    Paint paint,
  ) {
    final top = connector.startY < connector.endY
        ? connector.startY
        : connector.endY;
    final bottom = connector.startY < connector.endY
        ? connector.endY
        : connector.startY;
    for (var y = top; y < bottom; y += 8) {
      canvas.drawLine(
        Offset(connector.startX, y),
        Offset(connector.endX, (y + 4).clamp(top, bottom).toDouble()),
        paint,
      );
    }
  }
}
