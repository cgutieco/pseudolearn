import '../../domain/diagnostic.dart';
import '../events/execution_event.dart';
import 'execution_task.dart';
import 'interpreter.dart';
import 'interpreter_frame.dart';

final class TaskDispatcher {
  final Interpreter engine;

  TaskDispatcher(this.engine);

  Diagnostic? dispatch(
    ExecutionTask task,
    InterpreterFrame frame,
    List<ExecutionEvent> events,
  ) =>
      _dispatchStatement(task, frame, events) ??
      _dispatchExpression(task, frame, events) ??
      _dispatchOop(task, frame, events) ??
      _dispatchControlFlow(task, frame, events);

  Diagnostic? _dispatchStatement(
    ExecutionTask task,
    InterpreterFrame frame,
    List<ExecutionEvent> events,
  ) =>
      switch (task) {
        RunStatementTask() => engine.statements.run(task, frame, events),
        StatementExitMarkerTask() => _noFail(() => events.add(
              StatementExitedEvent(
                statementId: task.statement.id,
                snapshot: engine.snapshotIfObserved(),
              ),
            )),
        FinishAssignmentTask() => engine.statements.finishAssignment(task, frame),
        FinishWriteItemTask() =>
          _noFail(() => engine.statements.finishWriteItem(frame, events)),
        EmitNewlineIfNeededTask() =>
          _noFail(() => engine.statements.emitNewlineIfNeeded(task, events)),
        BeginInputTask() =>
          _noFail(() => engine.statements.beginInput(task, frame)),
        FinishReturnTask() => engine.statements.finishReturn(task, frame),
        FinishArrayDeclarationTask() =>
          engine.statements.finishArrayDeclaration(task, frame),
        _ => null,
      };

  Diagnostic? _dispatchExpression(
    ExecutionTask task,
    InterpreterFrame frame,
    List<ExecutionEvent> events,
  ) =>
      switch (task) {
        EvaluateExpressionTask() => engine.expressions.evaluate(task, frame),
        ResolveReferenceTask() => engine.expressions.resolveReference(task, frame),
        FinishArrayReferenceTask() =>
          engine.arrayAccess.finishArrayReference(task, frame),
        FinishUnaryTask() => engine.arithmetic.finishUnary(task, frame),
        FinishBinaryTask() => engine.arithmetic.finishBinary(task, frame),
        EvaluateLogicalRightTask() =>
          _noFail(() => engine.arithmetic.evaluateLogicalRight(task, frame)),
        FinishLogicalTask() =>
          _noFail(() => engine.arithmetic.finishLogical(task, frame)),
        FinishArrayAccessTask() => engine.arrayAccess.finishArrayAccess(task, frame),
        DispatchCallTask() => engine.calls.dispatch(task, frame, events),
        ResolveArrayArgumentTask() =>
          _noFail(() => engine.calls.resolveArrayArgument(task, frame)),
        _ => null,
      };

  Diagnostic? _dispatchOop(
    ExecutionTask task,
    InterpreterFrame frame,
    List<ExecutionEvent> events,
  ) =>
      switch (task) {
        FinishInstantiationTask() =>
          engine.oop.finishInstantiation(task, frame, events),
        FinishMemberAccessTask() =>
          engine.memberAccess.finishMemberAccess(task, frame),
        FinishMemberReferenceTask() =>
          engine.memberAccess.finishMemberReference(task, frame),
        DispatchMethodCallTask() =>
          engine.methodCalls.dispatchMethodCall(task, frame, events),
        FinishSuperConstructorTask() =>
          engine.methodCalls.finishSuperConstructor(task, frame, events),
        _ => null,
      };

  Diagnostic? _dispatchControlFlow(
    ExecutionTask task,
    InterpreterFrame frame,
    List<ExecutionEvent> events,
  ) =>
      switch (task) {
        FinishConditionTask() => _noFail(
            () => engine.conditionals.finishCondition(task, frame, events)),
        FinishSwitchSelectorTask() => _noFail(
            () => engine.conditionals.finishSwitchSelector(task, frame, events)),
        RunWhileTask() => _noFail(() => engine.loops.runWhile(task, frame)),
        FinishWhileConditionTask() => _noFail(
            () => engine.loops.finishWhileCondition(task, frame, events)),
        RunRepeatBodyTask() => _noFail(() => engine.loops.runRepeatBody(task, frame)),
        FinishRepeatConditionTask() => _noFail(
            () => engine.loops.finishRepeatCondition(task, frame, events)),
        SetUpForLoopTask() => engine.forLoop.setUpForLoop(task, frame),
        CheckForConditionTask() => _noFail(
            () => engine.forLoop.checkForCondition(task, frame, events)),
        AdvanceForLoopTask() => engine.forLoop.advanceForLoop(task, frame),
        _ => null,
      };

  Diagnostic? _noFail(void Function() action) {
    action();
    return null;
  }
}
