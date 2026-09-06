part of '../ast_node.dart';

final class LiteralExpressionNode extends ExpressionNode {
  final Object value;
  final PrimitiveType type;

  const LiteralExpressionNode({
    required super.id,
    required super.span,
    required this.value,
    required this.type,
  });
}
