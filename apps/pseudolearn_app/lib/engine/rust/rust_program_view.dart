import '../../domain/model/analysis/program_node_id.dart';
import '../../domain/model/analysis/source_range.dart';
import 'source_offset_index.dart';

final class RustViewNode {
  final ProgramNodeId id;
  final String kind;
  final SourceRange range;
  final List<int> children;

  const RustViewNode({
    required this.id,
    required this.kind,
    required this.range,
    required this.children,
  });
}

final class RustProgramView {
  final String revision;
  final Map<String, RustViewNode> _byIdentifier;
  final Map<int, String> _identifiers;

  const RustProgramView._(this.revision, this._byIdentifier, this._identifiers);

  factory RustProgramView.fromJson(
    Map<String, Object?> json,
    SourceOffsetIndex offsets,
  ) {
    final nodes = (json['nodes'] as List<Object?>).cast<Map<String, Object?>>();
    final ordinals = <String, int>{
      for (var index = 0; index < nodes.length; index++)
        nodes[index]['node_id'] as String: index,
    };
    final byIdentifier = <String, RustViewNode>{};
    final identifiers = <int, String>{};
    for (final node in nodes) {
      final identifier = node['node_id'] as String;
      final ordinal = ordinals[identifier]!;
      identifiers[ordinal] = identifier;
      byIdentifier[identifier] = RustViewNode(
        id: ProgramNodeId(ordinal),
        kind: node['kind'] as String,
        range: _rangeOf(node['span'] as Map<String, Object?>, offsets),
        children: [
          for (final child in node['child_node_ids'] as List<Object?>)
            ordinals[child as String]!,
        ],
      );
    }
    return RustProgramView._(
      json['revision_id'] as String,
      byIdentifier,
      identifiers,
    );
  }

  RustViewNode? node(String? identifier) =>
      identifier == null ? null : _byIdentifier[identifier];

  bool isContainer(RustViewNode node) => node.children.any(
    (child) => _byIdentifier[_identifiers[child]]?.kind == 'statement',
  );

  static SourceRange _rangeOf(
    Map<String, Object?> span,
    SourceOffsetIndex offsets,
  ) {
    final start = span['start'] as Map<String, Object?>;
    final end = span['end'] as Map<String, Object?>;
    return offsets.rangeOf(
      startLine: start['line'] as int,
      startColumn: start['column'] as int,
      endLine: end['line'] as int,
      endColumn: end['column'] as int,
    );
  }
}
