import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_argument.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/severity.dart';
import '../../domain/span.dart';
import '../../syntax/ast/ast_node.dart';
import '../symbols/resolution_result.dart';
import '../symbols/symbol.dart';
import 'class_hierarchy_provider.dart';
import 'control_flow_type_checker.dart';
import 'declaration_type_checker.dart';
import 'expression_type_checker.dart';
import 'semantic_type.dart';
import 'type_environment.dart';
import 'type_relations.dart';

final class StatementTypeChecker {
  final ResolutionResult resolution;
  final TypeEnvironment environment;
  final ClassHierarchyProvider hierarchy;
  final ExpressionTypeChecker expressionChecker;
  final List<Diagnostic> diagnostics;
  final Severity Function(DiagnosticCode code) severityFor;
  final SemanticType? currentSubroutineReturnType;
  final bool isInsideSubroutine;
  late final ControlFlowTypeChecker _controlFlowChecker;
  late final DeclarationTypeChecker _declarationChecker;

  StatementTypeChecker({
    required this.resolution,
    required this.environment,
    required this.hierarchy,
    required this.expressionChecker,
    required this.diagnostics,
    required this.severityFor,
    this.currentSubroutineReturnType,
    this.isInsideSubroutine = false,
  }) {
    _controlFlowChecker = ControlFlowTypeChecker(
      resolution: resolution,
      environment: environment,
      hierarchy: hierarchy,
      expressionChecker: expressionChecker,
      diagnostics: diagnostics,
      severityFor: severityFor,
    );
    _declarationChecker = DeclarationTypeChecker(
      resolution: resolution,
      environment: environment,
      expressionChecker: expressionChecker,
      diagnostics: diagnostics,
      severityFor: severityFor,
    );
  }

  void check(StatementNode node) {
    switch (node) {
      case AssignmentStatementNode():
        _checkAssignment(node);
      case ReadStatementNode():
        _checkRead(node);
      case WriteStatementNode():
        _checkWrite(node);
      case CallStatementNode():
        _checkCall(node);
      case MethodCallStatementNode():
        _checkMethodCall(node);
      case IfStatementNode():
        _controlFlowChecker.checkIf(node, check);
      case WhileStatementNode():
        _controlFlowChecker.checkWhile(node, check);
      case RepeatUntilStatementNode():
        _controlFlowChecker.checkRepeat(node, check);
      case ForStatementNode():
        _controlFlowChecker.checkFor(node, check);
      case SwitchStatementNode():
        _controlFlowChecker.checkSwitch(node, check);
      case ReturnStatementNode():
        _checkReturn(node);
      case VariableDeclarationNode():
        _declarationChecker.checkVarDeclaration(node);
      case DimensionStatementNode():
        _declarationChecker.checkDimension(node);
      case ErrorStatementNode():
        break;
    }
  }

  void _checkAssignment(AssignmentStatementNode node) {
    final valueType = expressionChecker.check(node.value);

    if (node.target is VariableExpressionNode) {
      final varNode = node.target as VariableExpressionNode;
      final symbol = resolution.symbolFor(varNode.id);
      if (symbol != null) {
        environment.recordAssignment(symbol, valueType, node.span);
        expressionChecker.nodeTypes[varNode.id] =
            environment.typeOf(symbol) ?? valueType;
      }
      return;
    }

    if (node.target is ArrayAccessExpressionNode) {
      final arrayAccess = node.target as ArrayAccessExpressionNode;
      final elemType = expressionChecker.check(arrayAccess);
      _checkAssignmentCompatibility(elemType, valueType, node.span);
      return;
    }

    if (node.target is MemberAccessExpressionNode) {
      final memberAccess = node.target as MemberAccessExpressionNode;
      final fieldType = expressionChecker.check(memberAccess);
      _checkAssignmentCompatibility(fieldType, valueType, node.span);
    }
  }

