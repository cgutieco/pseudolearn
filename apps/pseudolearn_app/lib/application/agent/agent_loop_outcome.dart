import '../../domain/model/agent/model_item.dart';
import '../../domain/model/agent/tool_definition.dart';
import '../../domain/model/credits/credit_failure.dart';
import 'agent_turn.dart';
import 'tools/tool_arguments.dart';

sealed class AgentLoopOutcome {
  final AgentTurn turn;

  const AgentLoopOutcome(this.turn);
}

final class AgentAnswered extends AgentLoopOutcome {
  const AgentAnswered(super.turn);
}

final class AgentAwaitsConfirmation extends AgentLoopOutcome {
  final ToolCallItem call;
  final ToolDefinition tool;
  final ToolArguments arguments;

  const AgentAwaitsConfirmation(super.turn, {required this.call, required this.tool, required this.arguments});
}

final class AgentFailed extends AgentLoopOutcome {
  final CreditFailure failure;

  const AgentFailed(super.turn, this.failure);
}

final class AgentExhausted extends AgentLoopOutcome {
  const AgentExhausted(super.turn);
}
