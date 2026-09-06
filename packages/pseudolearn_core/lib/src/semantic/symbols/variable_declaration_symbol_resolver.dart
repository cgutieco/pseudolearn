import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_argument.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/profile/semantic_profile.dart';
import '../../domain/span.dart';
import '../../syntax/ast/ast_node.dart';
import 'expression_symbol_resolver.dart';
import 'scope.dart';
import 'symbol.dart';

final class VariableDeclarationSymbolResolver {
  final SemanticProfile profile;
  final List<Diagnostic> diagnostics;
  final ExpressionSymbolResolver expressionResolver;

  VariableDeclarationSymbolResolver({
    required this.profile,
    required this.diagnostics,
    required this.expressionResolver,
  });

  void resolveVarDeclaration(
    VariableDeclarationNode node,
    Scope scope,
    Set<String> visibleVars,
  ) {
    _validateCustomType(node.customTypeName, node.typeSpan, scope);
    for (final v in node.variables) {
      visibleVars.add(v.name);
    }
  }

  void resolveDimensionStatement(
    DimensionStatementNode node,
    Scope scope,
    Set<String> visibleVars,
  ) {
    _validateCustomType(node.customElementTypeName, node.typeSpan, scope);
    for (final array in node.arrays) {
      for (final dim in array.dimensions) {
        expressionResolver.resolve(dim, scope, visibleVars);
      }
      visibleVars.add(array.name);
    }
  }

  void _validateCustomType(String? customTypeName, Span span, Scope scope) {
    if (customTypeName == null) return;
    final symbol = scope.lookup(customTypeName);
    if (symbol == null || symbol is! ClassSymbol) {
      _report(
        DiagnosticCode.undeclaredClass,
        span,
        {'lexeme': LexemeDiagnosticArgument(customTypeName)},
      );
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
