import '../../domain/model/analysis/highlight_span.dart';
import 'keyword_highlight_categories.dart';
import 'source_offset_index.dart';

final class RustSyntaxHighlighter {
  final SourceOffsetIndex _offsets;

  const RustSyntaxHighlighter(this._offsets);

  List<HighlightSpan> project(List<Object?> tokens) {
    final spans = <HighlightSpan>[];
    for (final token in tokens) {
      if (token is! Map<String, Object?>) continue;
      final category = _categoryOf(token);
      final span = token['span'];
      if (category == null || span is! Map<String, Object?>) continue;
      final start = span['start'];
      final end = span['end'];
      if (start is! Map<String, Object?> || end is! Map<String, Object?>) {
        continue;
      }
      final startLine = start['line'];
      final startColumn = start['column'];
      final endLine = end['line'];
      final endColumn = end['column'];
      if (startLine is! int ||
          startColumn is! int ||
          endLine is! int ||
          endColumn is! int) {
        continue;
      }
      spans.add(
        HighlightSpan(
          range: _offsets.rangeOf(
            startLine: startLine,
            startColumn: startColumn,
            endLine: endLine,
            endColumn: endColumn,
          ),
          category: category,
        ),
      );
    }
    return spans;
  }

  HighlightCategory? _categoryOf(Map<String, Object?> token) {
    final kind = token['kind'];
    if (kind == 'identifier') return HighlightCategory.identifier;
    if (kind == 'integer_literal' || kind == 'real_literal') {
      return HighlightCategory.literalNumber;
    }
    if (kind == 'string_literal' || kind == 'character_literal') {
      return HighlightCategory.literalString;
    }
    if (kind == 'boolean_literal') return HighlightCategory.literalBoolean;
    if (kind == 'comment') return HighlightCategory.comment;
    if (kind == 'operator') return HighlightCategory.operator;
    if (kind == 'punctuation') return HighlightCategory.punctuation;
    if (kind != 'keyword') return null;
    return _keywordCategory(token['keyword']);
  }

  HighlightCategory? _keywordCategory(Object? keyword) =>
      keywordHighlightCategories[keyword];
}
