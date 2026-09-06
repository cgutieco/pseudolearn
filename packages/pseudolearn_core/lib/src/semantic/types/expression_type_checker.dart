import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_argument.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/node_id.dart';
import '../../domain/severity.dart';
import '../../domain/span.dart';
import '../../syntax/ast/ast_node.dart';
import '../symbols/resolution_result.dart';
import '../symbols/symbol.dart';
import 'call_and_oop_type_checker.dart';
import 'class_hierarchy_provider.dart';
import 'operator_type_table.dart';
import 'semantic_type.dart';
import 'type_environment.dart';

final class ExpressionTypeChecker {
  final ResolutionResult resolution;
  final TypeEnvironment environment;
  final ClassHierarchyProvider hierarchy;
  final Map<NodeId, SemanticType> nodeTypes;
  final List<Diagnostic> diagnostics;
  final Severity Function(DiagnosticCode code) severityFor;
  final bool strictInitialization;
  final OperatorTypeTable _operatorTable = const OperatorTypeTable();
  late final CallAndOopTypeChecker _callAndOopChecker;

  ExpressionTypeChecker({
    required this.resolution,
    required this.environment,
    required this.hierarchy,
    required this.nodeTypes,
    required this.diagnostics,
    required this.severityFor,
    this.strictInitialization = true,
  }) {
    _callAndOopChecker = CallAndOopTypeChecker(
      resolution: resolution,
      hierarchy: hierarchy,
      diagnostics: diagnostics,
      severityFor: severityFor,
    );
  }

  void validateArguments(
    List<ParameterSymbol> parameters,
    List<ExpressionNode> arguments,
    Span callSpan,
  ) {
    _callAndOopChecker.validateArguments(
      parameters,
      arguments,
      callSpan,
      check,
    );
  }

  SemanticType check(ExpressionNode node) {
    final type = switch (node) {
      LiteralExpressionNode() => _checkLiteral(node),
      VariableExpressionNode() => _checkVariable(node),
      UnaryExpressionNode() => _checkUnary(node),
      BinaryExpressionNode() => _checkBinary(node),
      ParenthesizedExpressionNode() => check(node.expression),
      ArrayAccessExpressionNode() => _checkArrayAccess(node),
      FunctionCallExpressionNode() => _checkFunctionCall(node),
      InstantiationExpressionNode() =>
        _callAndOopChecker.checkInstantiation(node, check),
      MemberAccessExpressionNode() =>
        _callAndOopChecker.checkMemberAccess(node, check),
      MethodCallExpressionNode() =>
        _callAndOopChecker.checkMethodCall(node, check),
      ThisExpressionNode() => _checkThis(node),
      SuperExpressionNode() => _checkSuper(node),
    };

    nodeTypes[node.id] = type;
    return type;
  }

  SemanticType _checkLiteral(LiteralExpressionNode node) =>
      PrimitiveSemanticType(node.type);

  SemanticType _checkVariable(VariableExpressionNode node) {
    final symbol = resolution.symbolFor(node.id);
    if (symbol == null) return const ErrorSemanticType();

    if (symbol is VariableSymbol ||
        symbol is ParameterSymbol ||
        symbol is FieldSymbol) {
      _checkInitialization(symbol, node);
      final envType = environment.typeOf(symbol);
      if (envType != null) return envType;
      return _resolveSymbolType(symbol);
    }

    return const IndeterminateSemanticType();
  }

