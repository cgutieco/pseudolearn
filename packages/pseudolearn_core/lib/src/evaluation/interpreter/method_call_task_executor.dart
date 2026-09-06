import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_argument.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/span.dart';
import '../../domain/visibility.dart';
import '../../semantic/symbols/symbol.dart';
import '../../syntax/ast/ast_node.dart';
import '../../syntax/ast/classes/super_constructor_call.dart';
import '../environment/call_frame.dart';
import '../environment/object_instance.dart';
import '../events/execution_event.dart';
import '../values/runtime_value.dart';
import 'execution_task.dart';
import 'interpreter.dart';
import 'interpreter_frame.dart';

final class MethodCallTaskExecutor {
  final Interpreter engine;

  MethodCallTaskExecutor(this.engine);

  void pushMethodCallExpression(
      MethodCallExpressionNode node, InterpreterFrame frame) {
    frame.pushTask(DispatchMethodCallTask.expression(
      node: node,
      argumentCount: node.arguments.length,
    ));
    for (var i = node.arguments.length - 1; i >= 0; i--) {
      frame.pushTask(EvaluateExpressionTask(node.arguments[i]));
    }
    frame.pushTask(EvaluateExpressionTask(node.target));
  }

  void pushMethodCallStatement(
      MethodCallStatementNode node, InterpreterFrame frame) {
    if (isSuperConstructorCall(node)) {
      frame.pushTask(FinishSuperConstructorTask(
        statementNode: node,
        argumentCount: node.arguments.length,
      ));
      for (var i = node.arguments.length - 1; i >= 0; i--) {
        frame.pushTask(EvaluateExpressionTask(node.arguments[i]));
      }
      return;
    }
    frame.pushTask(DispatchMethodCallTask.statement(
      node: node,
      argumentCount: node.arguments.length,
    ));
    for (var i = node.arguments.length - 1; i >= 0; i--) {
      frame.pushTask(EvaluateExpressionTask(node.arguments[i]));
    }
    frame.pushTask(EvaluateExpressionTask(node.target));
  }

  Diagnostic? finishSuperConstructor(
    FinishSuperConstructorTask task,
    InterpreterFrame callerFrame,
    List<ExecutionEvent> events,
  ) {
    final rawArguments = List.generate(
      task.argumentCount,
      (_) => callerFrame.popOperand(),
    ).reversed.toList();

    final currentClass = callerFrame.currentClass;
    final superclass = currentClass?.superclass;
    if (superclass == null) {
      return engine.diagnostic(
        DiagnosticCode.superInClassWithoutSuperclass,
        task.statementNode!.span,
      );
    }
    return _invokeSuperConstructor(
      superclass: superclass,
      instance: callerFrame.receiver!,
      rawArguments: rawArguments,
      span: task.statementNode!.span,
      events: events,
    );
  }

  Diagnostic? _invokeSuperConstructor({
    required ClassSymbol superclass,
    required ObjectInstance instance,
    required List<Object> rawArguments,
    required Span span,
    required List<ExecutionEvent> events,
  }) {
    if (engine.frames.length >= Interpreter.maxCallDepth) {
      return engine.diagnostic(
        DiagnosticCode.recursionDepthExceeded,
        span,
        arguments: {'limit': const NumberDiagnosticArgument(Interpreter.maxCallDepth)},
      );
    }
    final calleeFrame = engine.oop.buildConstructorFrame(superclass, instance, span);
    final constructor = superclass.constructor;
    if (constructor != null) {
      engine.oop.bindParameters(constructor.parameters, rawArguments, calleeFrame);
      calleeFrame.pushBody(constructor.declarationNode?.body ?? const []);
    }
    engine.frames.add(calleeFrame);
    events.add(SubroutineEnteredEvent(
      subroutineName: '${superclass.name}.Constructor',
      callSpan: span,
      snapshot: engine.snapshotIfObserved(),
    ));
    return null;
  }

  Diagnostic? dispatchMethodCall(
    DispatchMethodCallTask task,
    InterpreterFrame callerFrame,
    List<ExecutionEvent> events,
  ) {
    final rawArguments = List.generate(
      task.argumentCount,
      (_) => callerFrame.popOperand(),
    ).reversed.toList();
    final targetValue = callerFrame.popOperand();

    if (targetValue is! ObjectValue) {
      throw StateError('Target of method call is not an ObjectValue: $targetValue');
    }
    final resolved = _resolveMethod(task, targetValue.instance, callerFrame);
    if (resolved.diagnostic != null) return resolved.diagnostic;

    final method = resolved.method!;
    final declaringClass = resolved.declaringClass!;
    final visibilityDiag = _checkVisibility(method, declaringClass, task, callerFrame);
    if (visibilityDiag != null) return visibilityDiag;

    return _invokeMethod(
      method: method,
      declaringClass: declaringClass,
      instance: targetValue.instance,
      rawArguments: rawArguments,
      task: task,
      events: events,
    );
  }

