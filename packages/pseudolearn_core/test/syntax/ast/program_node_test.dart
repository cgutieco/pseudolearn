import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';

void main() {
  group('AlgorithmNode', () {
    test('creates algorithm node with non-empty body and exact span', () {
      const id = NodeId(1);
      final span = Span(
        start: const Position(line: 1, column: 1, offset: 0),
        end: const Position(line: 3, column: 11, offset: 35),
      );
      final nameSpan = Span(
        start: const Position(line: 1, column: 9, offset: 8),
        end: const Position(line: 1, column: 14, offset: 13),
      );
      final statement = ErrorStatementNode(
        id: const NodeId(2),
        span: Span(
          start: const Position(line: 2, column: 3, offset: 17),
          end: const Position(line: 2, column: 10, offset: 24),
        ),
      );

      final node = AlgorithmNode(
        id: id,
        span: span,
        name: 'Sumar',
        nameSpan: nameSpan,
        body: [statement],
      );

      expect(node.id, id);
      expect(node.span, span);
      expect(node.name, 'Sumar');
      expect(node.nameSpan, nameSpan);
      expect(node.body, hasLength(1));
      expect(node.body.first, same(statement));
    });

    test('creates algorithm node with empty body', () {
      final span = Span(
        start: const Position(line: 1, column: 1, offset: 0),
        end: const Position(line: 2, column: 11, offset: 20),
      );
      final nameSpan = Span(
        start: const Position(line: 1, column: 9, offset: 8),
        end: const Position(line: 1, column: 13, offset: 12),
      );

      final node = AlgorithmNode(
        id: const NodeId(1),
        span: span,
        name: 'Test',
        nameSpan: nameSpan,
        body: const [],
      );

      expect(node.body, isEmpty);
    });
  });
}
