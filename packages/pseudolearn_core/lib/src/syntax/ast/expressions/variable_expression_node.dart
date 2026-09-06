part of '../ast_node.dart';

final class VariableExpressionNode extends ExpressionNode {
  final String name;

  const VariableExpressionNode({
    required super.id,
    required super.span,
    required this.name,
  });
}
