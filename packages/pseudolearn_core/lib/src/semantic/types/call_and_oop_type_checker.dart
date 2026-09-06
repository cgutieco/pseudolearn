import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_argument.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/severity.dart';
import '../../domain/span.dart';
import '../../syntax/ast/ast_node.dart';
import '../symbols/resolution_result.dart';
import '../symbols/symbol.dart';
import 'builtin_call_type_checker.dart';
import 'class_hierarchy_provider.dart';
import 'semantic_type.dart';
import 'type_relations.dart';

final class CallAndOopTypeChecker {
  final ResolutionResult resolution;
  final ClassHierarchyProvider hierarchy;
  final List<Diagnostic> diagnostics;
  final Severity Function(DiagnosticCode code) severityFor;
  late final BuiltinCallTypeChecker _builtinChecker;

  CallAndOopTypeChecker({
    required this.resolution,
    required this.hierarchy,
    required this.diagnostics,
    required this.severityFor,
  }) {
    _builtinChecker = BuiltinCallTypeChecker(
      hierarchy: hierarchy,
      diagnostics: diagnostics,
      severityFor: severityFor,
    );
  }

  SemanticType checkBuiltinCall(
    BuiltinFunctionSymbol symbol,
    FunctionCallExpressionNode node,
    SemanticType Function(ExpressionNode) evaluate,
  ) =>
      _builtinChecker.check(symbol, node, evaluate);

