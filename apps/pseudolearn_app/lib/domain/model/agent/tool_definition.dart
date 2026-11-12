enum ToolRisk { read, write, destructive }

final class ToolDefinition {
  final String name;
  final String description;
  final Map<String, Object?> parameters;
  final ToolRisk risk;
  final String stepLabel;

  const ToolDefinition({
    required this.name,
    required this.description,
    required this.parameters,
    required this.risk,
    required this.stepLabel,
  });
}
