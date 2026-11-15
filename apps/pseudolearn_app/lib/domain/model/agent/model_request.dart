import 'model_item.dart';
import 'tool_definition.dart';

final class ModelRequest {
  final String instructions;
  final List<ModelItem> input;
  final List<ToolDefinition> tools;

  const ModelRequest({
    required this.instructions,
    required this.input,
    required this.tools,
  });
}
