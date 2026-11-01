import 'package:pseudolearn_app/domain/model/diagram/diagram_scene.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/engine/rust/rust_class_diagram_builder.dart';
import 'package:pseudolearn_app/engine/rust/rust_transport.dart';

Future<Map<String, Object?>> runClassDiagramScenario(
  RustTransport transport,
  Map<String, Object?> input,
) async {
  final scene = RustClassDiagramBuilder(transport).buildDiagram(
    sourceCode: input['program'] as String,
    profileId: input['profile'] == 'en'
        ? SyntaxProfileId.english
        : SyntaxProfileId.classicSpanish,
  );
  final names = _namesByFrame(scene);
  return {
    'boxes': _boxes(scene),
    'relations': [
      for (final edge in scene.edges)
        {
          'kind': edge.kind.name,
          'from': names[edge.fromId],
          'to': names[edge.toId],
          'valid': edge.isValid,
          'diagnostics': edge.diagnostics,
          'has_origin': edge.originNodeId != null,
          if (edge.label != null) 'label': edge.label,
        },
    ],
  };
}

Map<String, String> _namesByFrame(DiagramScene scene) => {
  for (final node in scene.nodes)
    if (node.shape == DiagramShape.classHeader)
      node.id.replaceFirst('_header', ''): node.lines.last,
};

List<Map<String, Object?>> _boxes(DiagramScene scene) => [
  for (final header in scene.nodes.where(
    (node) => node.shape == DiagramShape.classHeader,
  ))
    {
      'name': header.lines.last,
      'stereotype': header.lines.length > 1 ? header.lines.first : null,
      'rows': [
        for (final row in scene.nodes.where(
          (node) =>
              node.shape == DiagramShape.classRow &&
              node.id.startsWith('${header.id.replaceFirst('_header', '')}_'),
        ))
          row.lines.single,
      ],
    },
];
