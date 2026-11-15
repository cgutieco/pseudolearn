final class AgentCase {
  final List<String> inputs;
  final String expected;
  final bool hidden;

  const AgentCase({
    required this.inputs,
    required this.expected,
    required this.hidden,
  });

  Map<String, Object?> toJson() => {
    'inputs': inputs,
    'expected': expected,
    'hidden': hidden,
  };
}

final class AgentTask {
  final String id;
  final String kind;
  final String title;
  final String statement;
  final String? starter;
  final List<AgentCase> cases;

  const AgentTask({
    required this.id,
    required this.kind,
    required this.title,
    required this.statement,
    required this.starter,
    required this.cases,
  });

  Map<String, Object?> toJson() => {
    'id': id,
    'kind': kind,
    'title': title,
    'statement': statement,
    'starter': starter,
    'cases': [for (final item in cases) item.toJson()],
  };
}
