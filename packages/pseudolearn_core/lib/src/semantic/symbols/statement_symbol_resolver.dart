import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_argument.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/node_id.dart';
import '../../domain/profile/semantic_profile.dart';
import '../../domain/span.dart';
import '../../syntax/ast/ast_node.dart';
import 'control_flow_symbol_resolver.dart';
import 'expression_symbol_resolver.dart';
import 'scope.dart';
import 'symbol.dart';
import 'variable_declaration_symbol_resolver.dart';

final class StatementSymbolResolver {
  final SemanticProfile profile;
  final List<Diagnostic> diagnostics;
  final Map<NodeId, Symbol> resolvedSymbols;
  final ExpressionSymbolResolver expressionResolver;
  late final ControlFlowSymbolResolver _controlFlowResolver;
  late final VariableDeclarationSymbolResolver _varDeclResolver;

  StatementSymbolResolver({
    required this.profile,
    required this.diagnostics,
    required this.resolvedSymbols,
    required this.expressionResolver,
  }) {
    _controlFlowResolver = ControlFlowSymbolResolver(
      expressionResolver: expressionResolver,
      resolvedSymbols: resolvedSymbols,
      resolveStatement: resolveStatement,
      resolveVariableWrite: _resolveVariableWrite,
    );
    _varDeclResolver = VariableDeclarationSymbolResolver(
      profile: profile,
      diagnostics: diagnostics,
      expressionResolver: expressionResolver,
    );
  }

  void resolveStatement(
    StatementNode stmt,
    Scope scope,
    Set<String> visibleVars,
  ) {
    switch (stmt) {
      case VariableDeclarationNode():
        _varDeclResolver.resolveVarDeclaration(stmt, scope, visibleVars);
      case DimensionStatementNode():
        _varDeclResolver.resolveDimensionStatement(stmt, scope, visibleVars);
      case AssignmentStatementNode():
        _resolveAssignment(stmt, scope, visibleVars);
      case ReadStatementNode():
        _resolveRead(stmt, scope, visibleVars);
      case WriteStatementNode():
        _resolveWrite(stmt, scope, visibleVars);
      case IfStatementNode():
        _controlFlowResolver.resolveIf(stmt, scope, visibleVars);
      case WhileStatementNode():
        _controlFlowResolver.resolveWhile(stmt, scope, visibleVars);
      case RepeatUntilStatementNode():
        _controlFlowResolver.resolveRepeat(stmt, scope, visibleVars);
      case ForStatementNode():
        _controlFlowResolver.resolveFor(stmt, scope, visibleVars);
      case SwitchStatementNode():
        _controlFlowResolver.resolveSwitch(stmt, scope, visibleVars);
      case ReturnStatementNode():
        _resolveReturn(stmt, scope, visibleVars);
      case CallStatementNode():
        _resolveCall(stmt, scope, visibleVars);
      case MethodCallStatementNode():
        _resolveMethodCall(stmt, scope, visibleVars);
      case ErrorStatementNode():
        break;
    }
  }

  void _resolveAssignment(
    AssignmentStatementNode stmt,
    Scope scope,
    Set<String> visibleVars,
  ) {
    expressionResolver.resolve(stmt.value, scope, visibleVars);
    final target = stmt.target;
    if (target is VariableExpressionNode) {
      _resolveVariableWrite(target, scope, visibleVars);
    } else {
      expressionResolver.resolve(target, scope, visibleVars);
    }
  }

  void _resolveVariableWrite(
    VariableExpressionNode target,
    Scope scope,
    Set<String> visibleVars,
  ) {
    final symbol = scope.lookup(target.name);
    if (symbol == null) {
      _handleMissingVariableWrite(target, scope);
      return;
    }

    if (symbol is VariableSymbol) {
      _recordVariableAssignment(symbol, target, visibleVars);
    } else if (symbol is ParameterSymbol) {
      symbol.markAssigned();
      resolvedSymbols[target.id] = symbol;
    }
  }

  void _handleMissingVariableWrite(
    VariableExpressionNode target,
    Scope scope,
  ) {
    if (scope is MethodScope && scope.findEnclosingField(target.name) != null) {
      _report(
        DiagnosticCode.identifierMatchesFieldWithoutThis,
        target.span,
        {'lexeme': LexemeDiagnosticArgument(target.name)},
      );
      return;
    }
    _report(
      DiagnosticCode.undeclaredVariable,
      target.span,
      {'lexeme': LexemeDiagnosticArgument(target.name)},
    );
    final inferred = VariableSymbol(
      name: target.name,
      span: target.span,
      isDeclared: false,
      isAssigned: true,
      isRead: false,
    );
    scope.define(inferred);
    resolvedSymbols[target.id] = inferred;
  }

  void _recordVariableAssignment(
    VariableSymbol symbol,
    VariableExpressionNode target,
    Set<String> visibleVars,
  ) {
    if (!visibleVars.contains(symbol.name) && symbol.isDeclared) {
      _report(
        DiagnosticCode.variableUsedBeforeDeclaration,
        target.span,
        {'lexeme': LexemeDiagnosticArgument(target.name)},
        relatedSpans: [symbol.span],
      );
    }
    symbol.markAssigned();
    resolvedSymbols[target.id] = symbol;
  }

  void _resolveRead(
    ReadStatementNode stmt,
    Scope scope,
    Set<String> visibleVars,
  ) {
    for (final target in stmt.targets) {
      if (target is VariableExpressionNode) {
        _resolveVariableWrite(target, scope, visibleVars);
      } else {
        expressionResolver.resolve(target, scope, visibleVars);
      }
    }
  }

  void _resolveWrite(
    WriteStatementNode stmt,
    Scope scope,
    Set<String> visibleVars,
  ) {
    for (final expr in stmt.expressions) {
      expressionResolver.resolve(expr, scope, visibleVars);
    }
  }

  void _resolveReturn(
    ReturnStatementNode stmt,
    Scope scope,
    Set<String> visibleVars,
  ) {
    if (stmt.value != null) {
      expressionResolver.resolve(stmt.value!, scope, visibleVars);
    }
  }

  void _resolveCall(
    CallStatementNode stmt,
    Scope scope,
    Set<String> visibleVars,
  ) {
    expressionResolver.resolveCallNamed(
      name: stmt.name,
      span: stmt.nameSpan,
      arguments: stmt.arguments,
      callId: stmt.id,
      scope: scope,
      visibleVars: visibleVars,
    );
  }

  void _resolveMethodCall(
    MethodCallStatementNode stmt,
    Scope scope,
    Set<String> visibleVars,
  ) {
    expressionResolver.resolve(stmt.target, scope, visibleVars);
    for (final arg in stmt.arguments) {
      expressionResolver.resolve(arg, scope, visibleVars);
    }
  }

  void _report(
    DiagnosticCode code,
    Span span,
    Map<String, DiagnosticArgument> arguments, {
    List<Span>? relatedSpans,
  }) {
    diagnostics.add(
      Diagnostic(
        code: code,
        severity:
            profile.severityPolicy[code] ?? profile.severityPolicy.values.first,
        span: span,
        relatedSpans: relatedSpans ?? const [],
        arguments: arguments,
      ),
    );
  }
}
