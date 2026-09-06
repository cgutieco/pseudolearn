import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/analysis/highlight_span.dart';
import 'package:pseudolearn_app/engine/mapping/span_projection.dart';
import 'package:pseudolearn_core/pseudolearn_core.dart';

void main() {
  group('SpanProjection', () {
    test('projects core Span to SourceRange', () {
      final span = Span(
        start: const Position(line: 2, column: 5, offset: 12),
        end: const Position(line: 2, column: 15, offset: 22),
      );

      final range = SpanProjection.toSourceRange(span);
      expect(range.startLine, 2);
      expect(range.startColumn, 5);
      expect(range.startOffset, 12);
      expect(range.endLine, 2);
      expect(range.endColumn, 15);
      expect(range.endOffset, 22);
    });

    test('projects token to HighlightSpan with correct category', () {
      final token = Token(
        type: TokenType.ifKeyword,
        lexeme: 'si',
        span: Span(
          start: const Position(line: 1, column: 1, offset: 0),
          end: const Position(line: 1, column: 3, offset: 2),
        ),
      );

      final highlight = SpanProjection.toHighlightSpan(token);
      expect(highlight, isNotNull);
      expect(highlight!.category, HighlightCategory.keywordStructured);
      expect(highlight.range.startOffset, 0);
      expect(highlight.range.endOffset, 2);
    });
  });
}
