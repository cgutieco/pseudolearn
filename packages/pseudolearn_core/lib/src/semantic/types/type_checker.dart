import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/node_id.dart';
import '../../domain/profile/semantic_profile.dart';
import '../../domain/severity.dart';
import '../../syntax/ast/ast_node.dart';
import '../symbols/resolution_result.dart';
import 'class_hierarchy_provider.dart';
import 'expression_type_checker.dart';
import 'scope_class_hierarchy_provider.dart';
import 'semantic_type.dart';
import 'statement_type_checker.dart';
import 'subroutine_type_checker.dart';
import 'type_check_result.dart';
import 'type_environment.dart';

final class TypeChecker {
  final ResolutionResult resolution;
  final SemanticProfile profile;
  final bool strictInitialization;
  final List<Diagnostic> _diagnostics = [];
  final Map<NodeId, SemanticType> _nodeTypes = {};
  late final ClassHierarchyProvider _hierarchy;
  late final SubroutineTypeChecker _subroutineChecker;

  TypeChecker({
    required this.resolution,
    required this.profile,
    bool? strictInitialization,
  }) : strictInitialization =
            strictInitialization ?? profile.mandatoryInitialization {
    _hierarchy = ScopeClassHierarchyProvider(resolution.rootScope);
    _subroutineChecker = SubroutineTypeChecker(
      resolution: resolution,
      profile: profile,
      hierarchy: _hierarchy,
      nodeTypes: _nodeTypes,
      diagnostics: _diagnostics,
      severityFor: severityFor,
      strictInitialization: this.strictInitialization,
    );
  }

  Severity severityFor(DiagnosticCode code) =>
      profile.severityPolicy[code] ?? Severity.error;

  TypeCheckResult check(SourceUnitNode sourceUnit) {
    _diagnostics.addAll(resolution.diagnostics);

    if (sourceUnit.algorithm != null) {
      _checkAlgorithm(sourceUnit.algorithm!);
    }

    for (final subroutine in sourceUnit.subroutines) {
      _subroutineChecker.checkSubroutine(subroutine);
    }

    for (final classNode in sourceUnit.classes) {
      _checkClass(classNode);
    }

    return TypeCheckResult(
      nodeTypes: _nodeTypes,
      diagnostics: _diagnostics,
    );
  }

  void _checkAlgorithm(AlgorithmNode algorithm) {
    final env = TypeEnvironment(
      hierarchy: _hierarchy,
      diagnostics: _diagnostics,
      severityFor: severityFor,
    );

    final exprChecker = ExpressionTypeChecker(
      resolution: resolution,
      environment: env,
      hierarchy: _hierarchy,
      nodeTypes: _nodeTypes,
      diagnostics: _diagnostics,
      severityFor: severityFor,
      strictInitialization: strictInitialization,
    );

    final stmtChecker = StatementTypeChecker(
      resolution: resolution,
      environment: env,
      hierarchy: _hierarchy,
      expressionChecker: exprChecker,
      diagnostics: _diagnostics,
      severityFor: severityFor,
    );

    for (final stmt in algorithm.body) {
      stmtChecker.check(stmt);
    }
  }

  void _checkClass(ClassNode classNode) {
    for (final member in classNode.members) {
      switch (member) {
        case MethodDeclarationNode():
          _subroutineChecker.checkMethod(classNode, member);
        case ConstructorDeclarationNode():
          _subroutineChecker.checkConstructor(classNode, member);
        case ClassFieldNode():
          break;
      }
    }
  }
}