  void _checkAssignmentCompatibility(
    SemanticType targetType,
    SemanticType valueType,
    Span span,
  ) {
    if (valueType.isError || valueType.isIndeterminate) return;
    if (targetType.isError || targetType.isIndeterminate) return;

    if (!TypeRelations.isAssignable(valueType, targetType,
        hierarchy: hierarchy)) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.incompatibleTypesInAssignment,
          severity: severityFor(DiagnosticCode.incompatibleTypesInAssignment),
          span: span,
          arguments: {
            'expected': targetType is PrimitiveSemanticType
                ? TypeDiagnosticArgument(targetType.primitive)
                : LexemeDiagnosticArgument(targetType.displayName),
            'found': valueType is PrimitiveSemanticType
                ? TypeDiagnosticArgument(valueType.primitive)
                : LexemeDiagnosticArgument(valueType.displayName),
          },
        ),
      );
    }
  }

  void _checkRead(ReadStatementNode node) {
    for (final target in node.targets) {
      _checkReadTarget(target);
    }
  }

  void _checkReadTarget(ExpressionNode target) {
    if (target is! VariableExpressionNode) {
      expressionChecker.check(target);
      return;
    }

    final symbol = resolution.symbolFor(target.id);
    if (symbol == null) return;

    if (environment.typeOf(symbol) == null) {
      environment.declare(
        symbol,
        const IndeterminateSemanticType(),
        isExplicit: false,
        isInitialized: true,
      );
    } else {
      environment.markInitialized(symbol);
    }
    expressionChecker.nodeTypes[target.id] = environment.typeOf(symbol)!;
  }

  void _checkWrite(WriteStatementNode node) {
    for (final expr in node.expressions) {
      final type = expressionChecker.check(expr);
      if (type is ArraySemanticType) {
        diagnostics.add(
          Diagnostic(
            code: DiagnosticCode.arrayCannotBeUsedAsValue,
            severity: severityFor(DiagnosticCode.arrayCannotBeUsedAsValue),
            span: expr.span,
          ),
        );
      } else if (type is ClassSemanticType) {
        diagnostics.add(
          Diagnostic(
            code: DiagnosticCode.objectCannotBeWritten,
            severity: severityFor(DiagnosticCode.objectCannotBeWritten),
            span: expr.span,
          ),
        );
      }
    }
  }

  void _checkCall(CallStatementNode node) {
    final sym =
        resolution.symbolFor(node.id) ?? resolution.rootScope.lookup(node.name);
    if (sym is SubroutineSymbol) {
      if (sym.returnType != null || sym.customReturnType != null) {
        diagnostics.add(
          Diagnostic(
            code: DiagnosticCode.discardedReturnValue,
            severity: severityFor(DiagnosticCode.discardedReturnValue),
            span: node.span,
            arguments: {'lexeme': LexemeDiagnosticArgument(node.name)},
          ),
        );
      }
      expressionChecker.validateArguments(
        sym.parameters,
        node.arguments,
        node.span,
      );
    }
  }

  void _checkMethodCall(MethodCallStatementNode node) {
    final targetType = expressionChecker.check(node.target);
    if (targetType is! ClassSemanticType) return;

    final sym = resolution.rootScope.lookup(targetType.className);
    if (sym is! ClassSymbol) return;

    final method = sym.findMethod(node.methodName);
    if (method != null) {
      if (method.returnType != null || method.customReturnType != null) {
        diagnostics.add(
          Diagnostic(
            code: DiagnosticCode.discardedReturnValue,
            severity: severityFor(DiagnosticCode.discardedReturnValue),
            span: node.span,
            arguments: {'lexeme': LexemeDiagnosticArgument(node.methodName)},
          ),
        );
      }
      expressionChecker.validateArguments(
        method.parameters,
        node.arguments,
        node.span,
      );
    }
  }

  void _checkReturn(ReturnStatementNode node) {
    if (!isInsideSubroutine) return;

    final expected = currentSubroutineReturnType;
    if (expected != null && !expected.isVoid) {
      _checkNonVoidReturn(node, expected);
    } else if (node.value != null) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.returnExpressionInVoidSubroutine,
          severity:
              severityFor(DiagnosticCode.returnExpressionInVoidSubroutine),
          span: node.span,
        ),
      );
    }
  }

  void _checkNonVoidReturn(ReturnStatementNode node, SemanticType expected) {
    if (node.value == null) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.missingReturnExpression,
          severity: severityFor(DiagnosticCode.missingReturnExpression),
          span: node.span,
        ),
      );
      return;
    }
    final returnType = expressionChecker.check(node.value!);
    if (!TypeRelations.isConvertibleTo(returnType, expected,
        hierarchy: hierarchy)) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.incompatibleReturnType,
          severity: severityFor(DiagnosticCode.incompatibleReturnType),
          span: node.span,
        ),
      );
    }
  }
}
