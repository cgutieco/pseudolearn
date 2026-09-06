import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_argument.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/primitive_type.dart';
import '../../semantic/types/semantic_type.dart';
import '../../syntax/ast/ast_node.dart';
import '../environment/array_storage.dart';
import '../environment/reference_binding.dart';
import '../events/execution_event.dart';
import '../values/runtime_value.dart';
import 'execution_task.dart';
import 'interpreter.dart';
import 'interpreter_frame.dart';

final class StatementTaskExecutor {
  final Interpreter engine;

  StatementTaskExecutor(this.engine);

  Diagnostic? run(RunStatementTask task, InterpreterFrame frame,
      List<ExecutionEvent> events) {
    final statement = task.statement;
    events.add(StatementEnteredEvent(
        statementId: statement.id, snapshot: engine.snapshotIfObserved()));
    frame.pushTask(StatementExitMarkerTask(statement));
    return switch (statement) {
      VariableDeclarationNode() => _pushDeclaration(statement, frame),
      DimensionStatementNode() => _pushDimension(statement, frame),
      AssignmentStatementNode() => _pushAssignment(statement, frame),
      WriteStatementNode() => _pushWrite(statement, frame),
      ReadStatementNode() => _pushRead(statement, frame),
      ReturnStatementNode() => _pushReturn(statement, frame),
      CallStatementNode() => _pushCall(statement, frame),
      IfStatementNode() => engine.conditionals.pushIf(statement, frame),
      SwitchStatementNode() => engine.conditionals.pushSwitch(statement, frame),
      WhileStatementNode() => engine.loops.pushWhile(statement, frame),
      RepeatUntilStatementNode() => engine.loops.pushRepeat(statement, frame),
      ForStatementNode() => engine.forLoop.pushFor(statement, frame),
      MethodCallStatementNode() => _pushMethodCall(statement, frame),
      ErrorStatementNode() => throw StateError(
          'Unreachable statement reached evaluator: ${statement.runtimeType}',
        ),
    };
  }

  Diagnostic? _pushMethodCall(
      MethodCallStatementNode node, InterpreterFrame frame) {
    engine.methodCalls.pushMethodCallStatement(node, frame);
    return null;
  }

  Diagnostic? _pushDeclaration(
      VariableDeclarationNode node, InterpreterFrame frame) {
    for (final declarator in node.variables) {
      final symbol = engine.program.resolution.symbolFor(declarator.id)!;
      frame.environment.scope.cellFor(symbol);
    }
    return null;
  }

  Diagnostic? _pushDimension(
      DimensionStatementNode node, InterpreterFrame frame) {
    for (final array in node.arrays.reversed) {
      frame.pushTask(FinishArrayDeclarationTask(array));
      for (final dimension in array.dimensions.reversed) {
        frame.pushTask(EvaluateExpressionTask(dimension));
      }
    }
    return null;
  }

  Diagnostic? finishArrayDeclaration(
      FinishArrayDeclarationTask task, InterpreterFrame frame) {
    final node = task.node;
    final sizeValues =
        List.generate(node.dimensions.length, (_) => frame.popValue())
            .reversed
            .toList();
    for (var i = 0; i < sizeValues.length; i++) {
      final size = (sizeValues[i] as IntegerValue).value;
      if (size.isNegative) {
        return engine.diagnostic(
          DiagnosticCode.negativeArraySize,
          node.dimensions[i].span,
          arguments: {'size': IntegerValueDiagnosticArgument(size)},
        );
      }
    }
    final sizes = [
      for (final v in sizeValues) (v as IntegerValue).value.toHostInt()
    ];
    final symbol = engine.program.resolution.symbolFor(node.id)!;
    frame.environment.scope.declareArray(symbol, ArrayStorage(sizes));
    return null;
  }

  Diagnostic? _pushAssignment(
      AssignmentStatementNode node, InterpreterFrame frame) {
    frame.pushTask(FinishAssignmentTask(node));
    frame.pushTask(EvaluateExpressionTask(node.value));
    frame.pushTask(ResolveReferenceTask(node.target));
    return null;
  }

  Diagnostic? finishAssignment(
      FinishAssignmentTask task, InterpreterFrame frame) {
    final value = frame.popValue();
    final target = frame.popOperand() as ReferenceBinding;
    final declaredType = engine.program.typeCheck.typeFor(task.node.target.id);
    target.write(_coerce(value, declaredType?.isReal ?? false));
    return null;
  }

  RuntimeValue _coerce(RuntimeValue value, bool widenToReal) =>
      (widenToReal && value is IntegerValue) ? value.widenedToReal() : value;

  Diagnostic? _pushWrite(WriteStatementNode node, InterpreterFrame frame) {
    frame.pushTask(EmitNewlineIfNeededTask(node));
    for (final expression in node.expressions.reversed) {
      frame.pushTask(const FinishWriteItemTask());
      frame.pushTask(EvaluateExpressionTask(expression));
    }
    return null;
  }

  void finishWriteItem(InterpreterFrame frame, List<ExecutionEvent> events) {
    final value = frame.popValue();
    events.add(OutputProducedEvent(engine.valueFormatter.format(value)));
  }

  void emitNewlineIfNeeded(
      EmitNewlineIfNeededTask task, List<ExecutionEvent> events) {
    if (!task.node.withoutNewline) {
      events.add(const OutputProducedEvent('\n'));
    }
  }

  Diagnostic? _pushRead(ReadStatementNode node, InterpreterFrame frame) {
    for (final target in node.targets.reversed) {
      frame.pushTask(BeginInputTask(target));
      frame.pushTask(ResolveReferenceTask(target));
    }
    return null;
  }

  void beginInput(BeginInputTask task, InterpreterFrame frame) {
    final binding = frame.popOperand() as ReferenceBinding;
    final staticType = engine.program.typeCheck.typeFor(task.designator.id);
    final expectedType =
        staticType is PrimitiveSemanticType ? staticType.primitive : null;
    engine.beginAwaitingInput(
      designatorId: task.designator.id,
      designatorSpan: task.designator.span,
      binding: binding,
      expectedType: expectedType,
    );
  }

  Diagnostic? _pushReturn(ReturnStatementNode node, InterpreterFrame frame) {
    frame.pushTask(FinishReturnTask(node));
    if (node.value != null) {
      frame.pushTask(EvaluateExpressionTask(node.value!));
    }
    return null;
  }

  Diagnostic? finishReturn(FinishReturnTask task, InterpreterFrame frame) {
    if (task.node.value != null) {
      final value = frame.popValue();
      final widen = frame.returnPrimitiveType == PrimitiveType.real;
      frame.returnValue = _coerce(value, widen);
    }
    frame.isReturning = true;
    return null;
  }

  Diagnostic? _pushCall(CallStatementNode node, InterpreterFrame frame) {
    engine.calls.pushStatementCall(node, frame);
    return null;
  }
}
