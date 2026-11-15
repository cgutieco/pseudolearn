import '../../../domain/model/analysis/highlight_span.dart';
import '../../../domain/model/analysis/source_range.dart';
import 'code_language.dart';
import 'lexical_token_scanner.dart';

List<HighlightSpan> highlightLexically(String source, CodeLanguage language) {
  final scanner = LexicalTokenScanner(source, language);
  final positions = _LinePositions(source);
  final spans = <HighlightSpan>[];
  var cursor = 0;
  while (cursor < source.length) {
    final token = scanner.tokenAt(cursor);
    final category = token.category;
    if (category != null) {
      spans.add(HighlightSpan(range: positions.range(cursor, token.end), category: category));
    }
    cursor = token.end > cursor ? token.end : cursor + 1;
  }
  return spans;
}

final class _LinePositions {
  final List<int> _lineStarts;

  _LinePositions(String source)
    : _lineStarts = [
        0,
        for (final (index, unit) in source.codeUnits.indexed)
          if (unit == 0x0A) index + 1,
      ];

  SourceRange range(int start, int end) {
    final startLine = _lineOf(start);
    final endLine = _lineOf(end);
    return SourceRange(
      startOffset: start,
      endOffset: end,
      startLine: startLine + 1,
      startColumn: start - _lineStarts[startLine] + 1,
      endLine: endLine + 1,
      endColumn: end - _lineStarts[endLine] + 1,
    );
  }

  int _lineOf(int offset) {
    var line = 0;
    while (line + 1 < _lineStarts.length && _lineStarts[line + 1] <= offset) {
      line += 1;
    }
    return line;
  }
}