  SemanticType checkSubroutineCall(
    SubroutineSymbol symbol,
    FunctionCallExpressionNode node,
    SemanticType Function(ExpressionNode) evaluate,
  ) {
    if (symbol.returnType == null && symbol.customReturnType == null) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.callAsExpressionWithoutReturnType,
          severity:
              severityFor(DiagnosticCode.callAsExpressionWithoutReturnType),
          span: node.span,
          arguments: {'lexeme': LexemeDiagnosticArgument(symbol.name)},
        ),
      );
    }

    validateArguments(
      symbol.parameters,
      node.arguments,
      node.span,
      evaluate,
    );

    if (symbol.returnType != null) {
      return PrimitiveSemanticType(symbol.returnType!);
    }
    if (symbol.customReturnType != null) {
      return ClassSemanticType(symbol.customReturnType!);
    }
    return const VoidSemanticType();
  }

  void validateArguments(
    List<ParameterSymbol> parameters,
    List<ExpressionNode> arguments,
    Span callSpan,
    SemanticType Function(ExpressionNode) evaluate,
  ) {
    if (parameters.length != arguments.length) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.argumentCountMismatch,
          severity: severityFor(DiagnosticCode.argumentCountMismatch),
          span: callSpan,
          arguments: {
            'expected': NumberDiagnosticArgument(parameters.length),
            'found': NumberDiagnosticArgument(arguments.length),
          },
        ),
      );
      return;
    }

    for (var i = 0; i < parameters.length; i++) {
      final param = parameters[i];
      final arg = arguments[i];
      final argType = evaluate(arg);
      final paramType = _resolveParameterType(param);

      if (param.passingMode == ParameterPassingMode.byReference) {
        _validateByRefArgument(param, arg, argType, paramType);
      } else {
        _validateByValArgument(param, arg, argType, paramType);
      }
    }
  }

  SemanticType _resolveParameterType(ParameterSymbol param) {
    final baseType = param.primitiveType != null
        ? PrimitiveSemanticType(param.primitiveType!)
        : (param.customTypeName != null
            ? ClassSemanticType(param.customTypeName!)
            : const IndeterminateSemanticType());

    if (baseType is IndeterminateSemanticType) {
      return baseType;
    }

    return param.dimensionCount > 0
        ? ArraySemanticType(baseType, param.dimensionCount)
        : baseType;
  }

  void _validateByRefArgument(
    ParameterSymbol param,
    ExpressionNode arg,
    SemanticType argType,
    SemanticType paramType,
  ) {
    final isDesignator = arg is VariableExpressionNode ||
        arg is ArrayAccessExpressionNode ||
        arg is MemberAccessExpressionNode;

    if (!isDesignator) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.byReferenceArgumentRequiresDesignator,
          severity:
              severityFor(DiagnosticCode.byReferenceArgumentRequiresDesignator),
          span: arg.span,
        ),
      );
      return;
    }

    if (!TypeRelations.areIdentical(argType, paramType)) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.byReferenceArgumentTypeMismatch,
          severity: severityFor(DiagnosticCode.byReferenceArgumentTypeMismatch),
          span: arg.span,
          arguments: {'lexeme': LexemeDiagnosticArgument(param.name)},
        ),
      );
    }
  }

  void _validateByValArgument(
    ParameterSymbol param,
    ExpressionNode arg,
    SemanticType argType,
    SemanticType paramType,
  ) {
    if (!TypeRelations.isConvertibleTo(argType, paramType,
        hierarchy: hierarchy)) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.incompatibleArgumentType,
          severity: severityFor(DiagnosticCode.incompatibleArgumentType),
          span: arg.span,
          arguments: {'lexeme': LexemeDiagnosticArgument(param.name)},
        ),
      );
    }
  }

  SemanticType checkInstantiation(
    InstantiationExpressionNode node,
    SemanticType Function(ExpressionNode) evaluate,
  ) {
    final sym = resolution.rootScope.lookup(node.className);
    if (sym is! ClassSymbol) return const ErrorSemanticType();

    final constructor = sym.constructor;
    if (constructor != null) {
      validateArguments(
        constructor.parameters,
        node.arguments,
        node.span,
        evaluate,
      );
    } else if (node.arguments.isNotEmpty) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.argumentCountMismatch,
          severity: severityFor(DiagnosticCode.argumentCountMismatch),
          span: node.span,
          arguments: {
            'expected': const NumberDiagnosticArgument(0),
            'found': NumberDiagnosticArgument(node.arguments.length),
          },
        ),
      );
    }

    return ClassSemanticType(node.className, sym);
  }

  SemanticType checkMemberAccess(
    MemberAccessExpressionNode node,
    SemanticType Function(ExpressionNode) evaluate,
  ) {
    final targetType = evaluate(node.target);
    if (targetType is! ClassSemanticType) return const ErrorSemanticType();

    final sym = resolution.rootScope.lookup(targetType.className);
    if (sym is! ClassSymbol) return const ErrorSemanticType();

    final field = sym.findField(node.memberName);
    if (field != null) {
      return field.primitiveType != null
          ? PrimitiveSemanticType(field.primitiveType!)
          : (field.customTypeName != null
              ? ClassSemanticType(field.customTypeName!)
              : const IndeterminateSemanticType());
    }

    return const ErrorSemanticType();
  }

  SemanticType checkMethodCall(
    MethodCallExpressionNode node,
    SemanticType Function(ExpressionNode) evaluate,
  ) {
    final targetType = evaluate(node.target);
    if (targetType is! ClassSemanticType) return const ErrorSemanticType();

    final sym = resolution.rootScope.lookup(targetType.className);
    if (sym is! ClassSymbol) return const ErrorSemanticType();

    final method = sym.findMethod(node.methodName);
    if (method == null) return const ErrorSemanticType();

    if (method.returnType == null && method.customReturnType == null) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.callAsExpressionWithoutReturnType,
          severity:
              severityFor(DiagnosticCode.callAsExpressionWithoutReturnType),
          span: node.span,
          arguments: {'lexeme': LexemeDiagnosticArgument(method.name)},
        ),
      );
    }

    validateArguments(
      method.parameters,
      node.arguments,
      node.span,
      evaluate,
    );

    if (method.returnType != null) {
      return PrimitiveSemanticType(method.returnType!);
    }
    if (method.customReturnType != null) {
      return ClassSemanticType(method.customReturnType!);
    }
    return const VoidSemanticType();
  }
}
