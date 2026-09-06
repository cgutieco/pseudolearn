import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_argument.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/node_id.dart';
import '../../domain/primitive_type.dart';
import '../../domain/profile/semantic_profile.dart';
import '../../domain/span.dart';
import '../../syntax/ast/ast_node.dart';
import 'scope.dart';
import 'symbol.dart';

final class BodyDeclarationCollector {
  final SemanticProfile profile;
  final List<Diagnostic> diagnostics;
  final Map<NodeId, Symbol> resolvedSymbols;

  BodyDeclarationCollector({
    required this.profile,
    required this.diagnostics,
    required this.resolvedSymbols,
  });

  void collectFromStatements(List<StatementNode> statements, Scope scope) {
    for (final stmt in statements) {
      _collectFromStatement(stmt, scope);
    }
  }

  void _collectFromStatement(StatementNode stmt, Scope scope) {
    switch (stmt) {
      case VariableDeclarationNode():
        _collectVarDeclaration(stmt, scope);
      case DimensionStatementNode():
        _collectDimensionStatement(stmt, scope);
      case IfStatementNode():
        collectFromStatements(stmt.thenBody, scope);
        if (stmt.elseBody != null) {
          collectFromStatements(stmt.elseBody!, scope);
        }
      case WhileStatementNode():
        collectFromStatements(stmt.body, scope);
      case RepeatUntilStatementNode():
        collectFromStatements(stmt.body, scope);
      case ForStatementNode():
        collectFromStatements(stmt.body, scope);
      case SwitchStatementNode():
        for (final caseNode in stmt.cases) {
          collectFromStatements(caseNode.body, scope);
        }
        if (stmt.defaultCase != null) {
          collectFromStatements(stmt.defaultCase!.body, scope);
        }
      default:
        break;
    }
  }

  void _collectVarDeclaration(VariableDeclarationNode node, Scope scope) {
    for (final v in node.variables) {
      _defineVariable(
        nodeId: v.id,
        name: v.name,
        span: v.span,
        type: node.type,
        customTypeName: node.customTypeName,
        dimensionCount: 0,
        scope: scope,
      );
    }
  }

  void _collectDimensionStatement(DimensionStatementNode node, Scope scope) {
    for (final array in node.arrays) {
      _defineVariable(
        nodeId: array.id,
        name: array.name,
        span: array.nameSpan,
        type: node.elementType,
        customTypeName: node.customElementTypeName,
        dimensionCount: array.dimensions.length,
        scope: scope,
      );
    }
  }

  bool _reportIfDuplicateOrShadowsSubroutine(
      String name, Span span, Scope scope) {
    final existing = scope.lookupLocal(name);
    if (existing != null) {
      _report(
        DiagnosticCode.duplicateVariableDeclaration,
        span,
        {'lexeme': LexemeDiagnosticArgument(name)},
        relatedSpans: [existing.span],
      );
      return true;
    }

    final topSymbol = scope.parent?.lookup(name);
    if (topSymbol is SubroutineSymbol) {
      _report(
        DiagnosticCode.subroutineAndVariableSameName,
        span,
        {'lexeme': LexemeDiagnosticArgument(name)},
        relatedSpans: [topSymbol.span],
      );
    }
    return false;
  }

  void _defineVariable({
    required NodeId nodeId,
    required String name,
    required Span span,
    required PrimitiveType? type,
    required String? customTypeName,
    required int dimensionCount,
    required Scope scope,
  }) {
    if (_reportIfDuplicateOrShadowsSubroutine(name, span, scope)) return;

    final symbol = VariableSymbol(
      name: name,
      span: span,
      primitiveType: type,
      customTypeName: customTypeName,
      dimensionCount: dimensionCount,
      isDeclared: true,
    );
    scope.define(symbol);
    resolvedSymbols[nodeId] = symbol;
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
