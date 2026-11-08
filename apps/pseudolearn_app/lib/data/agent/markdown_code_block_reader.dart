import '../../domain/model/agent/code_block.dart';
import '../../domain/ports/reply_code_block_reader.dart';

final RegExp _fence = RegExp(r'```([A-Za-z0-9_+-]*)[^\n]*\n([\s\S]*?)```');

final class MarkdownCodeBlockReader implements ReplyCodeBlockReader {
  const MarkdownCodeBlockReader();

  @override
  List<CodeBlock> read(String markdown) => [
    for (final match in _fence.allMatches(markdown))
      CodeBlock(
        language: (match.group(1) ?? '').toLowerCase(),
        source: match.group(2) ?? '',
        start: match.start,
        end: match.end,
      ),
  ];
}
