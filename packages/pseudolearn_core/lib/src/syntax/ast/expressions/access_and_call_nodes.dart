part of '../ast_node.dart';

final class ArrayAccessExpressionNode extends ExpressionNode {
  final ExpressionNode target;
  final List<ExpressionNode> indices;

  const ArrayAccessExpressionNode({
    required super.id,
    required super.span,
    required this.target,
    required this.indices,
  });
}

final class FunctionCallExpressionNode extends ExpressionNode {
  final String name;
  final Span nameSpan;
  final List<ExpressionNode> arguments;

  const FunctionCallExpressionNode({
    required super.id,
    required super.span,
    required this.name,
    required this.nameSpan,
    required this.arguments,
  });
}
