import 'package:flutter/material.dart';
import '../../domain/model/diagram/diagram_metrics.dart';
import '../../domain/model/diagram/diagram_scene.dart';
import '../../domain/model/diagram/structogram_metrics.dart';
import '../theme/tokens/color_semantic.dart';
import '../theme/tokens/editor_metrics.dart';
import 'structogram_shapes.dart';
import '../theme/font_role_style.dart';
import '../theme/tokens/typography.dart';

final class StructogramPainter extends CustomPainter {
  final DiagramScene scene;
  final AppSemanticColors colors;

  const StructogramPainter({required this.scene, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    for (final node in scene.nodes) {
      if (node.shape == DiagramShape.cellLabel) continue;
      _paintCell(canvas, node);
    }
    _paintHeaderDividers(canvas);
    for (final node in scene.nodes) {
      _paintText(canvas, node);
    }
  }

  @override
  bool shouldRepaint(covariant StructogramPainter oldDelegate) =>
      oldDelegate.scene != scene || oldDelegate.colors != colors;

  Paint get _border => Paint()
    ..color = colors.borders.strong
    ..strokeWidth = EditorMetricsTokens.flowNodeBorderWidth
    ..style = PaintingStyle.stroke
    ..isAntiAlias = false;

  void _paintCell(Canvas canvas, DiagramNode node) {
    final rect = _rectOf(node);
    canvas.drawRect(rect, Paint()..color = _fillColorOf(node.shape));
    canvas.drawRect(rect, _border);
    for (final decoration
        in StructogramShapes.decorationsOf(node.shape, rect)) {
      canvas.drawPath(decoration, _border);
    }
    if (node.shape != DiagramShape.cellExit) return;
    canvas.drawPath(
      StructogramShapes.exitMarker(rect),
      Paint()..color = colors.borders.strong,
    );
  }

  Color _fillColorOf(DiagramShape shape) => shape == DiagramShape.cellLoopStrip
      ? colors.surfaces.defaultSurface
      : colors.surfaces.raised;

  void _paintHeaderDividers(Canvas canvas) {
    for (var index = 0; index < scene.nodes.length; index++) {
      final node = scene.nodes[index];
      if (!_isBranchHeader(node.shape)) continue;
      final dividers = StructogramShapes.headerDividers(
        _rectOf(node),
        boundaries: _boundariesAfter(index),
        isBinary: node.shape == DiagramShape.cellCondition,
      );
      for (final divider in dividers) {
        canvas.drawPath(divider, _border);
      }
    }
  }

  bool _isBranchHeader(DiagramShape shape) =>
      shape == DiagramShape.cellCondition || shape == DiagramShape.cellCase;

  List<double> _boundariesAfter(int headerIndex) {
    final boundaries = <double>[];
    for (var index = headerIndex + 1; index < scene.nodes.length; index++) {
      if (scene.nodes[index].shape != DiagramShape.cellLabel) break;
      if (index > headerIndex + 1) boundaries.add(scene.nodes[index].x);
    }
    return boundaries;
  }

  void _paintText(Canvas canvas, DiagramNode node) {
    if (node.lines.isEmpty) return;
    final painter = _layoutText(node);
    final box = _textBoxOf(node);
    painter.paint(
      canvas,
      Offset(
        box.center.dx - painter.width / 2,
        box.center.dy - painter.height / 2,
      ),
    );
  }

  TextPainter _layoutText(DiagramNode node) {
    final style = TextStyle(
      color: _textColorOf(node.shape),
      fontSize: DiagramMetrics.fontSize,
      height: DiagramMetrics.lineHeight / DiagramMetrics.fontSize,
      fontWeight: node.shape == DiagramShape.cellLabel
          ? FontWeight.w600
          : FontWeight.w500,
    ).inRole(AppFontRole.ui);
    return TextPainter(
      text: TextSpan(text: node.lines.join('\n'), style: style),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      maxLines: node.lines.length,
      ellipsis: '…',
    )..layout(maxWidth: _textBoxOf(node).width);
  }

  Color _textColorOf(DiagramShape shape) {
    if (shape == DiagramShape.cellEmpty) return colors.text.secondary;
    if (shape == DiagramShape.cellLabel) return colors.text.secondary;
    return colors.text.primary;
  }

  Rect _textBoxOf(DiagramNode node) {
    final rect = _rectOf(node).deflate(StructogramMetrics.cellPadding / 2);
    if (_isBranchHeader(node.shape)) {
      return Rect.fromLTRB(
        rect.left,
        rect.top,
        rect.right,
        rect.bottom - StructogramMetrics.branchLabelBand,
      );
    }
    if (node.shape == DiagramShape.cellExit) {
      return Rect.fromLTRB(
          rect.left, rect.top, rect.right - _exitMarkerWidth, rect.bottom);
    }
    if (node.shape == DiagramShape.cellCall) {
      const bar = StructogramMetrics.callBarInset;
      return Rect.fromLTRB(
          rect.left + bar, rect.top, rect.right - bar, rect.bottom);
    }
    return rect;
  }

  static const double _exitMarkerWidth =
      StructogramMetrics.exitMarkerSize + StructogramMetrics.cellPadding;

  Rect _rectOf(DiagramNode node) =>
      Rect.fromLTWH(node.x, node.y, node.width, node.height);
}
