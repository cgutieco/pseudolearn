sealed class ModelItem {
  const ModelItem();
}

final class UserTextItem extends ModelItem {
  final String text;

  const UserTextItem(this.text);
}

final class AssistantTextItem extends ModelItem {
  final String text;

  const AssistantTextItem(this.text);
}

final class ToolCallItem extends ModelItem {
  final String callId;
  final String name;
  final String arguments;

  const ToolCallItem({
    required this.callId,
    required this.name,
    required this.arguments,
  });
}

final class ToolOutputItem extends ModelItem {
  final String callId;
  final String output;

  const ToolOutputItem({required this.callId, required this.output});
}
