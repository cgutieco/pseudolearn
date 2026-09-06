import '../../domain/diagnostic.dart';
import '../../domain/node_id.dart';
import '../../domain/span.dart';
import '../../syntax/ast/ast_node.dart';
import '../events/execution_event.dart';
import '../values/runtime_value.dart';
import 'execution_task.dart';
import 'interpreter.dart';
import 'interpreter_frame.dart';

final class LoopTaskExecutor {
  final Interpreter engine;

  LoopTaskExecutor(this.engine);

  Diagnostic? pushWhile(WhileStatementNode node, InterpreterFrame frame) {
    frame.pushTask(RunWhileTask(node));
    return null;
  }

  void runWhile(RunWhileTask task, InterpreterFrame frame) {
    frame.pushTask(FinishWhileConditionTask(task.node));
    frame.pushTask(EvaluateExpressionTask(task.node.condition));
  }

  void finishWhileCondition(FinishWhileConditionTask task,
      InterpreterFrame frame, List<ExecutionEvent> events) {
    final condition = (frame.popValue() as BooleanValue).value;
    events.add(_conditionEvent(
        task.node.id, task.node.condition.span, holds: condition));
    if (!condition) return;
    frame.pushTask(RunWhileTask(task.node));
    frame.pushBody(task.node.body);
  }

  Diagnostic? pushRepeat(
      RepeatUntilStatementNode node, InterpreterFrame frame) {
    frame.pushTask(RunRepeatBodyTask(node));
    return null;
  }

  void runRepeatBody(RunRepeatBodyTask task, InterpreterFrame frame) {
    frame.pushTask(FinishRepeatConditionTask(task.node));
    frame.pushTask(EvaluateExpressionTask(task.node.condition));
    frame.pushBody(task.node.body);
  }

  void finishRepeatCondition(FinishRepeatConditionTask task,
      InterpreterFrame frame, List<ExecutionEvent> events) {
    final stopsNow = (frame.popValue() as BooleanValue).value;
    events.add(_conditionEvent(
        task.node.id, task.node.condition.span, holds: stopsNow));
    if (stopsNow) return;
    frame.pushTask(RunRepeatBodyTask(task.node));
  }

  DecisionEvaluatedEvent _conditionEvent(NodeId id, Span span,
          {required bool holds}) =>
      DecisionEvaluatedEvent(
        decisionId: id,
        decisionSpan: span,
        branch: holds ? DecisionBranch.affirmative : DecisionBranch.negative,
        snapshot: engine.snapshotIfObserved(),
      );
}
