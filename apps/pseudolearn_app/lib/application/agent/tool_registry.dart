import '../../domain/model/agent/tool_definition.dart';
import 'tools/agent_tool.dart';

final class ToolRegistry {
  final Map<String, AgentTool> _tools;

  ToolRegistry(List<AgentTool> tools)
    : _tools = {for (final tool in tools) tool.definition.name: tool};

  AgentTool? named(String name) => _tools[name];

  List<ToolDefinition> get definitions => [
    for (final tool in _tools.values) tool.definition,
  ];
}
