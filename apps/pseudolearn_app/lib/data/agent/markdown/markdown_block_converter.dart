import 'package:markdown/markdown.dart' as md;
import '../../../domain/model/agent/code_block.dart';
import '../../../domain/model/agent/flowchart.dart';
import '../../../domain/model/agent/reply_block.dart';
import 'markdown_inline_converter.dart';
import 'markdown_list_converter.dart';
import 'markdown_table_converter.dart';

const Set<String> _headingTags = {'h1', 'h2', 'h3', 'h4', 'h5', 'h6'};
const String _diagramLanguage = 'mermaid';
const String _languageClassPrefix = 'language-';

typedef FlowchartParser = Flowchart? Function(String source);

final class MarkdownBlockConverter {
  final FlowchartParser _parseFlowchart;
  final List<CodeBlock> codeBlocks = [];

  MarkdownBlockConverter(this._parseFlowchart);

  List<ReplyBlock> blocks(List<md.Node> nodes) {
    final blocks = <ReplyBlock>[];
    final pendingInline = <md.Node>[];
    for (final node in nodes) {
      if (_isBlock(node)) {
        _flushInline(pendingInline, blocks);
        blocks.addAll(_converted(node as md.Element));
      } else {
        pendingInline.add(node);
      }
    }
    _flushInline(pendingInline, blocks);
    return blocks;
  }

  void _flushInline(List<md.Node> pending, List<ReplyBlock> blocks) {
    if (pending.isEmpty) return;
    final runs = inlineRuns(List.of(pending));
    pending.clear();
    if (runs.isNotEmpty) blocks.add(ReplyParagraph(runs));
  }

  List<ReplyBlock> _converted(md.Element element) {
    final tag = element.tag;
    if (_headingTags.contains(tag)) {
      return [ReplyHeading(level: int.parse(tag.substring(1)), runs: inlineRuns(_children(element)))];
    }
    return switch (tag) {
      'p' => _paragraph(element),
      'ul' || 'ol' => [listOf(element, blocks)],
      'blockquote' => [ReplyQuote(blocks: blocks(_children(element)))],
      'div' => [_alertOrGroup(element)],
      'pre' => [_fenced(element)],
      'hr' => const [ReplyRule()],
      'table' => [tableOf(element)],
      _ => blocks(_children(element)),
    };
  }

  List<ReplyBlock> _paragraph(md.Element element) {
    final runs = inlineRuns(_children(element));
    return runs.isEmpty ? const [] : [ReplyParagraph(runs)];
  }

  ReplyBlock _alertOrGroup(md.Element element) {
    final kind = alertKindOf(element.attributes['class'] ?? '');
    final children = _children(element);
    if (kind == null) return ReplyQuote(blocks: blocks(children));
    return ReplyQuote(kind: kind, blocks: blocks(children.skip(1).toList()));
  }

  ReplyBlock _fenced(md.Element element) {
    final code = _children(element).whereType<md.Element>().firstOrNull;
    final language = _languageOf(code);
    final source = _withoutFinalNewline((code ?? element).textContent);
    if (language == _diagramLanguage) {
      return ReplyDiagram(source: source, flowchart: _parseFlowchart(source));
    }
    codeBlocks.add(CodeBlock(language: language, source: source));
    return ReplyCode(codeBlocks.length - 1);
  }
}

bool _isBlock(md.Node node) =>
    node is md.Element && (_headingTags.contains(node.tag) || _blockTags.contains(node.tag));

const Set<String> _blockTags = {
  'p', 'ul', 'ol', 'li', 'blockquote', 'div', 'pre', 'hr', 'table', 'section',
};

List<md.Node> _children(md.Element element) => element.children ?? const [];

String _languageOf(md.Element? code) {
  final classes = (code?.attributes['class'] ?? '').split(' ');
  final declared = classes.where((name) => name.startsWith(_languageClassPrefix)).firstOrNull;
  return (declared?.substring(_languageClassPrefix.length) ?? '').toLowerCase();
}

String _withoutFinalNewline(String source) =>
    source.endsWith('\n') ? source.substring(0, source.length - 1) : source;

const Map<String, ReplyQuoteKind> _alertKinds = {
  'markdown-alert-note': ReplyQuoteKind.note,
  'markdown-alert-tip': ReplyQuoteKind.tip,
  'markdown-alert-important': ReplyQuoteKind.important,
  'markdown-alert-warning': ReplyQuoteKind.warning,
  'markdown-alert-caution': ReplyQuoteKind.caution,
};

ReplyQuoteKind? alertKindOf(String classes) {
  for (final name in classes.split(' ')) {
    final kind = _alertKinds[name];
    if (kind != null) return kind;
  }
  return null;
}
