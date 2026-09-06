part of '../ast_node.dart';

final class IfStatementNode extends StatementNode {
  final ExpressionNode condition;
  final List<StatementNode> thenBody;
  final List<StatementNode>? elseBody;
  final Span? elseKeywordSpan;

  const IfStatementNode({
    required super.id,
    required super.span,
    required this.condition,
    required this.thenBody,
    this.elseBody,
    this.elseKeywordSpan,
  });
}

final class SwitchCaseNode extends AstNode {
  final List<ExpressionNode> labels;
  final List<StatementNode> body;

  const SwitchCaseNode({
    required super.id,
    required super.span,
    required this.labels,
    required this.body,
  });
}

final class SwitchDefaultNode extends AstNode {
  final List<StatementNode> body;

  const SwitchDefaultNode({
    required super.id,
    required super.span,
    required this.body,
  });
}

final class SwitchStatementNode extends StatementNode {
  final ExpressionNode selector;
  final List<SwitchCaseNode> cases;
  final SwitchDefaultNode? defaultCase;

  const SwitchStatementNode({
    required super.id,
    required super.span,
    required this.selector,
    required this.cases,
    this.defaultCase,
  });
}

final class WhileStatementNode extends StatementNode {
  final ExpressionNode condition;
  final List<StatementNode> body;

  const WhileStatementNode({
    required super.id,
    required super.span,
    required this.condition,
    required this.body,
  });
}

final class RepeatUntilStatementNode extends StatementNode {
  final List<StatementNode> body;
  final ExpressionNode condition;
  final Span untilKeywordSpan;

  const RepeatUntilStatementNode({
    required super.id,
    required super.span,
    required this.body,
    required this.condition,
    required this.untilKeywordSpan,
  });
}

final class ForStatementNode extends StatementNode {
  final VariableExpressionNode variable;
  final ExpressionNode from;
  final ExpressionNode to;
  final ExpressionNode? step;
  final List<StatementNode> body;

  const ForStatementNode({
    required super.id,
    required super.span,
    required this.variable,
    required this.from,
    required this.to,
    this.step,
    required this.body,
  });
}
