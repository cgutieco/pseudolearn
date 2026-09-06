import '../../domain/pseudo_integer.dart';
import '../../domain/span.dart';
import '../../syntax/ast/ast_node.dart';

sealed class ExecutionTask {
  const ExecutionTask();
}

final class RunStatementTask extends ExecutionTask {
  final StatementNode statement;

  const RunStatementTask(this.statement);
}

final class StatementExitMarkerTask extends ExecutionTask {
  final StatementNode statement;

  const StatementExitMarkerTask(this.statement);
}

final class EvaluateExpressionTask extends ExecutionTask {
  final ExpressionNode expression;

  const EvaluateExpressionTask(this.expression);
}

final class ResolveReferenceTask extends ExecutionTask {
  final ExpressionNode designator;

  const ResolveReferenceTask(this.designator);
}

final class FinishArrayReferenceTask extends ExecutionTask {
  final ArrayAccessExpressionNode node;

  const FinishArrayReferenceTask(this.node);
}

final class ResolveArrayArgumentTask extends ExecutionTask {
  final VariableExpressionNode designator;

  const ResolveArrayArgumentTask(this.designator);
}

final class FinishUnaryTask extends ExecutionTask {
  final UnaryExpressionNode node;

  const FinishUnaryTask(this.node);
}

final class FinishBinaryTask extends ExecutionTask {
  final BinaryExpressionNode node;

  const FinishBinaryTask(this.node);
}

final class EvaluateLogicalRightTask extends ExecutionTask {
  final BinaryExpressionNode node;

  const EvaluateLogicalRightTask(this.node);
}

final class FinishLogicalTask extends ExecutionTask {
  final BinaryExpressionNode node;
  final bool leftValue;

  const FinishLogicalTask(this.node, this.leftValue);
}

final class FinishArrayAccessTask extends ExecutionTask {
  final ArrayAccessExpressionNode node;

  const FinishArrayAccessTask(this.node);
}

final class DispatchCallTask extends ExecutionTask {
  final String name;
  final int argumentCount;
  final Span callSpan;
  final bool pushValueOnReturn;

  const DispatchCallTask({
    required this.name,
    required this.argumentCount,
    required this.callSpan,
    required this.pushValueOnReturn,
  });
}

final class FinishAssignmentTask extends ExecutionTask {
  final AssignmentStatementNode node;

  const FinishAssignmentTask(this.node);
}

final class FinishWriteItemTask extends ExecutionTask {
  const FinishWriteItemTask();
}

final class EmitNewlineIfNeededTask extends ExecutionTask {
  final WriteStatementNode node;

  const EmitNewlineIfNeededTask(this.node);
}

final class BeginInputTask extends ExecutionTask {
  final ExpressionNode designator;

  const BeginInputTask(this.designator);
}

sealed class ControlFlowTask extends ExecutionTask {
  const ControlFlowTask();
}

final class FinishConditionTask extends ControlFlowTask {
  final IfStatementNode node;

  const FinishConditionTask(this.node);
}

final class FinishSwitchSelectorTask extends ControlFlowTask {
  final SwitchStatementNode node;

  const FinishSwitchSelectorTask(this.node);
}

final class RunWhileTask extends ControlFlowTask {
  final WhileStatementNode node;

  const RunWhileTask(this.node);
}

final class FinishWhileConditionTask extends ControlFlowTask {
  final WhileStatementNode node;

  const FinishWhileConditionTask(this.node);
}

final class RunRepeatBodyTask extends ControlFlowTask {
  final RepeatUntilStatementNode node;

  const RunRepeatBodyTask(this.node);
}

final class FinishRepeatConditionTask extends ControlFlowTask {
  final RepeatUntilStatementNode node;

  const FinishRepeatConditionTask(this.node);
}

final class SetUpForLoopTask extends ControlFlowTask {
  final ForStatementNode node;

  const SetUpForLoopTask(this.node);
}

final class CheckForConditionTask extends ControlFlowTask {
  final ForStatementNode node;
  final PseudoInteger to;
  final PseudoInteger step;

  const CheckForConditionTask(this.node,
      {required this.to, required this.step});
}

final class AdvanceForLoopTask extends ControlFlowTask {
  final ForStatementNode node;
  final PseudoInteger to;
  final PseudoInteger step;

  const AdvanceForLoopTask(this.node, {required this.to, required this.step});
}

final class FinishReturnTask extends ExecutionTask {
  final ReturnStatementNode node;

  const FinishReturnTask(this.node);
}

final class FinishArrayDeclarationTask extends ExecutionTask {
  final ArrayDeclaratorNode node;

  const FinishArrayDeclarationTask(this.node);
}

final class FinishInstantiationTask extends ExecutionTask {
  final InstantiationExpressionNode node;

  const FinishInstantiationTask(this.node);
}

final class FinishMemberAccessTask extends ExecutionTask {
  final MemberAccessExpressionNode node;

  const FinishMemberAccessTask(this.node);
}

final class FinishMemberReferenceTask extends ExecutionTask {
  final MemberAccessExpressionNode node;

  const FinishMemberReferenceTask(this.node);
}

final class DispatchMethodCallTask extends ExecutionTask {
  final MethodCallExpressionNode? expressionNode;
  final MethodCallStatementNode? statementNode;
  final int argumentCount;
  final bool pushValueOnReturn;

  const DispatchMethodCallTask.expression({
    required MethodCallExpressionNode node,
    required this.argumentCount,
  })  : expressionNode = node,
        statementNode = null,
        pushValueOnReturn = true;

  const DispatchMethodCallTask.statement({
    required MethodCallStatementNode node,
    required this.argumentCount,
  })  : expressionNode = null,
        statementNode = node,
        pushValueOnReturn = false;

  Span get callSpan => expressionNode?.span ?? statementNode!.span;
  String get methodName =>
      expressionNode?.methodName ?? statementNode!.methodName;
  ExpressionNode get target => expressionNode?.target ?? statementNode!.target;
}

final class FinishSuperConstructorTask extends ExecutionTask {
  final MethodCallStatementNode? statementNode;
  final int argumentCount;

  const FinishSuperConstructorTask({
    required this.statementNode,
    required this.argumentCount,
  });
}
