import '../../domain/model/agent/tool_definition.dart';
import 'tools/agent_tool.dart';
import 'tools/tool_arguments.dart';

final class ConfirmationPolicy {
  const ConfirmationPolicy();

  bool requiresConfirmation(AgentTool tool, ToolArguments arguments) =>
      tool.definition.risk == ToolRisk.destructive || tool.needsConfirmation(arguments);
}
