import 'source_range.dart';

enum HighlightCategory {
  keywordStructured,
  keywordProcedural,
  keywordOop,
  identifier,
  type,
  literalNumber,
  literalString,
  literalBoolean,
  operator,
  punctuation,
  comment,
}

final class HighlightSpan {
  final SourceRange range;
  final HighlightCategory category;

  const HighlightSpan({
    required this.range,
    required this.category,
  });
}
