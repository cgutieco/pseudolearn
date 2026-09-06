import 'package:markdown/markdown.dart' as md;
import '../../domain/model/knowledge/content_block.dart';
import 'html_entities.dart';

final class MarkdownBlockParser {
  const MarkdownBlockParser();

  List<ContentBlock> parse(String markdownSource) {
    if (markdownSource.trim().isEmpty) {
      return const [];
    }

    final lines = markdownSource.split('\n');
    final document = md.Document(
      blockSyntaxes: const [
        md.FencedCodeBlockSyntax(),
        md.TableSyntax(),
        md.HeaderSyntax(),
        md.BlockquoteSyntax(),
        md.UnorderedListSyntax(),
        md.OrderedListSyntax(),
      ],
    );

    final nodes = document.parseLines(lines);
    final blocks = <ContentBlock>[];

    for (final node in nodes) {
      if (node is md.Element) {
        final block = _convertElementToBlock(node);
        if (block != null) {
          blocks.add(block);
        }
      }
    }

    return blocks;
  }

  ContentBlock? _convertElementToBlock(md.Element element) {
    return switch (element.tag) {
      'h1' => HeadingBlock(
          level: 1, text: unescapeHtmlEntities(element.textContent.trim())),
      'h2' => HeadingBlock(
          level: 2, text: unescapeHtmlEntities(element.textContent.trim())),
      'h3' => HeadingBlock(
          level: 3, text: unescapeHtmlEntities(element.textContent.trim())),
      'p' =>
        ParagraphBlock(text: unescapeHtmlEntities(element.textContent.trim())),
      'blockquote' =>
        QuoteBlock(text: unescapeHtmlEntities(element.textContent.trim())),
      'ul' => ListBlock(items: _extractListItems(element), isOrdered: false),
      'ol' => ListBlock(items: _extractListItems(element), isOrdered: true),
      'pre' => _extractCodeBlock(element),
      'table' => _extractTableBlock(element),
      _ =>
        ParagraphBlock(text: unescapeHtmlEntities(element.textContent.trim())),
    };
  }

  List<String> _extractListItems(md.Element listElement) {
    final items = <String>[];
    for (final child in listElement.children ?? const <md.Node>[]) {
      if (child is md.Element && child.tag == 'li') {
        items.add(unescapeHtmlEntities(child.textContent.trim()));
      }
    }
    return items;
  }

  TableBlock _extractTableBlock(md.Element element) {
    final rows = <List<String>>[];
    for (final section in element.children ?? const <md.Node>[]) {
      if (section is md.Element) rows.addAll(_extractTableRows(section));
    }
    if (rows.isEmpty) return const TableBlock(headers: [], rows: []);
    return TableBlock(headers: rows.first, rows: rows.sublist(1));
  }

  List<List<String>> _extractTableRows(md.Element section) {
    final rows = <List<String>>[];
    for (final row in section.children ?? const <md.Node>[]) {
      if (row is! md.Element || row.tag != 'tr') continue;
      final cells = <String>[];
      for (final cell in row.children ?? const <md.Node>[]) {
        if (cell is md.Element) {
          cells.add(unescapeHtmlEntities(cell.textContent.trim()));
        }
      }
      rows.add(cells);
    }
    return rows;
  }

  CodeBlock _extractCodeBlock(md.Element preElement) {
    final codeChild = preElement.children?.whereType<md.Element>().firstOrNull;
    final codeText = unescapeHtmlEntities(preElement.textContent);
    final classAttr = codeChild?.attributes['class'] ?? '';
    final language = classAttr.startsWith('language-')
        ? classAttr.substring('language-'.length)
        : 'pseudo';

    return CodeBlock(
      code: codeText.endsWith('\n')
          ? codeText.substring(0, codeText.length - 1)
          : codeText,
      language: language.isEmpty ? 'pseudo' : language,
    );
  }
}
