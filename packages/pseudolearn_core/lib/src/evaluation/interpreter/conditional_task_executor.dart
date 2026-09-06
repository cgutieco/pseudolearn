import '../../domain/diagnostic.dart';
import '../../syntax/ast/ast_node.dart';
import '../events/execution_event.dart';
import '../values/comparison_evaluator.dart';
import '../values/runtime_value.dart';
import 'execution_task.dart';
import 'interpreter.dart';
import 'interpreter_frame.dart';

final class ConditionalTaskExecutor {
  static const ComparisonEvaluator _comparison = ComparisonEvaluator();

  final Interpreter engine;

  ConditionalTaskExecutor(this.engine);

  Diagnostic? pushIf(IfStatementNode node, InterpreterFrame frame) {
    frame.pushTask(FinishConditionTask(node));
    frame.pushTask(EvaluateExpressionTask(node.condition));
    return null;
  }

  void finishCondition(FinishConditionTask task, InterpreterFrame frame,
      List<ExecutionEvent> events) {
    final condition = (frame.popValue() as BooleanValue).value;
    events.add(DecisionEvaluatedEvent(
      decisionId: task.node.id,
      decisionSpan: task.node.condition.span,
      branch: condition ? DecisionBranch.affirmative : DecisionBranch.negative,
      snapshot: engine.snapshotIfObserved(),
    ));
    if (condition) {
      frame.pushBody(task.node.thenBody);
    } else if (task.node.elseBody != null) {
      frame.pushBody(task.node.elseBody!);
    }
  }

  Diagnostic? pushSwitch(SwitchStatementNode node, InterpreterFrame frame) {
    frame.pushTask(FinishSwitchSelectorTask(node));
    frame.pushTask(EvaluateExpressionTask(node.selector));
    return null;
  }

  void finishSwitchSelector(FinishSwitchSelectorTask task,
      InterpreterFrame frame, List<ExecutionEvent> events) {
    final node = task.node;
    final selector = frame.popValue();
    for (var index = 0; index < node.cases.length; index++) {
      if (!_matches(node.cases[index], selector)) continue;
      events.add(_selectionEvent(node, DecisionBranch.selectedCase, index));
      frame.pushBody(node.cases[index].body);
      return;
    }
    final defaultCase = node.defaultCase;
    if (defaultCase == null) {
      events.add(_selectionEvent(node, DecisionBranch.negative, null));
      return;
    }
    events.add(_selectionEvent(node, DecisionBranch.defaultCase, null));
    frame.pushBody(defaultCase.body);
  }

  bool _matches(SwitchCaseNode switchCase, RuntimeValue selector) =>
      switchCase.labels.any(
        (label) => _comparison.equalValues(
          selector,
          engine.expressions.literalValue(label as LiteralExpressionNode),
        ),
      );

  DecisionEvaluatedEvent _selectionEvent(
          SwitchStatementNode node, DecisionBranch branch, int? caseIndex) =>
      DecisionEvaluatedEvent(
        decisionId: node.id,
        decisionSpan: node.selector.span,
        branch: branch,
        caseIndex: caseIndex,
        snapshot: engine.snapshotIfObserved(),
      );
}
