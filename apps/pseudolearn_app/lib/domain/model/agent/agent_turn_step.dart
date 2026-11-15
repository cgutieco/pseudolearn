enum AgentStepStatus { succeeded, failed, declined }

final class AgentTurnStep {
  final String toolName;
  final String label;
  final AgentStepStatus status;
  final String summary;

  const AgentTurnStep({
    required this.toolName,
    required this.label,
    required this.status,
    this.summary = '',
  });
}
