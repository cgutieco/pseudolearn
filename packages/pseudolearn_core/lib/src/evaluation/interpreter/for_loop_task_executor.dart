import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/pseudo_integer.dart';
import '../../domain/span.dart';
import '../../syntax/ast/ast_node.dart';
import '../events/execution_event.dart';
import '../values/integer_arithmetic.dart';
import '../values/runtime_value.dart';
import 'execution_task.dart';
import 'interpreter.dart';
import 'interpreter_frame.dart';

final class ForLoopTaskExecutor {
  static const IntegerArithmetic _integerArithmetic = IntegerArithmetic();

  final Interpreter engine;

  ForLoopTaskExecutor(this.engine);

  Diagnostic? pushFor(ForStatementNode node, InterpreterFrame frame) {
    frame.pushTask(SetUpForLoopTask(node));
    if (node.step != null) frame.pushTask(EvaluateExpressionTask(node.step!));
    frame.pushTask(EvaluateExpressionTask(node.to));
    frame.pushTask(EvaluateExpressionTask(node.from));
    return null;
  }

  Diagnostic? setUpForLoop(SetUpForLoopTask task, InterpreterFrame frame) {
    final node = task.node;
    final step = node.step != null
        ? (frame.popValue() as IntegerValue).value
        : PseudoInteger.one;
    final to = (frame.popValue() as IntegerValue).value;
    final from = (frame.popValue() as IntegerValue).value;

    if (step == PseudoInteger.zero) {
      return engine.diagnostic(
          DiagnosticCode.zeroStepInCountedLoop, (node.step ?? node.from).span);
    }

    final symbol = engine.program.resolution.symbolFor(node.variable.id)!;
    frame.environment.scope.cellFor(symbol).assign(IntegerValue(from));
    frame.pushTask(CheckForConditionTask(node, to: to, step: step));
    return null;
  }

  void checkForCondition(CheckForConditionTask task, InterpreterFrame frame,
      List<ExecutionEvent> events) {
    final symbol = engine.program.resolution.symbolFor(task.node.variable.id)!;
    final current =
        (frame.environment.scope.cellFor(symbol).value as IntegerValue).value;
    final continues = task.step.isNegative
        ? current.compareTo(task.to) >= 0
        : current.compareTo(task.to) <= 0;
    events.add(DecisionEvaluatedEvent(
      decisionId: task.node.id,
      decisionSpan: _headerSpan(task.node),
      branch: continues ? DecisionBranch.affirmative : DecisionBranch.negative,
      snapshot: engine.snapshotIfObserved(),
    ));
    if (!continues) return;

    frame.pushTask(AdvanceForLoopTask(task.node, to: task.to, step: task.step));
    frame.pushBody(task.node.body);
  }

  Span _headerSpan(ForStatementNode node) =>
      Span(start: node.span.start, end: (node.step ?? node.to).span.end);

  Diagnostic? advanceForLoop(AdvanceForLoopTask task, InterpreterFrame frame) {
    final symbol = engine.program.resolution.symbolFor(task.node.variable.id)!;
    final cell = frame.environment.scope.cellFor(symbol);
    final current = (cell.value as IntegerValue).value;
    final next = _integerArithmetic.add(current, task.step);
    if (next == null) {
      return engine.diagnostic(DiagnosticCode.integerOverflow, task.node.span);
    }
    cell.assign(IntegerValue(next));
    frame.pushTask(
        CheckForConditionTask(task.node, to: task.to, step: task.step));
    return null;
  }
}