  Diagnostic? _invokeMethod({
    required MethodSymbol method,
    required ClassSymbol declaringClass,
    required ObjectInstance instance,
    required List<Object> rawArguments,
    required DispatchMethodCallTask task,
    required List<ExecutionEvent> events,
  }) {
    if (engine.frames.length >= Interpreter.maxCallDepth) {
      return engine.diagnostic(
        DiagnosticCode.recursionDepthExceeded,
        task.callSpan,
        arguments: {'limit': const NumberDiagnosticArgument(Interpreter.maxCallDepth)},
      );
    }
    final calleeFrame = _buildMethodFrame(method, instance, declaringClass, task);
    engine.oop.bindParameters(method.parameters, rawArguments, calleeFrame);
    calleeFrame.pushBody(method.declarationNode.body);
    engine.frames.add(calleeFrame);
    events.add(SubroutineEnteredEvent(
      subroutineName: '${declaringClass.name}.${method.name}',
      callSpan: task.callSpan,
      snapshot: engine.snapshotIfObserved(),
    ));
    return null;
  }

  ({MethodSymbol? method, ClassSymbol? declaringClass, Diagnostic? diagnostic})
      _resolveMethod(
    DispatchMethodCallTask task,
    ObjectInstance instance,
    InterpreterFrame callerFrame,
  ) =>
      task.target is SuperExpressionNode
          ? _resolveSuperMethod(task, callerFrame)
          : _resolveInstanceMethod(task, instance);

  ({MethodSymbol? method, ClassSymbol? declaringClass, Diagnostic? diagnostic})
      _resolveSuperMethod(
    DispatchMethodCallTask task,
    InterpreterFrame callerFrame,
  ) {
    final superclass = callerFrame.currentClass?.superclass;
    if (superclass == null) {
      return (
        method: null,
        declaringClass: null,
        diagnostic: engine.diagnostic(
          DiagnosticCode.superInClassWithoutSuperclass,
          task.callSpan,
        ),
      );
    }
    final method = superclass.findMethod(task.methodName);
    if (method == null) {
      return (
        method: null,
        declaringClass: null,
        diagnostic: engine.diagnostic(
          DiagnosticCode.undefinedMember,
          task.callSpan,
          arguments: {'lexeme': LexemeDiagnosticArgument(task.methodName)},
        ),
      );
    }
    return (
      method: method,
      declaringClass: _findDeclaringClass(superclass, task.methodName),
      diagnostic: null,
    );
  }

  ({MethodSymbol? method, ClassSymbol? declaringClass, Diagnostic? diagnostic})
      _resolveInstanceMethod(
    DispatchMethodCallTask task,
    ObjectInstance instance,
  ) {
    final method = instance.classSymbol.findMethod(task.methodName);
    if (method == null) {
      return (
        method: null,
        declaringClass: null,
        diagnostic: engine.diagnostic(
          DiagnosticCode.undefinedMember,
          task.callSpan,
          arguments: {'lexeme': LexemeDiagnosticArgument(task.methodName)},
        ),
      );
    }
    return (
      method: method,
      declaringClass: _findDeclaringClass(instance.classSymbol, task.methodName),
      diagnostic: null,
    );
  }

  Diagnostic? _checkVisibility(
    MethodSymbol method,
    ClassSymbol declaringClass,
    DispatchMethodCallTask task,
    InterpreterFrame callerFrame,
  ) {
    if (method.visibility != Visibility.private) return null;
    final callerClass = callerFrame.currentClass;
    if (callerClass != null && callerClass.name == declaringClass.name) {
      return null;
    }
    return engine.diagnostic(
      DiagnosticCode.privateMemberAccess,
      task.callSpan,
      arguments: {
        'lexeme': LexemeDiagnosticArgument(method.name),
        'className': LexemeDiagnosticArgument(declaringClass.name),
      },
    );
  }

  InterpreterFrame _buildMethodFrame(
    MethodSymbol method,
    ObjectInstance instance,
    ClassSymbol declaringClass,
    DispatchMethodCallTask task,
  ) {
    final declarationEnd = method.declarationNode.span.end;
    return InterpreterFrame(
      environment: CallFrame(
        subroutineName: '${declaringClass.name}.${method.name}',
        callSpan: task.callSpan,
        receiver: instance,
        currentClass: declaringClass,
      ),
      hasDeclaredReturnType: method.returnType != null || method.customReturnType != null,
      returnPrimitiveType: method.returnType,
      headerSpan: method.span,
      closingSpan: Span(start: declarationEnd, end: declarationEnd),
      pushValueOnReturn: task.pushValueOnReturn,
    );
  }

  ClassSymbol _findDeclaringClass(ClassSymbol classSymbol, String methodName) {
    ClassSymbol? current = classSymbol;
    while (current != null) {
      if (current.methods.containsKey(methodName)) return current;
      current = current.superclass;
    }
    return classSymbol;
  }
}
