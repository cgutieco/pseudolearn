import 'dart:math' as math;

import '../../domain/model/diagram/diagram_metrics.dart';
import '../../domain/model/diagram/diagram_scene.dart';
import 'layout_block.dart';

final class PreTestLoopBlock {
  const PreTestLoopBlock._();

  static LayoutBlock compose({
    required DiagramNode header,
    required LayoutBlock body,
    required DiagramNode junction,
    required String? enterLabel,
    required String? exitLabel,
  }) {
    final spine = DiagramMetrics.gapHorizontal + math.max(header.width / 2, body.spineX);
    final bodyTop = header.height + DiagramMetrics.gapVertical;
    final placedBody = body.translate(spine - body.spineX, bodyTop);
    final bodyBottom = bodyTop + body.height;
    final laneX = math.max(spine + header.width / 2, placedBody.spineX + body.width) +
        DiagramMetrics.gapHorizontal;
    final junctionCenterY = bodyBottom + DiagramMetrics.gapVertical + junction.height / 2;
    return _assemble(
      header: header.shifted(spine - header.width / 2, 0.0),
      body: placedBody,
      junction: junction.shifted(spine - junction.width / 2, junctionCenterY - junction.height / 2),
      spine: spine,
      bodyTop: bodyTop,
      laneX: laneX,
      junctionCenterY: junctionCenterY,
      enterLabel: enterLabel,
      exitLabel: exitLabel,
    );
  }

  static LayoutBlock _assemble({
    required DiagramNode header,
    required LayoutBlock body,
    required DiagramNode junction,
    required double spine,
    required double bodyTop,
    required double laneX,
    required double junctionCenterY,
    required String? enterLabel,
    required String? exitLabel,
  }) {
    return LayoutBlock(
      nodes: [header, ...body.nodes, junction],
      edges: [
        ...body.edges,
        _enterEdge(header: header, body: body, bodyTop: bodyTop, spine: spine, label: enterLabel),
        if (body.hasExit && body.exitId != null)
          _backEdge(header: header, body: body, bodyBottom: bodyTop + body.height, spine: spine),
        _exitEdge(
          header: header,
          junction: junction,
          laneX: laneX,
          junctionCenterY: junctionCenterY,
          spine: spine,
          label: exitLabel,
        ),
      ],
      width: laneX + DiagramMetrics.gapHorizontal,
      height: junction.y + junction.height,
      spineX: spine,
      hasExit: true,
      entryId: header.id,
      exitId: junction.id,
    );
  }

  static DiagramEdge _enterEdge({
    required DiagramNode header,
    required LayoutBlock body,
    required double bodyTop,
    required double spine,
    required String? label,
  }) {
    return DiagramEdge(
      fromId: header.id,
      toId: body.entryId ?? header.id,
      label: label,
      kind: DiagramEdgeKind.branchTrue,
      labelAnchor: DiagramPoint(
        spine + DiagramMetrics.edgeLabelGap,
        (header.height + bodyTop) / 2,
      ),
      points: [DiagramPoint(spine, header.height), DiagramPoint(spine, bodyTop)],
    );
  }

  static DiagramEdge _backEdge({
    required DiagramNode header,
    required LayoutBlock body,
    required double bodyBottom,
    required double spine,
  }) {
    const laneX = DiagramMetrics.gapHorizontal / 2;
    final turnY = bodyBottom + DiagramMetrics.gapVertical / 2;
    final portY = header.y + header.height / 2;
    return DiagramEdge(
      fromId: body.exitId!,
      toId: header.id,
      kind: DiagramEdgeKind.loopBack,
      points: [
        DiagramPoint(spine, bodyBottom),
        DiagramPoint(spine, turnY),
        DiagramPoint(laneX, turnY),
        DiagramPoint(laneX, portY),
        DiagramPoint(header.x, portY),
      ],
    );
  }

  static DiagramEdge _exitEdge({
    required DiagramNode header,
    required DiagramNode junction,
    required double laneX,
    required double junctionCenterY,
    required double spine,
    required String? label,
  }) {
    final portY = header.y + header.height / 2;
    final portX = header.x + header.width;
    return DiagramEdge(
      fromId: header.id,
      toId: junction.id,
      label: label,
      kind: DiagramEdgeKind.branchFalse,
      labelAnchor: DiagramPoint((portX + laneX) / 2, portY - DiagramMetrics.edgeLabelGap),
      points: [
        DiagramPoint(portX, portY),
        DiagramPoint(laneX, portY),
        DiagramPoint(laneX, junctionCenterY),
        DiagramPoint(spine, junctionCenterY),
      ],
    );
  }
}
