import '../../domain/model/agent/agent_turn_step.dart';
import '../../domain/model/agent/model_item.dart';
import '../../domain/model/credits/credit_balance.dart';

final class AgentTurn {
  final String turnId;
  final List<ModelItem> history;
  final int modelCalls;
  final List<ToolCallItem> pendingCalls;
  final Set<String> declinedTools;
  final List<AgentTurnStep> steps;
  final CreditBalance? balance;
  final String? approvedCallId;

  const AgentTurn({
    required this.turnId,
    required this.history,
    this.modelCalls = 0,
    this.pendingCalls = const [],
    this.declinedTools = const {},
    this.steps = const [],
    this.balance,
    this.approvedCallId,
  });

  AgentTurn answered(List<ModelItem> items, CreditBalance? balance) => AgentTurn(
    turnId: turnId,
    history: [...history, ...items],
    modelCalls: modelCalls + 1,
    pendingCalls: [for (final item in items) if (item is ToolCallItem) item],
    declinedTools: declinedTools,
    steps: steps,
    balance: balance ?? this.balance,
  );

  AgentTurn resolved(ToolOutputItem output, AgentTurnStep step, {String? declinedTool}) => AgentTurn(
    turnId: turnId,
    history: [...history, output],
    modelCalls: modelCalls,
    pendingCalls: pendingCalls.length > 1 ? pendingCalls.sublist(1) : const [],
    declinedTools: {...declinedTools, ?declinedTool},
    steps: [...steps, step],
    balance: balance,
  );

  AgentTurn approving(String callId) => AgentTurn(
    turnId: turnId,
    history: history,
    modelCalls: modelCalls,
    pendingCalls: pendingCalls,
    declinedTools: declinedTools,
    steps: steps,
    balance: balance,
    approvedCallId: callId,
  );

  String get answerText => [
    for (final item in history.reversed.takeWhile((item) => item is! UserTextItem))
      if (item is AssistantTextItem) item.text,
  ].reversed.join('\n\n');
}
