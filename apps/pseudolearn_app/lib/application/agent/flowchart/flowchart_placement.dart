import 'flowchart_layering.dart';
import 'flowchart_layout_model.dart';

final class AxisBox {
  final double mainStart;
  final double crossCenter;
  final double mainSize;
  final double crossSize;

  const AxisBox({
    required this.mainStart,
    required this.crossCenter,
    required this.mainSize,
    required this.crossSize,
  });

  double get mainEnd => mainStart + mainSize;
}

final class AxisPlacement {
  final Map<String, AxisBox> boxes;
  final double mainExtent;
  final double crossExtent;

  const AxisPlacement({required this.boxes, required this.mainExtent, required this.crossExtent});
}

AxisPlacement placeOnAxes({
  required List<List<String>> layers,
  required LayeredGraph graph,
  required NodeExtent Function(String id) extentOf,
  required FlowchartSpacing spacing,
}) {
  final centers = <String, double>{};
  final passes = [
    (layers, graph.predecessors),
    (layers.reversed.toList(), graph.successors),
    (layers, graph.predecessors),
  ];
  for (final (ordered, anchors) in passes) {
    for (final layer in ordered) {
      _placeLayer(layer, centers, anchorsOf: anchors, extentOf: extentOf, gap: spacing.nodeGap);
    }
  }
  final shift = spacing.margin - _crossMinimum(layers, centers, extentOf);
  final boxes = <String, AxisBox>{};
  var mainCursor = spacing.margin;
  var crossExtent = 0.0;
  for (final layer in layers) {
    final thickness = layer.fold(0.0, (thick, id) => _max(thick, extentOf(id).height));
    for (final id in layer) {
      final extent = extentOf(id);
      final center = centers[id]! + shift;
      boxes[id] = AxisBox(
        mainStart: mainCursor + (thickness - extent.height) / 2,
        crossCenter: center,
        mainSize: extent.height,
        crossSize: extent.width,
      );
      crossExtent = _max(crossExtent, center + extent.width / 2 + spacing.margin);
    }
    mainCursor += thickness + spacing.rankGap;
  }
  return AxisPlacement(boxes: boxes, mainExtent: mainCursor - spacing.rankGap + spacing.margin, crossExtent: crossExtent);
}

void _placeLayer(
  List<String> layer,
  Map<String, double> centers, {
  required Map<String, List<String>> anchorsOf,
  required NodeExtent Function(String id) extentOf,
  required double gap,
}) {
  final desired = [for (final id in layer) _desiredCenter(id, centers, anchors: anchorsOf[id], extentOf: extentOf)];
  final separations = [
    for (var index = 1; index < layer.length; index += 1)
      (extentOf(layer[index - 1]).width + extentOf(layer[index]).width) / 2 + gap,
  ];
  final pushedRight = List.of(desired);
  for (var index = 1; index < layer.length; index += 1) {
    pushedRight[index] = _max(pushedRight[index], pushedRight[index - 1] + separations[index - 1]);
  }
  final pushedLeft = List.of(desired);
  for (var index = layer.length - 2; index >= 0; index -= 1) {
    pushedLeft[index] = _min(pushedLeft[index], pushedLeft[index + 1] - separations[index]);
  }
  for (final (index, id) in layer.indexed) {
    centers[id] = (pushedRight[index] + pushedLeft[index]) / 2;
  }
}

double _desiredCenter(
  String id,
  Map<String, double> centers, {
  required List<String>? anchors,
  required NodeExtent Function(String id) extentOf,
}) {
  final placed = [for (final anchor in anchors ?? const <String>[]) ?centers[anchor]];
  if (placed.isNotEmpty) return placed.reduce((a, b) => a + b) / placed.length;
  return centers[id] ?? extentOf(id).width / 2;
}

double _crossMinimum(List<List<String>> layers, Map<String, double> centers, NodeExtent Function(String id) extentOf) {
  var minimum = double.infinity;
  for (final layer in layers) {
    for (final id in layer) {
      minimum = _min(minimum, centers[id]! - extentOf(id).width / 2);
    }
  }
  return minimum.isFinite ? minimum : 0;
}

double _max(double a, double b) => a > b ? a : b;

double _min(double a, double b) => a < b ? a : b;
