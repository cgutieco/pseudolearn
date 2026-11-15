import '../../../domain/model/agent/flowchart.dart';

final class LayerChain {
  final int edgeIndex;
  final List<String> path;
  final bool reversed;

  const LayerChain({required this.edgeIndex, required this.path, required this.reversed});
}

final class LayeredGraph {
  final List<List<String>> layers;
  final Map<String, List<String>> predecessors;
  final Map<String, List<String>> successors;
  final List<LayerChain> chains;

  const LayeredGraph({
    required this.layers,
    required this.predecessors,
    required this.successors,
    required this.chains,
  });
}

final class _OrientedEdge {
  final int index;
  final String from;
  final String to;
  final bool reversed;

  const _OrientedEdge(this.index, this.from, this.to, {required this.reversed});
}

LayeredGraph layeredGraphOf(Flowchart chart) {
  final ids = [for (final node in chart.nodes) node.id];
  final oriented = _orientedEdges(chart.edges, ids);
  final ranks = _settledRanks(ids, oriented);
  final layerCount = ranks.values.fold(0, (highest, rank) => rank > highest ? rank : highest) + 1;
  final layers = List.generate(layerCount, (_) => <String>[]);
  for (final id in ids) {
    layers[ranks[id]!].add(id);
  }
  final graph = LayeredGraph(layers: layers, predecessors: {}, successors: {}, chains: []);
  for (final edge in oriented) {
    _chain(graph, edge, ranks);
  }
  return graph;
}

List<_OrientedEdge> _orientedEdges(List<FlowchartEdge> edges, List<String> ids) {
  final known = ids.toSet();
  final back = _backEdges(edges, ids);
  return [
    for (final (index, edge) in edges.indexed)
      if (edge.from != edge.to && known.contains(edge.from) && known.contains(edge.to))
        back.contains(index)
            ? _OrientedEdge(index, edge.to, edge.from, reversed: true)
            : _OrientedEdge(index, edge.from, edge.to, reversed: false),
  ];
}

Set<int> _backEdges(List<FlowchartEdge> edges, List<String> ids) {
  final outgoing = <String, List<int>>{};
  for (final (index, edge) in edges.indexed) {
    if (edge.from != edge.to) outgoing.putIfAbsent(edge.from, () => []).add(index);
  }
  final visiting = <String>{};
  final finished = <String>{};
  final back = <int>{};
  void visit(String id) {
    visiting.add(id);
    for (final index in outgoing[id] ?? const <int>[]) {
      final next = edges[index].to;
      if (visiting.contains(next)) {
        back.add(index);
      } else if (!finished.contains(next)) {
        visit(next);
      }
    }
    visiting.remove(id);
    finished.add(id);
  }
  for (final id in ids) {
    if (!finished.contains(id)) visit(id);
  }
  return back;
}

Map<String, int> _settledRanks(List<String> ids, List<_OrientedEdge> edges) {
  final order = _topologicalOrder(ids, edges);
  final ranks = {for (final id in ids) id: 0};
  for (final id in order) {
    for (final edge in edges.where((edge) => edge.from == id)) {
      final candidate = ranks[id]! + 1;
      if (candidate > ranks[edge.to]!) ranks[edge.to] = candidate;
    }
  }
  for (final id in order.reversed) {
    final hasIncoming = edges.any((edge) => edge.to == id);
    final targets = [for (final edge in edges) if (edge.from == id) ranks[edge.to]!];
    if (!hasIncoming && targets.isNotEmpty) ranks[id] = targets.reduce((a, b) => a < b ? a : b) - 1;
  }
  return ranks;
}

List<String> _topologicalOrder(List<String> ids, List<_OrientedEdge> edges) {
  final incoming = {for (final id in ids) id: 0};
  for (final edge in edges) {
    incoming[edge.to] = incoming[edge.to]! + 1;
  }
  final ready = [for (final id in ids) if (incoming[id] == 0) id];
  final order = <String>[];
  while (ready.isNotEmpty) {
    final id = ready.removeAt(0);
    order.add(id);
    for (final edge in edges.where((edge) => edge.from == id)) {
      incoming[edge.to] = incoming[edge.to]! - 1;
      if (incoming[edge.to] == 0) ready.add(edge.to);
    }
  }
  return order;
}

void _chain(LayeredGraph graph, _OrientedEdge edge, Map<String, int> ranks) {
  final path = <String>[edge.from];
  for (var rank = ranks[edge.from]! + 1; rank < ranks[edge.to]!; rank += 1) {
    final dummy = '\u0000${edge.index}:$rank';
    graph.layers[rank].add(dummy);
    path.add(dummy);
  }
  path.add(edge.to);
  for (var step = 1; step < path.length; step += 1) {
    graph.successors.putIfAbsent(path[step - 1], () => []).add(path[step]);
    graph.predecessors.putIfAbsent(path[step], () => []).add(path[step - 1]);
  }
  graph.chains.add(LayerChain(edgeIndex: edge.index, path: path, reversed: edge.reversed));
}

bool isDummyNode(String id) => id.startsWith('\u0000');
