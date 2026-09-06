import '../../domain/model/diagram/class_diagram_metrics.dart';
import '../../domain/model/diagram/class_model.dart';
import '../../domain/model/diagram/diagram_scene.dart';
import 'class_box_placement.dart';

final class ClassBoxNodes {
  const ClassBoxNodes();

  static String frameIdOf(PlacedClassBox placed) => 'box${placed.index}';

  List<DiagramNode> of(PlacedClassBox placed) {
    final nodes = <DiagramNode>[
      _frame(placed),
      _header(placed),
      _compartment(
        placed,
        suffix: 'attributes',
        top: placed.attributesTop,
        height: placed.size.attributesHeight,
      ),
      _compartment(
        placed,
        suffix: 'methods',
        top: placed.methodsTop,
        height: placed.size.methodsHeight,
      ),
    ];
    _appendRows(
      nodes,
      placed,
      rows: placed.box.attributes,
      compartmentTop: placed.attributesTop,
      prefix: 'a',
    );
    _appendRows(
      nodes,
      placed,
      rows: placed.box.methods,
      compartmentTop: placed.methodsTop,
      prefix: 'm',
    );
    return nodes;
  }

  DiagramNode _frame(PlacedClassBox placed) => DiagramNode(
        id: frameIdOf(placed),
        shape: DiagramShape.classFrame,
        lines: const [],
        x: placed.left,
        y: placed.top,
        width: placed.size.width,
        height: placed.size.height,
        sourceLine: placed.box.sourceLine,
        nodeId: placed.box.nodeId,
      );

  DiagramNode _header(PlacedClassBox placed) => DiagramNode(
        id: '${frameIdOf(placed)}_header',
        shape: DiagramShape.classHeader,
        lines: [placed.box.name],
        x: placed.left,
        y: placed.top,
        width: placed.size.width,
        height: placed.size.headerHeight,
        sourceLine: placed.box.sourceLine,
        nodeId: placed.box.nodeId,
      );

  DiagramNode _compartment(
    PlacedClassBox placed, {
    required String suffix,
    required double top,
    required double height,
  }) =>
      DiagramNode(
        id: '${frameIdOf(placed)}_$suffix',
        shape: DiagramShape.classCompartment,
        lines: const [],
        x: placed.left,
        y: top,
        width: placed.size.width,
        height: height,
      );

  void _appendRows(
    List<DiagramNode> nodes,
    PlacedClassBox placed, {
    required List<ClassMemberRow> rows,
    required double compartmentTop,
    required String prefix,
  }) {
    for (var index = 0; index < rows.length; index++) {
      nodes.add(DiagramNode(
        id: '${frameIdOf(placed)}_$prefix$index',
        shape: DiagramShape.classRow,
        lines: [_rowTextOf(rows[index])],
        x: placed.left,
        y: compartmentTop +
            ClassDiagramMetrics.boxPadding / 2 +
            index * ClassDiagramMetrics.rowHeight,
        width: placed.size.width,
        height: ClassDiagramMetrics.rowHeight,
        sourceLine: rows[index].sourceLine,
        nodeId: rows[index].nodeId,
      ));
    }
  }

  String _rowTextOf(ClassMemberRow row) => switch (row.visibility) {
        ClassMemberVisibility.public => '+ ${row.text}',
        ClassMemberVisibility.private => '- ${row.text}',
      };
}
