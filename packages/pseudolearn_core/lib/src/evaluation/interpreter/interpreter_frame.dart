import '../../domain/primitive_type.dart';
import '../../domain/span.dart';
import '../../semantic/symbols/symbol.dart';
import '../../syntax/ast/ast_node.dart';
import '../environment/call_frame.dart';
import '../environment/object_instance.dart';
import '../values/runtime_value.dart';
import 'execution_task.dart';

final class InterpreterFrame {
  final CallFrame environment;
  final List<ExecutionTask> taskStack = [];
  final List<Object> operandStack = [];
  final bool hasDeclaredReturnType;
  final PrimitiveType? returnPrimitiveType;
  final Span headerSpan;
  final Span closingSpan;

  final bool pushValueOnReturn;

  bool isReturning = false;
  RuntimeValue? returnValue;

  InterpreterFrame({
    required this.environment,
    required this.hasDeclaredReturnType,
    required this.headerSpan,
    required this.closingSpan,
    this.returnPrimitiveType,
    this.pushValueOnReturn = false,
  });

  void pushTask(ExecutionTask task) => taskStack.add(task);

  ExecutionTask popTask() => taskStack.removeLast();

  void pushBody(List<StatementNode> body) {
    for (final statement in body.reversed) {
      taskStack.add(RunStatementTask(statement));
    }
  }

  bool get hasPendingTasks => taskStack.isNotEmpty;

  void pushOperand(Object value) => operandStack.add(value);

  Object popOperand() => operandStack.removeLast();

  RuntimeValue popValue() => popOperand() as RuntimeValue;

  ObjectInstance? get receiver => environment.receiver;

  ClassSymbol? get currentClass => environment.currentClass;
}
