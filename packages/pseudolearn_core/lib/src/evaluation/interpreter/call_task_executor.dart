import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_argument.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/primitive_type.dart';
import '../../domain/span.dart';
import '../../semantic/symbols/symbol.dart';
import '../../syntax/ast/ast_node.dart';
import '../environment/array_storage.dart';
import '../environment/call_frame.dart';
import '../environment/reference_binding.dart';
import '../events/execution_event.dart';
import '../values/runtime_value.dart';
import 'execution_task.dart';
import 'interpreter.dart';
import 'interpreter_frame.dart';

final class CallTaskExecutor {
  final Interpreter engine;

  CallTaskExecutor(this.engine);

  void pushExpressionCall(
      FunctionCallExpressionNode node, InterpreterFrame frame) {
    _pushCall(
      name: node.name,
      arguments: node.arguments,
      callSpan: node.span,
      frame: frame,
      pushValueOnReturn: true,
    );
  }

  void pushStatementCall(CallStatementNode node, InterpreterFrame frame) {
    _pushCall(
      name: node.name,
      arguments: node.arguments,
      callSpan: node.span,
      frame: frame,
      pushValueOnReturn: false,
    );
  }

  void _pushCall({
    required String name,
    required List<ExpressionNode> arguments,
    required Span callSpan,
    required InterpreterFrame frame,
    required bool pushValueOnReturn,
  }) {
    final symbol = engine.program.resolution.rootScope.lookup(name);
    frame.pushTask(DispatchCallTask(
      name: name,
      argumentCount: arguments.length,
      callSpan: callSpan,
      pushValueOnReturn: pushValueOnReturn,
    ));
    final parameters = symbol is SubroutineSymbol ? symbol.parameters : null;
    for (var i = arguments.length - 1; i >= 0; i--) {
      frame.pushTask(_argumentTask(parameters?[i], arguments[i]));
    }
  }

  ExecutionTask _argumentTask(ParameterSymbol? param, ExpressionNode argument) {
    if (param != null && param.dimensionCount > 0) {
      return ResolveArrayArgumentTask(argument as VariableExpressionNode);
    }
    if (param != null &&
        param.passingMode == ParameterPassingMode.byReference) {
      return ResolveReferenceTask(argument);
    }
    return EvaluateExpressionTask(argument);
  }

  void resolveArrayArgument(
      ResolveArrayArgumentTask task, InterpreterFrame frame) {
    final symbol = engine.program.resolution.symbolFor(task.designator.id)!;
    frame.pushOperand(frame.environment.scope.arrayFor(symbol)!);
  }

  Diagnostic? dispatch(
    DispatchCallTask task,
    InterpreterFrame callerFrame,
    List<ExecutionEvent> events,
  ) {
    final rawArguments =
        List.generate(task.argumentCount, (_) => callerFrame.popOperand())
            .reversed
            .toList();
    final symbol = engine.program.resolution.rootScope.lookup(task.name);

    if (symbol is BuiltinFunctionSymbol) {
      return _dispatchBuiltin(symbol, rawArguments, task, callerFrame);
    }
    if (symbol is SubroutineSymbol) {
      return _dispatchSubroutine(symbol, rawArguments, task, events);
    }
    throw StateError('Unresolved call target at runtime: ${task.name}');
  }

  Diagnostic? _dispatchBuiltin(
    BuiltinFunctionSymbol symbol,
    List<Object> rawArguments,
    DispatchCallTask task,
    InterpreterFrame callerFrame,
  ) {
    final values = rawArguments.cast<RuntimeValue>();
    final result =
        engine.builtinInvoker.invoke(symbol.function, values, task.callSpan);
    if (result.diagnostic != null) return result.diagnostic;
    if (task.pushValueOnReturn && result.value != null) {
      callerFrame.pushOperand(result.value!);
    }
    return null;
  }

  Diagnostic? _dispatchSubroutine(
    SubroutineSymbol symbol,
    List<Object> rawArguments,
    DispatchCallTask task,
    List<ExecutionEvent> events,
  ) {
    if (engine.frames.length - 1 >= Interpreter.maxCallDepth) {
      return engine.diagnostic(
        DiagnosticCode.recursionDepthExceeded,
        task.callSpan,
        arguments: {
          'limit': const NumberDiagnosticArgument(Interpreter.maxCallDepth)
        },
        relatedSpans: [symbol.span],
      );
    }

    final newFrame = _buildCalleeFrame(symbol, task);
    _bindParameters(symbol, rawArguments, newFrame);
    newFrame.pushBody(symbol.declarationNode.body);

    engine.frames.add(newFrame);
    events.add(SubroutineEnteredEvent(
      subroutineName: symbol.name,
      callSpan: task.callSpan,
      snapshot: engine.snapshotIfObserved(),
    ));
    return null;
  }

  InterpreterFrame _buildCalleeFrame(
      SubroutineSymbol symbol, DispatchCallTask task) {
    final declarationEnd = symbol.declarationNode.span.end;
    return InterpreterFrame(
      environment:
          CallFrame(subroutineName: symbol.name, callSpan: task.callSpan),
      hasDeclaredReturnType:
          symbol.returnType != null || symbol.customReturnType != null,
      returnPrimitiveType: symbol.returnType,
      headerSpan: symbol.span,
      closingSpan: Span(start: declarationEnd, end: declarationEnd),
      pushValueOnReturn: task.pushValueOnReturn,
    );
  }

  void _bindParameters(
    SubroutineSymbol symbol,
    List<Object> rawArguments,
    InterpreterFrame newFrame,
  ) {
    for (var i = 0; i < symbol.parameters.length; i++) {
      final param = symbol.parameters[i];
      final argument = rawArguments[i];
      if (param.dimensionCount > 0) {
        newFrame.environment.scope
            .declareArray(param, argument as ArrayStorage);
      } else if (param.passingMode == ParameterPassingMode.byReference) {
        newFrame.environment.scope
            .bind(param, (argument as ReferenceBinding).cell);
      } else {
        final value = _widenIfNeeded(param, argument as RuntimeValue);
        newFrame.environment.scope.cellFor(param).assign(value);
      }
    }
  }

  RuntimeValue _widenIfNeeded(ParameterSymbol param, RuntimeValue value) {
    if (param.primitiveType == PrimitiveType.real && value is IntegerValue) {
      return value.widenedToReal();
    }
    return value;
  }
}
