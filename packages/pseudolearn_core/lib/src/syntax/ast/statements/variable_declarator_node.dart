part of '../ast_node.dart';

final class VariableDeclaratorNode extends AstNode {
  final String name;

  const VariableDeclaratorNode({
    required super.id,
    required super.span,
    required this.name,
  });
}
