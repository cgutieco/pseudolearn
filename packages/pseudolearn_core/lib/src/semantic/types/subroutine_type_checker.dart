import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_argument.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/node_id.dart';
import '../../domain/profile/semantic_profile.dart';
import '../../domain/severity.dart';
import '../../domain/span.dart';
import '../../syntax/ast/ast_node.dart';
import '../symbols/resolution_result.dart';
import '../symbols/symbol.dart';
import 'class_hierarchy_provider.dart';
import 'expression_type_checker.dart';
import 'semantic_type.dart';
import 'statement_type_checker.dart';
import 'type_environment.dart';

final class SubroutineTypeChecker {
  final ResolutionResult resolution;
  final SemanticProfile profile;
  final ClassHierarchyProvider hierarchy;
  final Map<NodeId, SemanticType> nodeTypes;
  final List<Diagnostic> diagnostics;
  final Severity Function(DiagnosticCode code) severityFor;
  final bool strictInitialization;

  const SubroutineTypeChecker({
    required this.resolution,
    required this.profile,
    required this.hierarchy,
    required this.nodeTypes,
    required this.diagnostics,
    required this.severityFor,
    required this.strictInitialization,
  });

  void checkSubroutine(SubroutineDeclarationNode subroutine) {
    final env = TypeEnvironment(
      hierarchy: hierarchy,
      diagnostics: diagnostics,
      severityFor: severityFor,
    );

    final sym = resolution.symbolFor(subroutine.id) ??
        resolution.rootScope.lookup(subroutine.name);
    if (sym is SubroutineSymbol) {
      _declareParameters(env, sym.parameters);
    }

    final returnType = subroutine.returnType != null
        ? PrimitiveSemanticType(subroutine.returnType!)
        : (subroutine.customReturnType != null
            ? ClassSemanticType(subroutine.customReturnType!)
            : const VoidSemanticType());

    _validateSubroutineReturn(
        subroutine.name, subroutine.nameSpan, returnType, subroutine.body);
    _executeStatementCheck(env, subroutine.body, returnType);
  }

  void checkMethod(ClassNode classNode, MethodDeclarationNode method) {
    final env = TypeEnvironment(
      hierarchy: hierarchy,
      diagnostics: diagnostics,
      severityFor: severityFor,
    );

    final classSym = resolution.classFor(classNode.id) ??
        resolution.rootScope.lookup(classNode.name);
    if (classSym is ClassSymbol) {
      final methodSym = classSym.findMethod(method.name);
      if (methodSym != null) {
        _declareParameters(env, methodSym.parameters);
      }
    }

    final returnType = method.returnType != null
        ? PrimitiveSemanticType(method.returnType!)
        : (method.customReturnType != null
            ? ClassSemanticType(method.customReturnType!)
            : const VoidSemanticType());

    _validateSubroutineReturn(
        method.name, method.nameSpan, returnType, method.body);
    _executeStatementCheck(env, method.body, returnType);
  }

  void checkConstructor(
      ClassNode classNode, ConstructorDeclarationNode constructor) {
    final env = TypeEnvironment(
      hierarchy: hierarchy,
      diagnostics: diagnostics,
      severityFor: severityFor,
    );

    final classSym = resolution.classFor(classNode.id) ??
        resolution.rootScope.lookup(classNode.name);
    if (classSym is ClassSymbol && classSym.constructor != null) {
      _declareParameters(env, classSym.constructor!.parameters);
    }

    _executeStatementCheck(env, constructor.body, const VoidSemanticType());
  }

  void _declareParameters(
      TypeEnvironment env, List<ParameterSymbol> parameters) {
    for (final param in parameters) {
      final baseType = param.primitiveType != null
          ? PrimitiveSemanticType(param.primitiveType!)
          : (param.customTypeName != null
              ? ClassSemanticType(param.customTypeName!)
              : const IndeterminateSemanticType());
      final paramType = (baseType is! IndeterminateSemanticType &&
              param.dimensionCount > 0)
          ? ArraySemanticType(baseType, param.dimensionCount)
          : baseType;
      env.declare(param, paramType, isExplicit: true, isInitialized: true);
    }
  }

  void _validateSubroutineReturn(
    String name,
    Span span,
    SemanticType returnType,
    List<StatementNode> body,
  ) {
    if (!returnType.isVoid && !_hasReturnStatement(body)) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.subroutineWithoutReturn,
          severity: severityFor(DiagnosticCode.subroutineWithoutReturn),
          span: span,
          arguments: {'lexeme': LexemeDiagnosticArgument(name)},
        ),
      );
    }
  }

  void _executeStatementCheck(
    TypeEnvironment env,
    List<StatementNode> body,
    SemanticType returnType,
  ) {
    final exprChecker = ExpressionTypeChecker(
      resolution: resolution,
      environment: env,
      hierarchy: hierarchy,
      nodeTypes: nodeTypes,
      diagnostics: diagnostics,
      severityFor: severityFor,
      strictInitialization: strictInitialization,
    );

    final stmtChecker = StatementTypeChecker(
      resolution: resolution,
      environment: env,
      hierarchy: hierarchy,
      expressionChecker: exprChecker,
      diagnostics: diagnostics,
      severityFor: severityFor,
      currentSubroutineReturnType: returnType,
      isInsideSubroutine: true,
    );

    for (final stmt in body) {
      stmtChecker.check(stmt);
    }
  }

  bool _hasReturnStatement(List<StatementNode> statements) {
    for (final stmt in statements) {
      if (stmt is ReturnStatementNode) return true;
      if (_hasReturnInControlFlow(stmt)) return true;
    }
    return false;
  }

  bool _hasReturnInControlFlow(StatementNode stmt) => switch (stmt) {
        IfStatementNode(:final thenBody, :final elseBody) =>
          _hasReturnStatement(thenBody) ||
              (elseBody != null && _hasReturnStatement(elseBody)),
        WhileStatementNode(:final body) => _hasReturnStatement(body),
        RepeatUntilStatementNode(:final body) => _hasReturnStatement(body),
        ForStatementNode(:final body) => _hasReturnStatement(body),
        SwitchStatementNode(:final cases, :final defaultCase) =>
          _hasReturnInSwitch(cases, defaultCase),
        _ => false,
      };

  bool _hasReturnInSwitch(
    List<SwitchCaseNode> cases,
    SwitchDefaultNode? defaultCase,
  ) {
    for (final kase in cases) {
      if (_hasReturnStatement(kase.body)) return true;
    }
    return defaultCase != null && _hasReturnStatement(defaultCase.body);
  }
}
