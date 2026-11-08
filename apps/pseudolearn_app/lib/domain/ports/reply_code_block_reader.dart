import '../model/agent/code_block.dart';

abstract interface class ReplyCodeBlockReader {
  List<CodeBlock> read(String markdown);
}
