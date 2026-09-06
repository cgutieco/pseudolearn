import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/severity.dart';
import '../../syntax/ast/ast_node.dart';
import '../symbols/resolution_result.dart';
import 'class_hierarchy_provider.dart';
import 'expression_type_checker.dart';
import 'semantic_type.dart';
import 'type_environment.dart';
import 'type_relations.dart';

final class ControlFlowTypeChecker {
  final ResolutionResult resolution;
  final TypeEnvironment environment;
  final ClassHierarchyProvider hierarchy;
  final ExpressionTypeChecker expressionChecker;
  final List<Diagnostic> diagnostics;
  final Severity Function(DiagnosticCode code) severityFor;

  const ControlFlowTypeChecker({
    required this.resolution,
    required this.environment,
    required this.hierarchy,
    required this.expressionChecker,
    required this.diagnostics,
    required this.severityFor,
  });

  void checkIf(IfStatementNode node, void Function(StatementNode) checkStmt) {
    _checkCondition(node.condition);
    for (final stmt in node.thenBody) {
      checkStmt(stmt);
    }
    if (node.elseBody != null) {
      for (final stmt in node.elseBody!) {
        checkStmt(stmt);
      }
    }
  }

  void checkWhile(
      WhileStatementNode node, void Function(StatementNode) checkStmt) {
    _checkCondition(node.condition);
    for (final stmt in node.body) {
      checkStmt(stmt);
    }
  }

  void checkRepeat(
      RepeatUntilStatementNode node, void Function(StatementNode) checkStmt) {
    for (final stmt in node.body) {
      checkStmt(stmt);
    }
    _checkCondition(node.condition);
  }

  void checkFor(ForStatementNode node, void Function(StatementNode) checkStmt) {
    final symbol = resolution.symbolFor(node.variable.id);
    if (symbol != null) {
      environment.markInitialized(symbol);
    }

    final fromType = expressionChecker.check(node.from);
    final toType = expressionChecker.check(node.to);
    final stepType =
        node.step != null ? expressionChecker.check(node.step!) : null;

    final varType = symbol != null ? environment.typeOf(symbol) : null;
    final isVarValid = varType == null || varType.isInteger || varType.isError;

    if (!isVarValid ||
        (!fromType.isInteger && !fromType.isError) ||
        (!toType.isInteger && !toType.isError) ||
        (stepType != null && !stepType.isInteger && !stepType.isError)) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.nonIntegerForBound,
          severity: severityFor(DiagnosticCode.nonIntegerForBound),
          span: node.span,
        ),
      );
    }

    for (final stmt in node.body) {
      checkStmt(stmt);
    }
  }

  void checkSwitch(
      SwitchStatementNode node, void Function(StatementNode) checkStmt) {
    final selectorType = expressionChecker.check(node.selector);
    for (final kase in node.cases) {
      _checkSwitchCase(kase, selectorType, checkStmt);
    }
    if (node.defaultCase != null) {
      for (final stmt in node.defaultCase!.body) {
        checkStmt(stmt);
      }
    }
  }

  void _checkCondition(ExpressionNode condition) {
    final condType = expressionChecker.check(condition);
    if (!condType.isBoolean && !condType.isError && !condType.isIndeterminate) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.nonBooleanCondition,
          severity: severityFor(DiagnosticCode.nonBooleanCondition),
          span: condition.span,
        ),
      );
    }
  }

  void _checkSwitchCase(
    SwitchCaseNode kase,
    SemanticType selectorType,
    void Function(StatementNode) checkStmt,
  ) {
    for (final label in kase.labels) {
      _checkSwitchLabel(label, selectorType);
    }
    for (final stmt in kase.body) {
      checkStmt(stmt);
    }
  }

  void _checkSwitchLabel(ExpressionNode label, SemanticType selectorType) {
    final labelType = expressionChecker.check(label);
    final isInvalid = labelType.isReal ||
        !TypeRelations.areComparable(selectorType, labelType,
            hierarchy: hierarchy);
    if (isInvalid) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.incompatibleSwitchCaseType,
          severity: severityFor(DiagnosticCode.incompatibleSwitchCaseType),
          span: label.span,
        ),
      );
    }
  }
}
