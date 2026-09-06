import 'dart:math' as math;

import '../../domain/model/diagram/diagram_metrics.dart';
import '../../domain/model/diagram/diagram_scene.dart';
import 'layout_block.dart';

final class PostTestLoopBlock {
  const PostTestLoopBlock._();

  static LayoutBlock compose({
    required DiagramNode decision,
    required LayoutBlock body,
    required DiagramNode entryConnector,
    required String? enterLabel,
    required String? exitLabel,
  }) {
    final spine = DiagramMetrics.gapHorizontal + math.max(decision.width / 2, body.spineX);
    final bodyTop = entryConnector.height + DiagramMetrics.gapVertical;
    final placedBody = body.translate(spine - body.spineX, bodyTop);
    final decisionY = bodyTop + body.height + DiagramMetrics.gapVertical;
    return _assemble(
      decision: decision.shifted(spine - decision.width / 2, decisionY),
      body: placedBody,
      connector: entryConnector.shifted(spine - entryConnector.width / 2, 0.0),
      spine: spine,
      bodyTop: bodyTop,
      contentRight: math.max(spine + decision.width / 2, placedBody.spineX + body.width),
      enterLabel: enterLabel,
      exitLabel: exitLabel,
    );
  }

  static LayoutBlock _assemble({
    required DiagramNode decision,
    required LayoutBlock body,
    required DiagramNode connector,
    required double spine,
    required double bodyTop,
    required double contentRight,
    required String? enterLabel,
    required String? exitLabel,
  }) {
    final stubBottom = decision.y + decision.height + DiagramMetrics.gapVertical;
    return LayoutBlock(
      nodes: [connector, ...body.nodes, decision],
      edges: [
        ...body.edges,
        _connectorToBody(connector: connector, body: body, bodyTop: bodyTop, spine: spine),
        if (body.hasExit && body.exitId != null)
          _bodyToDecision(body: body, decision: decision, bodyTop: bodyTop, spine: spine),
        _backEdge(decision: decision, connector: connector, label: enterLabel),
        _exitStub(decision: decision, stubBottom: stubBottom, spine: spine, label: exitLabel),
      ],
      width: contentRight + DiagramMetrics.gapHorizontal,
      height: stubBottom,
      spineX: spine,
      hasExit: true,
      entryId: connector.id,
      exitId: decision.id,
    );
  }

  static DiagramEdge _connectorToBody({
    required DiagramNode connector,
    required LayoutBlock body,
    required double bodyTop,
    required double spine,
  }) {
    return DiagramEdge(
      fromId: connector.id,
      toId: body.entryId ?? connector.id,
      points: [
        DiagramPoint(spine, connector.height),
        DiagramPoint(spine, bodyTop),
      ],
    );
  }

  static DiagramEdge _bodyToDecision({
    required LayoutBlock body,
    required DiagramNode decision,
    required double bodyTop,
    required double spine,
  }) {
    return DiagramEdge(
      fromId: body.exitId!,
      toId: decision.id,
      points: [
        DiagramPoint(spine, bodyTop + body.height),
        DiagramPoint(spine, decision.y),
      ],
    );
  }

  static DiagramEdge _backEdge({
    required DiagramNode decision,
    required DiagramNode connector,
    required String? label,
  }) {
    const laneX = DiagramMetrics.gapHorizontal / 2;
    final portY = decision.y + decision.height / 2;
    final connectorCenterY = connector.y + connector.height / 2;
    return DiagramEdge(
      fromId: decision.id,
      toId: connector.id,
      label: label,
      kind: DiagramEdgeKind.loopBack,
      labelAnchor: DiagramPoint((decision.x + laneX) / 2, portY - DiagramMetrics.edgeLabelGap),
      points: [
        DiagramPoint(decision.x, portY),
        DiagramPoint(laneX, portY),
        DiagramPoint(laneX, connectorCenterY),
        DiagramPoint(connector.x, connectorCenterY),
      ],
    );
  }

  static DiagramEdge _exitStub({
    required DiagramNode decision,
    required double stubBottom,
    required double spine,
    required String? label,
  }) {
    final top = decision.y + decision.height;
    return DiagramEdge(
      fromId: decision.id,
      toId: decision.id,
      label: label,
      kind: DiagramEdgeKind.branchTrue,
      labelAnchor: DiagramPoint(spine + DiagramMetrics.edgeLabelGap, (top + stubBottom) / 2),
      points: [DiagramPoint(spine, top), DiagramPoint(spine, stubBottom)],
    );
  }
}
