part of '../ast_node.dart';

final class AssignmentStatementNode extends StatementNode {
  final ExpressionNode target;
  final ExpressionNode value;
  final Span assignmentOperatorSpan;

  const AssignmentStatementNode({
    required super.id,
    required super.span,
    required this.target,
    required this.value,
    required this.assignmentOperatorSpan,
  });
}

final class WriteStatementNode extends StatementNode {
  final List<ExpressionNode> expressions;
  final bool withoutNewline;
  final Span? withoutNewlineSpan;

  const WriteStatementNode({
    required super.id,
    required super.span,
    required this.expressions,
    this.withoutNewline = false,
    this.withoutNewlineSpan,
  });
}

final class ReadStatementNode extends StatementNode {
  final List<ExpressionNode> targets;

  const ReadStatementNode({
    required super.id,
    required super.span,
    required this.targets,
  });
}

final class ErrorStatementNode extends StatementNode {
  const ErrorStatementNode({
    required super.id,
    required super.span,
  });
}
