import '../../domain/model/agent/agent_message.dart';
import '../../domain/model/agent/agent_turn_step.dart';
import '../../domain/model/agent/tool_definition.dart';
import '../../domain/model/credits/credit_balance.dart';
import '../../domain/model/credits/credit_failure.dart';

enum AgentSessionStatus { idle, needsConsent, thinking, awaitingConfirmation, failed, exhausted }

final class PendingConfirmation {
  final String toolName;
  final String label;
  final ToolRisk risk;
  final Map<String, Object?> arguments;

  const PendingConfirmation({
    required this.toolName,
    required this.label,
    required this.risk,
    required this.arguments,
  });
}

final class AgentSessionState {
  final AgentSessionStatus status;
  final List<AgentMessage> messages;
  final List<AgentTurnStep> liveSteps;
  final PendingConfirmation? confirmation;
  final CreditFailure? failure;
  final CreditBalance? balance;
  final int lastRequestSpent;
  final String? draftAwaitingConsent;
  final bool hasUnseenReply;

  const AgentSessionState({
    this.status = AgentSessionStatus.idle,
    this.messages = const [],
    this.liveSteps = const [],
    this.confirmation,
    this.failure,
    this.balance,
    this.lastRequestSpent = 0,
    this.draftAwaitingConsent,
    this.hasUnseenReply = false,
  });

  bool get isBusy => status == AgentSessionStatus.thinking;

  bool get blocksComposer =>
      failure == CreditFailure.creditsExhausted || failure == CreditFailure.subscriptionRequired;

  AgentSessionState copyWith({
    AgentSessionStatus? status,
    List<AgentMessage>? messages,
    List<AgentTurnStep>? liveSteps,
    PendingConfirmation? Function()? confirmation,
    CreditFailure? Function()? failure,
    CreditBalance? balance,
    int? lastRequestSpent,
    String? Function()? draftAwaitingConsent,
    bool? hasUnseenReply,
  }) => AgentSessionState(
    status: status ?? this.status,
    messages: messages ?? this.messages,
    liveSteps: liveSteps ?? this.liveSteps,
    confirmation: confirmation != null ? confirmation() : this.confirmation,
    failure: failure != null ? failure() : this.failure,
    balance: balance ?? this.balance,
    lastRequestSpent: lastRequestSpent ?? this.lastRequestSpent,
    draftAwaitingConsent: draftAwaitingConsent != null ? draftAwaitingConsent() : this.draftAwaitingConsent,
    hasUnseenReply: hasUnseenReply ?? this.hasUnseenReply,
  );
}
