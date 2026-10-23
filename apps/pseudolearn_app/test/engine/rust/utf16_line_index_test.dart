import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/engine/rust/utf16_line_index.dart';

void main() {
  group('Utf16LineIndex', () {
    test('maps offsets to one-based lines and UTF-16 columns', () {
      final index = Utf16LineIndex('ab\ncd\n');
      expect(index.positionAt(0)?.line, 1);
      expect(index.positionAt(0)?.column, 1);
      expect(index.positionAt(4)?.line, 2);
      expect(index.positionAt(4)?.column, 2);
      expect(index.positionAt(6)?.line, 3);
      expect(index.positionAt(6)?.column, 1);
    });

    test('counts a supplementary scalar as two columns', () {
      final index = Utf16LineIndex('a🧩b');
      expect(index.positionAt(3)?.column, 4);
      expect(index.offsetAtScalarColumn(line: 1, column: 3), 3);
    });

    test('rejects offsets inside a surrogate pair and out of range', () {
      final index = Utf16LineIndex('a🧩b');
      expect(index.positionAt(2), isNull);
      expect(index.positionAt(-1), isNull);
      expect(index.positionAt(5), isNull);
    });

    test('handles CRLF text and the empty document', () {
      final crlf = Utf16LineIndex('a\r\nb');
      expect(crlf.positionAt(3)?.line, 2);
      expect(crlf.positionAt(3)?.column, 1);
      final empty = Utf16LineIndex('');
      expect(empty.positionAt(0)?.line, 1);
      expect(empty.positionAt(0)?.column, 1);
      expect(empty.positionAt(1), isNull);
    });

    test('scalar columns count a supplementary scalar once', () {
      final index = Utf16LineIndex('x\n"🧩"; ab');
      expect(index.offsetAtScalarColumn(line: 2, column: 1), 2);
      expect(index.offsetAtScalarColumn(line: 2, column: 3), 5);
      expect(index.offsetAtScalarColumn(line: 2, column: 4), 6);
      expect(index.offsetAtScalarColumn(line: 2, column: 8), 10);
      expect(index.offsetAtScalarColumn(line: 2, column: 9), isNull);
    });

    test('offsetAtScalarColumn rejects positions outside the text', () {
      final index = Utf16LineIndex('ab\ncd');
      expect(index.offsetAtScalarColumn(line: 0, column: 1), isNull);
      expect(index.offsetAtScalarColumn(line: 3, column: 1), isNull);
      expect(index.offsetAtScalarColumn(line: 1, column: 0), isNull);
      expect(index.offsetAtScalarColumn(line: 2, column: 9), isNull);
      expect(index.offsetAtScalarColumn(line: 2, column: 2), 4);
    });
  });
}
