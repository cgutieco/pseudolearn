import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_argument.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/node_id.dart';
import '../../domain/profile/semantic_profile.dart';
import '../../domain/span.dart';
import '../../syntax/ast/ast_node.dart';
import 'scope.dart';
import 'symbol.dart';

final class OopExpressionSymbolResolver {
  final SemanticProfile profile;
  final List<Diagnostic> diagnostics;
  final Map<NodeId, ClassSymbol> resolvedClasses;
  final void Function(ExpressionNode, Scope, Set<String>) resolveExpression;

  OopExpressionSymbolResolver({
    required this.profile,
    required this.diagnostics,
    required this.resolvedClasses,
    required this.resolveExpression,
  });

  void resolveInstantiation({
    required String className,
    required Span classNameSpan,
    required List<ExpressionNode> arguments,
    required NodeId id,
    required Scope scope,
    required Set<String> visibleVars,
  }) {
    final symbol = scope.lookup(className);
    if (symbol == null || symbol is! ClassSymbol) {
      _report(
        DiagnosticCode.undeclaredClass,
        classNameSpan,
        {'lexeme': LexemeDiagnosticArgument(className)},
      );
    } else {
      symbol.markInstantiated();
      resolvedClasses[id] = symbol;
    }
    for (final arg in arguments) {
      resolveExpression(arg, scope, visibleVars);
    }
  }

  void resolveMemberAccess({
    required ExpressionNode target,
    required String memberName,
    required Span memberSpan,
    required Scope scope,
    required Set<String> visibleVars,
  }) {
    resolveExpression(target, scope, visibleVars);
    if (target is ThisExpressionNode && scope is MethodScope) {
      final field = scope.classScope.classSymbol.findField(memberName);
      if (field == null) {
        _report(
          DiagnosticCode.undefinedMember,
          memberSpan,
          {'lexeme': LexemeDiagnosticArgument(memberName)},
        );
      } else {
        field.markRead();
      }
    }
  }

  void resolveMethodCall({
    required ExpressionNode target,
    required String methodName,
    required Span methodSpan,
    required List<ExpressionNode> arguments,
    required Scope scope,
    required Set<String> visibleVars,
  }) {
    resolveExpression(target, scope, visibleVars);
    for (final arg in arguments) {
      resolveExpression(arg, scope, visibleVars);
    }
    _checkMethodCallTarget(target, methodName, methodSpan, scope);
  }

  void _checkMethodCallTarget(
    ExpressionNode target,
    String methodName,
    Span methodSpan,
    Scope scope,
  ) {
    if (target is ThisExpressionNode && scope is MethodScope) {
      final method = scope.classScope.classSymbol.findMethod(methodName);
      if (method == null) {
        _report(
          DiagnosticCode.undefinedMember,
          methodSpan,
          {'lexeme': LexemeDiagnosticArgument(methodName)},
        );
      }
    } else if (target is SuperExpressionNode && scope is MethodScope) {
      final method =
          scope.classScope.classSymbol.superclass?.findMethod(methodName);
      if (method == null && methodName.toLowerCase() != 'constructor') {
        _report(
          DiagnosticCode.undefinedMember,
          methodSpan,
          {'lexeme': LexemeDiagnosticArgument(methodName)},
        );
      }
    }
  }

  void _report(
    DiagnosticCode code,
    Span span,
    Map<String, DiagnosticArgument> arguments,
  ) {
    diagnostics.add(
      Diagnostic(
        code: code,
        severity:
            profile.severityPolicy[code] ?? profile.severityPolicy.values.first,
        span: span,
        arguments: arguments,
      ),
    );
  }
}
