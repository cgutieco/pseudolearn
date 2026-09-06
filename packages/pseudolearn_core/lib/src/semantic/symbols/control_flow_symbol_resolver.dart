import '../../domain/node_id.dart';
import '../../syntax/ast/ast_node.dart';
import 'expression_symbol_resolver.dart';
import 'scope.dart';
import 'symbol.dart';

final class ControlFlowSymbolResolver {
  final ExpressionSymbolResolver expressionResolver;
  final Map<NodeId, Symbol> resolvedSymbols;
  final void Function(StatementNode, Scope, Set<String>) resolveStatement;
  final void Function(VariableExpressionNode, Scope, Set<String>)
      resolveVariableWrite;

  ControlFlowSymbolResolver({
    required this.expressionResolver,
    required this.resolvedSymbols,
    required this.resolveStatement,
    required this.resolveVariableWrite,
  });

  void resolveIf(
    IfStatementNode stmt,
    Scope scope,
    Set<String> visibleVars,
  ) {
    expressionResolver.resolve(stmt.condition, scope, visibleVars);
    for (final s in stmt.thenBody) {
      resolveStatement(s, scope, visibleVars);
    }
    if (stmt.elseBody != null) {
      for (final s in stmt.elseBody!) {
        resolveStatement(s, scope, visibleVars);
      }
    }
  }

  void resolveWhile(
    WhileStatementNode stmt,
    Scope scope,
    Set<String> visibleVars,
  ) {
    expressionResolver.resolve(stmt.condition, scope, visibleVars);
    for (final s in stmt.body) {
      resolveStatement(s, scope, visibleVars);
    }
  }

  void resolveRepeat(
    RepeatUntilStatementNode stmt,
    Scope scope,
    Set<String> visibleVars,
  ) {
    for (final s in stmt.body) {
      resolveStatement(s, scope, visibleVars);
    }
    expressionResolver.resolve(stmt.condition, scope, visibleVars);
  }

  void resolveFor(
    ForStatementNode stmt,
    Scope scope,
    Set<String> visibleVars,
  ) {
    resolveVariableWrite(stmt.variable, scope, visibleVars);
    final varSymbol = resolvedSymbols[stmt.variable.id];
    if (varSymbol is VariableSymbol) {
      varSymbol.markRead();
    } else if (varSymbol is ParameterSymbol) {
      varSymbol.markRead();
    }

    expressionResolver.resolve(stmt.from, scope, visibleVars);
    expressionResolver.resolve(stmt.to, scope, visibleVars);
    if (stmt.step != null) {
      expressionResolver.resolve(stmt.step!, scope, visibleVars);
    }
    for (final s in stmt.body) {
      resolveStatement(s, scope, visibleVars);
    }
  }

  void resolveSwitch(
    SwitchStatementNode stmt,
    Scope scope,
    Set<String> visibleVars,
  ) {
    expressionResolver.resolve(stmt.selector, scope, visibleVars);
    for (final caseNode in stmt.cases) {
      for (final label in caseNode.labels) {
        expressionResolver.resolve(label, scope, visibleVars);
      }
      for (final s in caseNode.body) {
        resolveStatement(s, scope, visibleVars);
      }
    }
    if (stmt.defaultCase != null) {
      for (final s in stmt.defaultCase!.body) {
        resolveStatement(s, scope, visibleVars);
      }
    }
  }
}
