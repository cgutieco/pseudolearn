import '../../domain/model/analysis/program_node_id.dart';
import '../../domain/model/analysis/source_range.dart';
import 'rust_view_semantics.dart';
import 'source_offset_index.dart';

part 'rust_program_view_builder.dart';

final class RustViewNode {
  final ProgramNodeId id;
  final String kind;
  final String syntaxKind;
  final String text;
  final SourceRange range;
  final int? dimensions;
  final List<int> children;
  final Map<int, String> childRoles;
  final RustViewSemantics semantics;

  const RustViewNode({
    required this.id,
    required this.kind,
    required this.syntaxKind,
    required this.text,
    required this.range,
    required this.dimensions,
    required this.children,
    required this.childRoles,
    this.semantics = RustViewSemantics.none,
  });
}

final class RustViewUnit {
  final String id;
  final String kind;
  final String name;
  final int order;
  final ProgramNodeId nodeId;
  final SourceRange range;

  const RustViewUnit({
    required this.id,
    required this.kind,
    required this.name,
    required this.order,
    required this.nodeId,
    required this.range,
  });
}

final class RustViewMember {
  final String className;
  final String name;
  final String kind;
  final String visibility;
  final int? arity;
  final String? typeName;
  final int dimensions;
  final ProgramNodeId? nodeId;

  const RustViewMember({
    required this.className,
    required this.name,
    required this.kind,
    required this.visibility,
    required this.arity,
    required this.typeName,
    required this.dimensions,
    required this.nodeId,
  });
}

final class RustProgramView {
  final String revision;
  final Map<String, RustViewNode> _byIdentifier;
  final Map<int, String> _identifiers;
  final List<RustViewUnit> units;
  final List<RustViewMember> members;
  final Map<String, String> superclasses;

  const RustProgramView._({
    required this.revision,
    required Map<String, RustViewNode> byIdentifier,
    required Map<int, String> identifiers,
    required this.units,
    required this.members,
    required this.superclasses,
  }) : _byIdentifier = byIdentifier,
       _identifiers = identifiers;

  factory RustProgramView.fromJson(
    Map<String, Object?> json,
    SourceOffsetIndex offsets,
  ) {
    final nodes = (json['nodes'] as List<Object?>).cast<Map<String, Object?>>();
    final ordinals = _ordinalsFor(nodes);
    final viewNodes = _RustViewNodeBuilder(ordinals, offsets).build(nodes);
    return RustProgramView._(
      revision: json['revision_id'] as String,
      byIdentifier: viewNodes.byIdentifier,
      identifiers: viewNodes.identifiers,
      units: _unitsFor(json, ordinals, offsets),
      members: _membersFor(json, ordinals),
      superclasses: _superclassesFor(json),
    );
  }

  RustViewNode? node(String? identifier) =>
      identifier == null ? null : _byIdentifier[identifier];

  Iterable<RustViewNode> get nodes => _byIdentifier.values;

  RustViewNode? nodeById(ProgramNodeId id) =>
      _byIdentifier[_identifiers[id.value]];

  RustViewNode? childForRole(RustViewNode node, String role) {
    for (final child in rustChildrenOf(this, node)) {
      if (node.childRoles[child.id.value] == role) return child;
    }
    return null;
  }

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

  static String _textOf(Map<String, Object?> span, SourceOffsetIndex offsets) {
    final range = _rangeOf(span, offsets);
    return offsets.textBetween(range);
  }
}
