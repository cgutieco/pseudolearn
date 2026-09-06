import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_argument.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/primitive_type.dart';
import '../../domain/span.dart';
import '../../semantic/symbols/symbol.dart';
import '../../syntax/ast/ast_node.dart';
import '../environment/array_storage.dart';
import '../environment/call_frame.dart';
import '../environment/object_instance.dart';
import '../environment/reference_binding.dart';
import '../events/execution_event.dart';
import '../values/runtime_value.dart';
import 'execution_task.dart';
import 'interpreter.dart';
import 'interpreter_frame.dart';

final class OopTaskExecutor {
  final Interpreter engine;

  OopTaskExecutor(this.engine);

  void pushInstantiation(
      InstantiationExpressionNode node, InterpreterFrame frame) {
    frame.pushTask(FinishInstantiationTask(node));
    final classSymbol = _resolveClass(node);
    final parameters = classSymbol?.constructor?.parameters;
    for (var i = node.arguments.length - 1; i >= 0; i--) {
      frame.pushTask(_argumentTask(parameters?[i], node.arguments[i]));
    }
  }

  Diagnostic? finishInstantiation(
    FinishInstantiationTask task,
    InterpreterFrame callerFrame,
    List<ExecutionEvent> events,
  ) {
    final rawArguments = List.generate(
      task.node.arguments.length,
      (_) => callerFrame.popOperand(),
    ).reversed.toList();

    final classSymbol = _resolveClass(task.node);
    if (classSymbol == null) {
      throw StateError('Unresolved class: ${task.node.className}');
    }

    final instance = ObjectInstance(
      id: engine.nextInstanceId,
      classSymbol: classSymbol,
    );

    final constructor = classSymbol.constructor;
    if (constructor != null) {
      return _invokeConstructor(
        classSymbol: classSymbol,
        constructor: constructor,
        instance: instance,
        rawArguments: rawArguments,
        callSpan: task.node.span,
        callerFrame: callerFrame,
        events: events,
      );
    }
    _executeImplicitSuperConstructors(classSymbol.superclass, instance);
    callerFrame.pushOperand(ObjectValue(instance));
    return null;
  }

  Diagnostic? _invokeConstructor({
    required ClassSymbol classSymbol,
    required ConstructorSymbol constructor,
    required ObjectInstance instance,
    required List<Object> rawArguments,
    required Span callSpan,
    required InterpreterFrame callerFrame,
    required List<ExecutionEvent> events,
  }) {
    if (engine.frames.length >= Interpreter.maxCallDepth) {
      return engine.diagnostic(
        DiagnosticCode.recursionDepthExceeded,
        callSpan,
        arguments: {'limit': const NumberDiagnosticArgument(Interpreter.maxCallDepth)},
      );
    }
    final calleeFrame = buildConstructorFrame(classSymbol, instance, callSpan);
    bindParameters(constructor.parameters, rawArguments, calleeFrame);
    calleeFrame.pushBody(constructor.declarationNode?.body ?? const []);
    _ensureSuperConstructor(classSymbol, instance, calleeFrame, constructor);
    engine.frames.add(calleeFrame);
    callerFrame.pushOperand(ObjectValue(instance));
    events.add(SubroutineEnteredEvent(
      subroutineName: '${classSymbol.name}.Constructor',
      callSpan: callSpan,
      snapshot: engine.snapshotIfObserved(),
    ));
    return null;
  }

  void _ensureSuperConstructor(
    ClassSymbol classSymbol,
    ObjectInstance instance,
    InterpreterFrame frame,
    ConstructorSymbol constructor,
  ) {
    final superclass = classSymbol.superclass;
    if (superclass == null) return;
    final body = constructor.declarationNode?.body ?? const [];
    final firstStatement = body.isNotEmpty ? body.first : null;
    final explicitlyCallsSuper = firstStatement is MethodCallStatementNode &&
        firstStatement.target is SuperExpressionNode &&
        firstStatement.methodName.toLowerCase() == 'constructor';
    if (!explicitlyCallsSuper) {
      _executeImplicitSuperConstructors(superclass, instance);
    }
  }

  void _executeImplicitSuperConstructors(
      ClassSymbol? superclass, ObjectInstance instance) {
    ClassSymbol? current = superclass;
    while (current != null) {
      final superConstructor = current.constructor;
      if (superConstructor != null &&
          (superConstructor.declarationNode?.body.isNotEmpty ?? false)) {
        break;
      }
      current = current.superclass;
    }
  }

  InterpreterFrame buildConstructorFrame(
      ClassSymbol classSymbol, ObjectInstance instance, Span callSpan) {
    final declarationEnd =
        classSymbol.constructor?.declarationNode?.span.end ?? classSymbol.span.end;
    return InterpreterFrame(
      environment: CallFrame(
        subroutineName: '${classSymbol.name}.Constructor',
        callSpan: callSpan,
        receiver: instance,
        currentClass: classSymbol,
      ),
      hasDeclaredReturnType: false,
      headerSpan: classSymbol.constructor?.span ?? classSymbol.span,
      closingSpan: Span(start: declarationEnd, end: declarationEnd),
      pushValueOnReturn: false,
    );
  }

  ClassSymbol? _resolveClass(InstantiationExpressionNode node) {
    final byId = engine.program.resolution.resolvedClasses[node.id];
    if (byId != null) return byId;
    final byName = engine.program.resolution.rootScope.lookup(node.className);
    return byName is ClassSymbol ? byName : null;
  }

  ExecutionTask _argumentTask(ParameterSymbol? param, ExpressionNode argument) {
    if (param != null && param.dimensionCount > 0) {
      return ResolveArrayArgumentTask(argument as VariableExpressionNode);
    }
    if (param != null && param.passingMode == ParameterPassingMode.byReference) {
      return ResolveReferenceTask(argument);
    }
    return EvaluateExpressionTask(argument);
  }

  void bindParameters(
    List<ParameterSymbol> parameters,
    List<Object> rawArguments,
    InterpreterFrame newFrame,
  ) {
    for (var i = 0; i < parameters.length; i++) {
      final param = parameters[i];
      final argument = rawArguments[i];
      if (param.dimensionCount > 0) {
        newFrame.environment.scope.declareArray(param, argument as ArrayStorage);
      } else if (param.passingMode == ParameterPassingMode.byReference) {
        newFrame.environment.scope.bind(param, (argument as ReferenceBinding).cell);
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
