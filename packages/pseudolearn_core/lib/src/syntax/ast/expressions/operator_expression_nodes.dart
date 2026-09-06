part of '../ast_node.dart';

final class UnaryExpressionNode extends ExpressionNode {
  final UnaryOperator operator;
  final ExpressionNode operand;
  final Span operatorSpan;

  const UnaryExpressionNode({
    required super.id,
    required super.span,
    required this.operator,
    required this.operand,
    required this.operatorSpan,
  });
}

final class BinaryExpressionNode extends ExpressionNode {
  final ExpressionNode left;
  final BinaryOperator operator;
  final ExpressionNode right;
  final Span operatorSpan;

  const BinaryExpressionNode({
    required super.id,
    required super.span,
    required this.left,
    required this.operator,
    required this.right,
    required this.operatorSpan,
  });
}

final class ParenthesizedExpressionNode extends ExpressionNode {
  final ExpressionNode expression;

  const ParenthesizedExpressionNode({
    required super.id,
    required super.span,
    required this.expression,
  });
}
