import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_argument.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/visibility.dart';
import '../../semantic/symbols/symbol.dart';
import '../../syntax/ast/ast_node.dart';
import '../environment/object_instance.dart';
import '../environment/reference_binding.dart';
import '../values/runtime_value.dart';
import 'execution_task.dart';
import 'interpreter.dart';
import 'interpreter_frame.dart';

final class MemberAccessTaskExecutor {
  final Interpreter engine;

  MemberAccessTaskExecutor(this.engine);

  void pushMemberAccess(
      MemberAccessExpressionNode node, InterpreterFrame frame) {
    frame.pushTask(FinishMemberAccessTask(node));
    frame.pushTask(EvaluateExpressionTask(node.target));
  }

  Diagnostic? finishMemberAccess(
      FinishMemberAccessTask task, InterpreterFrame frame) {
    final targetValue = frame.popOperand();
    if (targetValue is! ObjectValue) {
      throw StateError(
          'Target of member access is not an ObjectValue: $targetValue');
    }
    final instance = targetValue.instance;
    final field = instance.classSymbol.findField(task.node.memberName);
    if (field == null) {
      return engine.diagnostic(
        DiagnosticCode.undefinedMember,
        task.node.memberSpan,
        arguments: {'lexeme': LexemeDiagnosticArgument(task.node.memberName)},
      );
    }
    final visibilityDiag = _checkVisibility(field, instance, task.node, frame);
    if (visibilityDiag != null) return visibilityDiag;

    final cell = instance.fieldCell(task.node.memberName)!;
    if (!cell.hasValue) {
      return engine.diagnostic(
        DiagnosticCode.uninitializedVariableRead,
        task.node.memberSpan,
        arguments: {'lexeme': LexemeDiagnosticArgument(task.node.memberName)},
      );
    }
    frame.pushOperand(cell.value);
    return null;
  }

  void pushMemberReference(
      MemberAccessExpressionNode node, InterpreterFrame frame) {
    frame.pushTask(FinishMemberReferenceTask(node));
    frame.pushTask(EvaluateExpressionTask(node.target));
  }

  Diagnostic? finishMemberReference(
      FinishMemberReferenceTask task, InterpreterFrame frame) {
    final targetValue = frame.popOperand();
    if (targetValue is! ObjectValue) {
      throw StateError(
          'Target of member reference is not an ObjectValue: $targetValue');
    }
    final instance = targetValue.instance;
    final field = instance.classSymbol.findField(task.node.memberName);
    if (field == null) {
      return engine.diagnostic(
        DiagnosticCode.undefinedMember,
        task.node.memberSpan,
        arguments: {'lexeme': LexemeDiagnosticArgument(task.node.memberName)},
      );
    }
    final visibilityDiag = _checkVisibility(field, instance, task.node, frame);
    if (visibilityDiag != null) return visibilityDiag;

    final cell = instance.fieldCell(task.node.memberName)!;
    frame.pushOperand(ReferenceBinding(cell));
    return null;
  }

  Diagnostic? _checkVisibility(
    FieldSymbol field,
    ObjectInstance instance,
    MemberAccessExpressionNode node,
    InterpreterFrame frame,
  ) {
    if (field.visibility != Visibility.private) return null;
    final declaringClass = _findDeclaringClass(instance.classSymbol, field.name);
    final callerClass = frame.currentClass;
    if (callerClass != null && callerClass.name == declaringClass.name) {
      return null;
    }
    return engine.diagnostic(
      DiagnosticCode.privateMemberAccess,
      node.memberSpan,
      arguments: {
        'lexeme': LexemeDiagnosticArgument(field.name),
        'className': LexemeDiagnosticArgument(declaringClass.name),
      },
    );
  }

  ClassSymbol _findDeclaringClass(ClassSymbol classSymbol, String fieldName) {
    ClassSymbol? current = classSymbol;
    while (current != null) {
      if (current.fields.containsKey(fieldName)) return current;
      current = current.superclass;
    }
    return classSymbol;
  }
}
