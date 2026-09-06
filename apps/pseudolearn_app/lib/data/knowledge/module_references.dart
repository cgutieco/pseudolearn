import '../../domain/model/knowledge/content_block.dart';
import '../../domain/model/knowledge/prediction_activity.dart';

List<String> leadingTokensOfListItems(List<ContentBlock> blocks) {
  final tokens = <String>[];
  for (final block in blocks) {
    if (block is! ListBlock) continue;
    for (final item in block.items) {
      final token = _leadingTokenOf(item);
      if (token.isNotEmpty) tokens.add(token);
    }
  }
  return tokens;
}

PredictionActivity? predictionActivityOf(
  List<ContentBlock> blocks,
  String moduleId,
) {
  if (blocks.isEmpty) return null;
  final data = leadingTokensOfListItems(blocks);
  if (data.isEmpty) return null;
  final fields = data.first.split('#');
  if (fields.length != 3) return null;
  final stepNumber = int.tryParse(fields[1]);
  if (stepNumber == null) return null;
  return PredictionActivity(
    id: '$moduleId-P1',
    exampleId: fields[0],
    prompt: _firstParagraphOf(blocks),
    stepNumber: stepNumber,
    variableName: fields[2].isEmpty ? null : fields[2],
  );
}

String _firstParagraphOf(List<ContentBlock> blocks) {
  for (final block in blocks) {
    if (block is ParagraphBlock) return block.text;
  }
  return '';
}

String _leadingTokenOf(String item) {
  final trimmed = item.trim();
  final space = trimmed.indexOf(' ');
  return space < 0 ? trimmed : trimmed.substring(0, space);
}
