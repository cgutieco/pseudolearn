import '../../../domain/model/agent/tool_definition.dart';
import 'tool_arguments.dart';
import 'tool_execution.dart';

abstract interface class AgentTool {
  ToolDefinition get definition;

  bool needsConfirmation(ToolArguments arguments);

  Future<ToolExecution> run(ToolArguments arguments);
}

abstract base class DirectTool implements AgentTool {
  const DirectTool();

  @override
  bool needsConfirmation(ToolArguments arguments) => false;
}

abstract base class ConfirmedTool implements AgentTool {
  const ConfirmedTool();

  @override
  bool needsConfirmation(ToolArguments arguments) => true;
}