  void _checkInitialization(Symbol symbol, VariableExpressionNode node) {
    if (strictInitialization &&
        symbol is VariableSymbol &&
        !environment.isInitialized(symbol)) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.variableUsedUninitialized,
          severity: severityFor(DiagnosticCode.variableUsedUninitialized),
          span: node.span,
          arguments: {'lexeme': LexemeDiagnosticArgument(node.name)},
        ),
      );
    }
  }

  SemanticType _resolveSymbolType(Symbol symbol) {
    if (symbol is VariableSymbol) {
      final baseType = symbol.primitiveType != null
          ? PrimitiveSemanticType(symbol.primitiveType!)
          : (symbol.customTypeName != null
              ? ClassSemanticType(symbol.customTypeName!)
              : const IndeterminateSemanticType());
      if (symbol.dimensionCount > 0 && !baseType.isIndeterminate) {
        return ArraySemanticType(baseType, symbol.dimensionCount);
      }
      return baseType;
    }
    if (symbol is ParameterSymbol) {
      if (symbol.primitiveType != null) {
        final base = PrimitiveSemanticType(symbol.primitiveType!);
        return symbol.dimensionCount > 0
            ? ArraySemanticType(base, symbol.dimensionCount)
            : base;
      }
      if (symbol.customTypeName != null) {
        return ClassSemanticType(symbol.customTypeName!);
      }
    }
    return const IndeterminateSemanticType();
  }

  SemanticType _checkUnary(UnaryExpressionNode node) {
    final operandType = check(node.operand);
    final res = _operatorTable.computeUnary(node.operator, operandType);

    if (res.diagnosticCode != null) {
      diagnostics.add(
        Diagnostic(
          code: res.diagnosticCode!,
          severity: severityFor(res.diagnosticCode!),
          span: node.operatorSpan,
          arguments: {
            'lexeme': LexemeDiagnosticArgument(node.operator.name),
          },
        ),
      );
    }
    return res.resultType;
  }

  SemanticType _checkBinary(BinaryExpressionNode node) {
    final leftType = check(node.left);
    final rightType = check(node.right);
    final res = _operatorTable.computeBinary(
      node.operator,
      leftType,
      rightType,
      hierarchy: hierarchy,
    );

    if (res.diagnosticCode != null) {
      diagnostics.add(
        Diagnostic(
          code: res.diagnosticCode!,
          severity: severityFor(res.diagnosticCode!),
          span: node.operatorSpan,
          arguments: {
            'lexeme': LexemeDiagnosticArgument(node.operator.name),
          },
        ),
      );
    }
    if (res.warningCode != null) {
      diagnostics.add(
        Diagnostic(
          code: res.warningCode!,
          severity: severityFor(res.warningCode!),
          span: node.operatorSpan,
        ),
      );
    }
    return res.resultType;
  }

  SemanticType _checkArrayAccess(ArrayAccessExpressionNode node) {
    final targetType = check(node.target);

    for (final index in node.indices) {
      final indexType = check(index);
      if (!indexType.isInteger &&
          !indexType.isError &&
          !indexType.isIndeterminate) {
        diagnostics.add(
          Diagnostic(
            code: DiagnosticCode.nonIntegerArrayIndex,
            severity: severityFor(DiagnosticCode.nonIntegerArrayIndex),
            span: index.span,
          ),
        );
      }
    }

    if (targetType is ArraySemanticType) {
      if (node.indices.length != targetType.dimensions) {
        diagnostics.add(
          Diagnostic(
            code: DiagnosticCode.arrayDimensionCountMismatch,
            severity: severityFor(DiagnosticCode.arrayDimensionCountMismatch),
            span: node.span,
            arguments: {
              'lexeme': LexemeDiagnosticArgument(targetType.displayName),
            },
          ),
        );
      }
      return targetType.elementType;
    }

    return const ErrorSemanticType();
  }

  SemanticType _checkFunctionCall(FunctionCallExpressionNode node) {
    final symbol =
        resolution.symbolFor(node.id) ?? resolution.rootScope.lookup(node.name);
    if (symbol is BuiltinFunctionSymbol) {
      return _callAndOopChecker.checkBuiltinCall(symbol, node, check);
    }
    if (symbol is SubroutineSymbol) {
      return _callAndOopChecker.checkSubroutineCall(symbol, node, check);
    }
    return const ErrorSemanticType();
  }

  SemanticType _checkThis(ThisExpressionNode node) {
    final classSymbol = resolution.classFor(node.id);
    if (classSymbol != null) {
      return ClassSemanticType(classSymbol.name, classSymbol);
    }
    return const ErrorSemanticType();
  }

  SemanticType _checkSuper(SuperExpressionNode node) {
    final classSymbol = resolution.classFor(node.id);
    if (classSymbol?.superclass != null) {
      return ClassSemanticType(
        classSymbol!.superclass!.name,
        classSymbol.superclass,
      );
    }
    return const ErrorSemanticType();
  }
}
