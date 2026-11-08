import '../../../domain/model/agent/flowchart.dart';

final class MermaidGraphBuilder {
  final Map<String, FlowchartNode> _nodes = {};
  final List<FlowchartEdge> _edges = [];

  bool get isEmpty => _nodes.isEmpty;

  void declare(String id, {String? label, FlowchartShape? shape}) {
    final known = _nodes[id];
    if (known != null && label == null) return;
    _nodes[id] = FlowchartNode(
      id: id,
      label: label ?? known?.label ?? id,
      shape: shape ?? known?.shape ?? FlowchartShape.rectangle,
    );
  }

  void connect(FlowchartEdge edge) => _edges.add(edge);

  Flowchart build(FlowchartDirection direction) => Flowchart(
    direction: direction,
    nodes: List.unmodifiable(_nodes.values),
    edges: List.unmodifiable(_edges),
  );
}
