import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_argument.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/node_id.dart';
import '../../domain/profile/semantic_profile.dart';
import '../../domain/span.dart';
import '../../syntax/ast/ast_node.dart';
import 'oop_expression_symbol_resolver.dart';
import 'scope.dart';
import 'symbol.dart';

final class ExpressionSymbolResolver {
  final SemanticProfile profile;
  final List<Diagnostic> diagnostics;
  final Map<NodeId, Symbol> resolvedSymbols;
  final Map<NodeId, ClassSymbol> resolvedClasses;
  late final OopExpressionSymbolResolver _oopResolver;

  ExpressionSymbolResolver({
    required this.profile,
    required this.diagnostics,
    required this.resolvedSymbols,
    required this.resolvedClasses,
  }) {
    _oopResolver = OopExpressionSymbolResolver(
      profile: profile,
      diagnostics: diagnostics,
      resolvedClasses: resolvedClasses,
      resolveExpression: resolve,
    );
  }

  void resolve(
    ExpressionNode expr,
    Scope scope,
    Set<String> visibleVars,
  ) {
    switch (expr) {
      case LiteralExpressionNode() ||
            ThisExpressionNode() ||
            SuperExpressionNode():
        break;
      case VariableExpressionNode():
        _resolveVariableRead(expr, scope, visibleVars);
      case UnaryExpressionNode(:final operand):
        resolve(operand, scope, visibleVars);
      case BinaryExpressionNode(:final left, :final right):
        resolve(left, scope, visibleVars);
        resolve(right, scope, visibleVars);
      case ParenthesizedExpressionNode(:final expression):
        resolve(expression, scope, visibleVars);
      case ArrayAccessExpressionNode(:final target, :final indices):
        _resolveArrayAccess(target, indices, scope, visibleVars);
      case FunctionCallExpressionNode():
        _resolveFunctionCall(expr, scope, visibleVars);
      case InstantiationExpressionNode() ||
            MemberAccessExpressionNode() ||
            MethodCallExpressionNode():
        _resolveOopExpression(expr, scope, visibleVars);
    }
  }

  void _resolveFunctionCall(
    FunctionCallExpressionNode expr,
    Scope scope,
    Set<String> visibleVars,
  ) {
    resolveCallNamed(
      name: expr.name,
      span: expr.nameSpan,
      arguments: expr.arguments,
      callId: expr.id,
      scope: scope,
      visibleVars: visibleVars,
    );
  }

  void _resolveOopExpression(
    ExpressionNode expr,
    Scope scope,
    Set<String> visibleVars,
  ) {
    if (expr is InstantiationExpressionNode) {
      _oopResolver.resolveInstantiation(
        className: expr.className,
        classNameSpan: expr.classNameSpan,
        arguments: expr.arguments,
        id: expr.id,
        scope: scope,
        visibleVars: visibleVars,
      );
    } else if (expr is MemberAccessExpressionNode) {
      _oopResolver.resolveMemberAccess(
        target: expr.target,
        memberName: expr.memberName,
        memberSpan: expr.memberSpan,
        scope: scope,
        visibleVars: visibleVars,
      );
    } else if (expr is MethodCallExpressionNode) {
      _oopResolver.resolveMethodCall(
        target: expr.target,
        methodName: expr.methodName,
        methodSpan: expr.methodSpan,
        arguments: expr.arguments,
        scope: scope,
        visibleVars: visibleVars,
      );
    }
  }

  void _resolveArrayAccess(
    ExpressionNode target,
    List<ExpressionNode> indices,
    Scope scope,
    Set<String> visibleVars,
  ) {
    resolve(target, scope, visibleVars);
    for (final idx in indices) {
      resolve(idx, scope, visibleVars);
    }
  }

  void resolveCallNamed({
    required String name,
    required Span span,
    required List<ExpressionNode> arguments,
    required NodeId callId,
    required Scope scope,
    required Set<String> visibleVars,
  }) {
    final symbol = scope.lookup(name);
    if (symbol is SubroutineSymbol) {
      symbol.markCalled();
      resolvedSymbols[callId] = symbol;
      _resolveSubroutineArguments(symbol, arguments, scope, visibleVars);
    } else if (symbol is BuiltinFunctionSymbol) {
      resolvedSymbols[callId] = symbol;
      for (final arg in arguments) {
        resolve(arg, scope, visibleVars);
      }
    } else {
      _report(
        DiagnosticCode.undeclaredSubroutine,
        span,
        {'lexeme': LexemeDiagnosticArgument(name)},
      );
      for (final arg in arguments) {
        resolve(arg, scope, visibleVars);
      }
    }
  }

  void _resolveSubroutineArguments(
    SubroutineSymbol symbol,
    List<ExpressionNode> arguments,
    Scope scope,
    Set<String> visibleVars,
  ) {
    for (var i = 0; i < arguments.length; i++) {
      final arg = arguments[i];
      resolve(arg, scope, visibleVars);
      if (i < symbol.parameters.length) {
        _markByRefArgument(symbol.parameters[i], arg);
      }
    }
  }

  void _markByRefArgument(ParameterSymbol param, ExpressionNode arg) {
    if (param.passingMode != ParameterPassingMode.byReference) return;
    if (arg is! VariableExpressionNode) return;

    final argSym = resolvedSymbols[arg.id];
    if (argSym is VariableSymbol) {
      argSym.markRead();
      argSym.markAssigned();
    } else if (argSym is ParameterSymbol) {
      argSym.markRead();
      argSym.markAssigned();
    }
  }

  void _resolveVariableRead(
    VariableExpressionNode node,
    Scope scope,
    Set<String> visibleVars,
  ) {
    final symbol = scope.lookup(node.name);
    if (symbol == null) {
      if (scope is MethodScope && scope.findEnclosingField(node.name) != null) {
        _report(
          DiagnosticCode.identifierMatchesFieldWithoutThis,
          node.span,
          {'lexeme': LexemeDiagnosticArgument(node.name)},
        );
        return;
      }
      _handleUndeclaredVariable(node, scope, isWrite: false);
      return;
    }

    if (symbol is VariableSymbol) {
      if (!visibleVars.contains(symbol.name) && symbol.isDeclared) {
        _report(
          DiagnosticCode.variableUsedBeforeDeclaration,
          node.span,
          {'lexeme': LexemeDiagnosticArgument(node.name)},
          relatedSpans: [symbol.span],
        );
      }
      symbol.markRead();
      resolvedSymbols[node.id] = symbol;
    } else if (symbol is ParameterSymbol) {
      symbol.markRead();
      resolvedSymbols[node.id] = symbol;
    }
  }

  void _handleUndeclaredVariable(
    VariableExpressionNode node,
    Scope scope, {
    required bool isWrite,
  }) {
    _report(
      DiagnosticCode.undeclaredVariable,
      node.span,
      {'lexeme': LexemeDiagnosticArgument(node.name)},
    );

    final inferred = VariableSymbol(
      name: node.name,
      span: node.span,
      isDeclared: false,
      isAssigned: isWrite,
      isRead: !isWrite,
    );
    scope.define(inferred);
    resolvedSymbols[node.id] = inferred;
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
