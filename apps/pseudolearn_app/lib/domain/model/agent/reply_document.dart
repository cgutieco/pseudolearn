import 'code_block.dart';
import 'reply_block.dart';

final class ReplyDocument {
  final List<ReplyBlock> blocks;
  final List<CodeBlock> codeBlocks;

  const ReplyDocument({required this.blocks, required this.codeBlocks});

  static const ReplyDocument empty = ReplyDocument(blocks: [], codeBlocks: []);
}
