part of '../ast_node.dart';

final class InstantiationExpressionNode extends ExpressionNode {
  final String className;
  final Span classNameSpan;
  final List<ExpressionNode> arguments;

  const InstantiationExpressionNode({
    required super.id,
    required super.span,
    required this.className,
    required this.classNameSpan,
    required this.arguments,
  });
}

final class MemberAccessExpressionNode extends ExpressionNode {
  final ExpressionNode target;
  final String memberName;
  final Span memberSpan;

  const MemberAccessExpressionNode({
    required super.id,
    required super.span,
    required this.target,
    required this.memberName,
    required this.memberSpan,
  });
}

final class MethodCallExpressionNode extends ExpressionNode {
  final ExpressionNode target;
  final String methodName;
  final Span methodSpan;
  final List<ExpressionNode> arguments;

  const MethodCallExpressionNode({
    required super.id,
    required super.span,
    required this.target,
    required this.methodName,
    required this.methodSpan,
    required this.arguments,
  });
}

final class ThisExpressionNode extends ExpressionNode {
  const ThisExpressionNode({
    required super.id,
    required super.span,
  });
}

final class SuperExpressionNode extends ExpressionNode {
  const SuperExpressionNode({
    required super.id,
    required super.span,
  });
}
