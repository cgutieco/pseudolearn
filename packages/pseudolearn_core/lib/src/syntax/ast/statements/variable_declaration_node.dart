part of '../ast_node.dart';

final class VariableDeclarationNode extends StatementNode {
  final List<VariableDeclaratorNode> variables;
  final PrimitiveType? type;
  final String? customTypeName;
  final Span typeSpan;

  const VariableDeclarationNode({
    required super.id,
    required super.span,
    required this.variables,
    this.type,
    this.customTypeName,
    required this.typeSpan,
  });
}
