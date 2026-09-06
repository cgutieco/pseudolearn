part of '../ast_node.dart';

final class ReturnStatementNode extends StatementNode {
  final ExpressionNode? value;

  const ReturnStatementNode({
    required super.id,
    required super.span,
    this.value,
  });
}

final class CallStatementNode extends StatementNode {
  final String name;
  final Span nameSpan;
  final List<ExpressionNode> arguments;

  const CallStatementNode({
    required super.id,
    required super.span,
    required this.name,
    required this.nameSpan,
    required this.arguments,
  });
}

final class MethodCallStatementNode extends StatementNode {
  final ExpressionNode target;
  final String methodName;
  final Span methodSpan;
  final List<ExpressionNode> arguments;

  const MethodCallStatementNode({
    required super.id,
    required super.span,
    required this.target,
    required this.methodName,
    required this.methodSpan,
    required this.arguments,
  });
}
