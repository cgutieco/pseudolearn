import 'package:markdown/markdown.dart' as md;
import '../../../domain/model/agent/reply_document.dart';
import '../../../domain/ports/reply_markdown_reader.dart';
import '../mermaid/mermaid_flowchart_parser.dart';
import 'markdown_block_converter.dart';

final class MarkdownReplyReader implements ReplyMarkdownReader {
  final FlowchartParser _parseFlowchart;

  const MarkdownReplyReader({this._parseFlowchart = parseMermaidFlowchart});

  @override
  ReplyDocument read(String markdown) {
    if (markdown.trim().isEmpty) return ReplyDocument.empty;
    final converter = MarkdownBlockConverter(_parseFlowchart);
    final blocks = converter.blocks(_document().parse(markdown));
    return ReplyDocument(blocks: blocks, codeBlocks: List.unmodifiable(converter.codeBlocks));
  }
}

md.Document _document() => md.Document(
  encodeHtml: false,
  blockSyntaxes: [...md.ExtensionSet.gitHubFlavored.blockSyntaxes, const md.AlertBlockSyntax()],
  inlineSyntaxes: [...md.ExtensionSet.gitHubFlavored.inlineSyntaxes, md.EmojiSyntax()],
  withDefaultBlockSyntaxes: true,
  withDefaultInlineSyntaxes: true,
);
