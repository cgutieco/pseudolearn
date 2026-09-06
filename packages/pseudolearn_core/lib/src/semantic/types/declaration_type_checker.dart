import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/severity.dart';
import '../../syntax/ast/ast_node.dart';
import '../symbols/resolution_result.dart';
import 'expression_type_checker.dart';
import 'semantic_type.dart';
import 'type_environment.dart';

final class DeclarationTypeChecker {
  final ResolutionResult resolution;
  final TypeEnvironment environment;
  final ExpressionTypeChecker expressionChecker;
  final List<Diagnostic> diagnostics;
  final Severity Function(DiagnosticCode code) severityFor;

  const DeclarationTypeChecker({
    required this.resolution,
    required this.environment,
    required this.expressionChecker,
    required this.diagnostics,
    required this.severityFor,
  });

  void checkVarDeclaration(VariableDeclarationNode node) {
    final declaredType = node.type != null
        ? PrimitiveSemanticType(node.type!)
        : (node.customTypeName != null
            ? ClassSemanticType(node.customTypeName!)
            : const IndeterminateSemanticType());

    for (final declarator in node.variables) {
      final symbol = resolution.symbolFor(declarator.id);
      if (symbol != null) {
        environment.declare(symbol, declaredType, isExplicit: true);
      }
    }
  }

  void checkDimension(DimensionStatementNode node) {
    final elemType = node.elementType != null
        ? PrimitiveSemanticType(node.elementType!)
        : (node.customElementTypeName != null
            ? ClassSemanticType(node.customElementTypeName!)
            : const IndeterminateSemanticType());

    for (final decl in node.arrays) {
      for (final sizeExpr in decl.dimensions) {
        final sizeType = expressionChecker.check(sizeExpr);
        if (!sizeType.isInteger &&
            !sizeType.isError &&
            !sizeType.isIndeterminate) {
          diagnostics.add(
            Diagnostic(
              code: DiagnosticCode.nonIntegerArrayIndex,
              severity: severityFor(DiagnosticCode.nonIntegerArrayIndex),
              span: sizeExpr.span,
            ),
          );
        }
      }

      final arrayType = ArraySemanticType(elemType, decl.dimensions.length);
      final symbol = resolution.symbolFor(decl.id);
      if (symbol != null) {
        environment.declare(
          symbol,
          arrayType,
          isExplicit: true,
          isInitialized: true,
        );
      }
    }
  }
}
