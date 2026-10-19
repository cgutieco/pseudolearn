import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/engine/rust/source_offset_index.dart';

void main() {
  group('SourceOffsetIndex', () {
    test('maps one based line and column to offsets', () {
      final index = SourceOffsetIndex('ab\ncd\n');
      expect(index.offsetOf(1, 1), 0);
      expect(index.offsetOf(2, 2), 4);
    });

    test('counts a surrogate pair as one column but two code units', () {
      final index = SourceOffsetIndex('a🧩b\n');
      expect(index.offsetOf(1, 3), 3);
      expect(index.offsetOf(1, 4), 4);
    });

    test('converts UTF-16 cursor offsets to UTF-8 boundaries', () {
      final index = SourceOffsetIndex('a🧩b');
      expect(index.utf8OffsetAtUtf16(1), 1);
      expect(index.utf8OffsetAtUtf16(2), isNull);
      expect(index.utf8OffsetAtUtf16(3), 5);
      expect(index.utf8OffsetAtUtf16(4), 6);
    });

    test('converts UTF-8 edit offsets to UTF-16 boundaries', () {
      final index = SourceOffsetIndex('a🧩b');
      expect(index.utf16OffsetAtUtf8(1), 1);
      expect(index.utf16OffsetAtUtf8(2), isNull);
      expect(index.utf16OffsetAtUtf8(5), 3);
      expect(index.utf16OffsetAtUtf8(6), 4);
      expect(index.utf16OffsetAtUtf8(7), isNull);
    });

    test('clamps positions beyond the source', () {
      final index = SourceOffsetIndex('ab');
      expect(index.offsetOf(9, 9), 2);
      expect(index.offsetOf(0, 0), 0);
    });

    test('handles an empty source', () {
      final index = SourceOffsetIndex('');
      expect(index.offsetOf(1, 1), 0);
      expect(
        index.textBetween(
          index.rangeOf(startLine: 1, startColumn: 1, endLine: 1, endColumn: 1),
        ),
        '',
      );
    });

    test('builds a range with text', () {
      final index = SourceOffsetIndex('Escribir 1;\n');
      final range = index.rangeOf(
        startLine: 1,
        startColumn: 10,
        endLine: 1,
        endColumn: 11,
      );
      expect(index.textBetween(range), '1');
    });
  });
}
