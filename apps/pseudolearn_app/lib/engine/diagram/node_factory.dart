import '../../domain/model/analysis/program_node_id.dart';
import '../../domain/model/diagram/diagram_scene.dart';
import 'node_sizing.dart';

final class NodeFactory {
  final NodeSizing _sizing;
  int _sequence = 0;

  NodeFactory(this._sizing);

  DiagramNode create({
    required DiagramShape shape,
    required String text,
    int? sourceLine,
    ProgramNodeId? nodeId,
  }) {
    final label = _sizing.measure(text, shape);
    return DiagramNode(
      id: _nextId(),
      shape: shape,
      lines: label.lines,
      x: 0.0,
      y: 0.0,
      width: label.width,
      height: label.height,
      sourceLine: sourceLine,
      nodeId: nodeId,
    );
  }

  DiagramNode connector() => create(shape: DiagramShape.connector, text: '');

  String _nextId() {
    _sequence += 1;
    return 'n$_sequence';
  }
}
