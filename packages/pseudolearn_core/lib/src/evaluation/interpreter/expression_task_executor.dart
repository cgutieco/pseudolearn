import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_argument.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/primitive_type.dart';
import '../../domain/pseudo_integer.dart';
import '../../domain/span.dart';
import '../../syntax/ast/ast_node.dart';
import '../../syntax/ast/operators.dart';
import '../environment/reference_binding.dart';
import '../environment/variable_cell.dart';
import '../values/runtime_value.dart';
import 'execution_task.dart';
import 'interpreter.dart';
import 'interpreter_frame.dart';

final class ExpressionTaskExecutor {
  final Interpreter engine;

  ExpressionTaskExecutor(this.engine);

  Diagnostic? evaluate(EvaluateExpressionTask task, InterpreterFrame frame) {
    final node = task.expression;
    return switch (node) {
      LiteralExpressionNode() => _evaluateLiteral(node, frame),
      VariableExpressionNode() => _evaluateVariable(node, frame),
      ParenthesizedExpressionNode() =>
        _push(frame, EvaluateExpressionTask(node.expression)),
      UnaryExpressionNode() => _evaluateUnary(node, frame),
      BinaryExpressionNode() => _evaluateBinary(node, frame),
      ArrayAccessExpressionNode() => _evaluateArrayAccess(node, frame),
      FunctionCallExpressionNode() => _evaluateCall(node, frame),
      InstantiationExpressionNode() => _evaluateInstantiation(node, frame),
      MemberAccessExpressionNode() => _evaluateMemberAccess(node, frame),
      MethodCallExpressionNode() => _evaluateMethodCall(node, frame),
      ThisExpressionNode() => _evaluateThis(node, frame),
      SuperExpressionNode() => _evaluateSuper(node, frame),
    };
  }

  Diagnostic? _evaluateInstantiation(
      InstantiationExpressionNode node, InterpreterFrame frame) {
    engine.oop.pushInstantiation(node, frame);
    return null;
  }

  Diagnostic? _evaluateMemberAccess(
      MemberAccessExpressionNode node, InterpreterFrame frame) {
    engine.memberAccess.pushMemberAccess(node, frame);
    return null;
  }

  Diagnostic? _evaluateMethodCall(
      MethodCallExpressionNode node, InterpreterFrame frame) {
    engine.methodCalls.pushMethodCallExpression(node, frame);
    return null;
  }

  Diagnostic? _evaluateThis(ThisExpressionNode node, InterpreterFrame frame) {
    final receiver = frame.receiver;
    if (receiver == null) {
      throw StateError('Este used outside of instance context.');
    }
    frame.pushOperand(ObjectValue(receiver));
    return null;
  }

  Diagnostic? _evaluateSuper(SuperExpressionNode node, InterpreterFrame frame) {
    final receiver = frame.receiver;
    if (receiver == null) {
      throw StateError('Super used outside of instance context.');
    }
    frame.pushOperand(ObjectValue(receiver));
    return null;
  }

  Diagnostic? _push(InterpreterFrame frame, ExecutionTask task) {
    frame.pushTask(task);
    return null;
  }

  RuntimeValue literalValue(LiteralExpressionNode node) => switch (node.type) {
        PrimitiveType.integer => IntegerValue(node.value as PseudoInteger),
        PrimitiveType.real => RealValue(node.value as double),
        PrimitiveType.boolean => BooleanValue(node.value as bool),
        PrimitiveType.character => CharacterValue(node.value as String),
        PrimitiveType.string => StringValue(node.value as String),
      };

  Diagnostic? _evaluateLiteral(
      LiteralExpressionNode node, InterpreterFrame frame) {
    frame.pushOperand(literalValue(node));
    return null;
  }

  Diagnostic? _evaluateVariable(
      VariableExpressionNode node, InterpreterFrame frame) {
    final symbol = engine.program.resolution.symbolFor(node.id);
    if (symbol == null) {
      throw StateError('Unresolved variable at runtime: ${node.name}');
    }
    final cell = frame.environment.scope.cellFor(symbol);
    return pushCellValue(frame, cell, symbol.name, node.span);
  }

  Diagnostic? pushCellValue(
      InterpreterFrame frame, VariableCell cell, String name, Span span) {
    if (!cell.hasValue) {
      return engine.diagnostic(
        DiagnosticCode.uninitializedVariableRead,
        span,
        arguments: {'lexeme': LexemeDiagnosticArgument(name)},
      );
    }
    frame.pushOperand(cell.value);
    return null;
  }

  Diagnostic? _evaluateUnary(UnaryExpressionNode node, InterpreterFrame frame) {
    frame.pushTask(FinishUnaryTask(node));
    frame.pushTask(EvaluateExpressionTask(node.operand));
    return null;
  }

  Diagnostic? _evaluateBinary(
      BinaryExpressionNode node, InterpreterFrame frame) {
    if (node.operator == BinaryOperator.and ||
        node.operator == BinaryOperator.or) {
      frame.pushTask(EvaluateLogicalRightTask(node));
      frame.pushTask(EvaluateExpressionTask(node.left));
      return null;
    }
    frame.pushTask(FinishBinaryTask(node));
    frame.pushTask(EvaluateExpressionTask(node.right));
    frame.pushTask(EvaluateExpressionTask(node.left));
    return null;
  }

  Diagnostic? _evaluateArrayAccess(
      ArrayAccessExpressionNode node, InterpreterFrame frame) {
    frame.pushTask(FinishArrayAccessTask(node));
    for (final index in node.indices.reversed) {
      frame.pushTask(EvaluateExpressionTask(index));
    }
    return null;
  }

  Diagnostic? _evaluateCall(
      FunctionCallExpressionNode node, InterpreterFrame frame) {
    engine.calls.pushExpressionCall(node, frame);
    return null;
  }

  Diagnostic? resolveReference(
      ResolveReferenceTask task, InterpreterFrame frame) {
    final designator = task.designator;
    if (designator is VariableExpressionNode) {
      final symbol = engine.program.resolution.symbolFor(designator.id)!;
      frame.pushOperand(
          ReferenceBinding(frame.environment.scope.cellFor(symbol)));
      return null;
    }
    if (designator is MemberAccessExpressionNode) {
      engine.memberAccess.pushMemberReference(designator, frame);
      return null;
    }
    final arrayAccess = designator as ArrayAccessExpressionNode;
    frame.pushTask(FinishArrayReferenceTask(arrayAccess));
    for (final index in arrayAccess.indices.reversed) {
      frame.pushTask(EvaluateExpressionTask(index));
    }
    return null;
  }
}
