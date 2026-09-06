import '../../domain/node_id.dart';
import '../../domain/position.dart';
import '../../domain/span.dart';
import 'ast_node.dart';

List<AstNode> getChildNodes(AstNode node) => switch (node) {
      StatementNode() => _getStatementChildNodes(node),
      ExpressionNode() => _getExpressionChildNodes(node),
      TypeAnnotationNode() => const [],
      SourceUnitNode(:final declarations) => declarations,
      AlgorithmNode(:final body) => body,
      SubroutineDeclarationNode(:final parameters, :final body) => [
          ...parameters,
          ...body,
        ],
      ClassNode(:final members) => members,
      ClassMemberNode() => _getClassMemberChildNodes(node),
      ParameterNode() => const [],
      VariableDeclaratorNode() => const [],
      ArrayDeclaratorNode(:final dimensions) => dimensions,
      SwitchCaseNode(:final labels, :final body) => [...labels, ...body],
      SwitchDefaultNode(:final body) => body,
    };

List<AstNode> _getClassMemberChildNodes(ClassMemberNode node) => switch (node) {
      ClassFieldNode(:final declaration) => [declaration],
      MethodDeclarationNode(:final parameters, :final body) => [
          ...parameters,
          ...body,
        ],
      ConstructorDeclarationNode(:final parameters, :final body) => [
          ...parameters,
          ...body,
        ],
    };

List<AstNode> _getStatementChildNodes(StatementNode node) => switch (node) {
      VariableDeclarationNode(:final variables) => variables,
      DimensionStatementNode(:final arrays) => arrays,
      AssignmentStatementNode(:final target, :final value) => [target, value],
      WriteStatementNode(:final expressions) => expressions,
      ReadStatementNode(:final targets) => targets,
      ReturnStatementNode(:final value) => [if (value != null) value],
      CallStatementNode(:final arguments) => arguments,
      MethodCallStatementNode(:final target, :final arguments) => [
          target,
          ...arguments,
        ],
      ErrorStatementNode() => const [],
      IfStatementNode() ||
      SwitchStatementNode() =>
        _getBranchingChildNodes(node),
      WhileStatementNode() ||
      RepeatUntilStatementNode() ||
      ForStatementNode() =>
        _getLoopChildNodes(node),
    };

List<AstNode> _getBranchingChildNodes(StatementNode node) => switch (node) {
      IfStatementNode(:final condition, :final thenBody, :final elseBody) => [
          condition,
          ...thenBody,
          if (elseBody != null) ...elseBody,
        ],
      SwitchStatementNode(:final selector, :final cases, :final defaultCase) =>
        [
          selector,
          ...cases,
          if (defaultCase != null) defaultCase,
        ],
      VariableDeclarationNode() ||
      DimensionStatementNode() ||
      AssignmentStatementNode() ||
      WriteStatementNode() ||
      ReadStatementNode() ||
      ReturnStatementNode() ||
      CallStatementNode() ||
      MethodCallStatementNode() ||
      WhileStatementNode() ||
      RepeatUntilStatementNode() ||
      ForStatementNode() ||
      ErrorStatementNode() =>
        const [],
    };

List<AstNode> _getLoopChildNodes(StatementNode node) => switch (node) {
      WhileStatementNode(:final condition, :final body) => [condition, ...body],
      RepeatUntilStatementNode(:final body, :final condition) => [
          ...body,
          condition,
        ],
      ForStatementNode(
        :final variable,
        :final from,
        :final to,
        :final step,
        :final body,
      ) =>
        [
          variable,
          from,
          to,
          if (step != null) step,
          ...body,
        ],
      VariableDeclarationNode() ||
      DimensionStatementNode() ||
      AssignmentStatementNode() ||
      WriteStatementNode() ||
      ReadStatementNode() ||
      ReturnStatementNode() ||
      CallStatementNode() ||
      MethodCallStatementNode() ||
      IfStatementNode() ||
      SwitchStatementNode() ||
      ErrorStatementNode() =>
        const [],
    };

List<AstNode> _getExpressionChildNodes(ExpressionNode node) => switch (node) {
      LiteralExpressionNode() ||
      VariableExpressionNode() ||
      ThisExpressionNode() ||
      SuperExpressionNode() =>
        const [],
      UnaryExpressionNode(:final operand) => [operand],
      BinaryExpressionNode(:final left, :final right) => [left, right],
      ParenthesizedExpressionNode(:final expression) => [expression],
      ArrayAccessExpressionNode(:final target, :final indices) => [
          target,
          ...indices,
        ],
      FunctionCallExpressionNode(:final arguments) => arguments,
      InstantiationExpressionNode(:final arguments) => arguments,
      MemberAccessExpressionNode(:final target) => [target],
      MethodCallExpressionNode(:final target, :final arguments) => [
          target,
          ...arguments,
        ],
    };

AstNode? findInnermostNodeAt(AstNode root, Position position) {
  if (!root.span.contains(position)) {
    return null;
  }
  for (final child in getChildNodes(root)) {
    final matchedChild = findInnermostNodeAt(child, position);
    if (matchedChild != null) {
      return matchedChild;
    }
  }
  return root;
}

Set<NodeId> collectNodeIds(AstNode root) {
  final ids = <NodeId>{};
  _collectNodeIdsRecursively(root, ids);
  return ids;
}

void _collectNodeIdsRecursively(AstNode node, Set<NodeId> target) {
  target.add(node.id);
  for (final child in getChildNodes(node)) {
    _collectNodeIdsRecursively(child, target);
  }
}

Span calculateEnclosingSpan(AstNode root) {
  var result = root.span;
  for (final child in getChildNodes(root)) {
    result = result.union(calculateEnclosingSpan(child));
  }
  return result;
}

List<T> collectNodesOfType<T extends AstNode>(AstNode root) {
  final matching = <T>[];
  _collectNodesOfTypeRecursively(root, matching);
  return matching;
}

void _collectNodesOfTypeRecursively<T extends AstNode>(
  AstNode node,
  List<T> target,
) {
  if (node is T) {
    target.add(node);
  }
  for (final child in getChildNodes(node)) {
    _collectNodesOfTypeRecursively(child, target);
  }
}
