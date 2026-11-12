import '../../../domain/model/agent/tool_definition.dart';
import '../../../domain/ports/screen_context_source.dart';
import 'agent_tool.dart';
import 'tool_arguments.dart';
import 'tool_execution.dart';
import 'tool_schema.dart';

final class ScreenContextTool extends DirectTool {
  final ScreenContextSource _source;

  const ScreenContextTool(this._source);

  @override
  ToolDefinition get definition => ToolDefinition(
    name: 'get_screen_context',
    description:
        'Returns what the person is looking at now, including the full text of the screen '
        '(the open document source, the visible lesson or specification section). Hidden test '
        'cases are never included.',
    parameters: objectSchema(const {}),
    risk: ToolRisk.read,
    stepLabel: 'agentStepReadScreen',
  );

  @override
  Future<ToolExecution> run(ToolArguments arguments) async {
    final snapshot = _source.snapshot();
    return ToolExecution.done({
      'screen': snapshot.screen,
      'route': snapshot.route,
      'fields': snapshot.fields,
      'full_text': _source.fullText(),
    });
  }
}
