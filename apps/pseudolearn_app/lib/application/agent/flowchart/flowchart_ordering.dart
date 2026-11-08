import 'flowchart_layering.dart';

const int _sweeps = 4;

List<List<String>> orderedLayers(LayeredGraph graph) {
  final layers = [for (final layer in graph.layers) List.of(layer)];
  for (var sweep = 0; sweep < _sweeps; sweep += 1) {
    for (var rank = 1; rank < layers.length; rank += 1) {
      layers[rank] = _byBarycenter(layers[rank], layers[rank - 1], graph.predecessors);
    }
    for (var rank = layers.length - 2; rank >= 0; rank -= 1) {
      layers[rank] = _byBarycenter(layers[rank], layers[rank + 1], graph.successors);
    }
  }
  return layers;
}

List<String> _byBarycenter(
  List<String> layer,
  List<String> reference,
  Map<String, List<String>> neighbors,
) {
  final positions = {for (final (index, id) in reference.indexed) id: index};
  final keys = <String, double>{};
  final original = <String, int>{};
  for (final (index, id) in layer.indexed) {
    final linked = [for (final neighbor in neighbors[id] ?? const <String>[]) ?positions[neighbor]];
    keys[id] = linked.isEmpty ? index.toDouble() : linked.reduce((a, b) => a + b) / linked.length;
    original[id] = index;
  }
  int compare(String a, String b) {
    final byKey = keys[a]!.compareTo(keys[b]!);
    return byKey != 0 ? byKey : original[a]!.compareTo(original[b]!);
  }
  return List.of(layer)..sort(compare);
}
