import 'package:pseudolearn_core/pseudolearn_core.dart';

final class CompoundStatementIndex {
  final Set<NodeId> _ids;

  const CompoundStatementIndex._(this._ids);

  const CompoundStatementIndex.empty() : _ids = const {};

  factory CompoundStatementIndex.of(SourceUnitNode unit) {
    final ids = <NodeId>{};
    final pending = <AstNode>[unit];
    while (pending.isNotEmpty) {
      final node = pending.removeLast();
      if (_isCompound(node)) ids.add(node.id);
      pending.addAll(getChildNodes(node));
    }
    return CompoundStatementIndex._(ids);
  }

  bool contains(NodeId id) => _ids.contains(id);

  static bool _isCompound(AstNode node) => switch (node) {
        IfStatementNode() ||
        SwitchStatementNode() ||
        WhileStatementNode() ||
        RepeatUntilStatementNode() ||
        ForStatementNode() =>
          true,
        _ => false,
      };
}
