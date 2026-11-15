import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/analysis/source_range.dart';
import 'package:pseudolearn_app/engine/rust/source_offset_index.dart';
import 'package:pseudolearn_app/engine/rust/source_offset_text.dart';

void main() {
  test('extracts text using a source range', () {
    final index = SourceOffsetIndex('Escribir 1;');
    final range = index.rangeOf(
      startLine: 1,
      startColumn: 10,
      endLine: 1,
      endColumn: 11,
    );
    expect(index.textBetween(range), '1');
  });

  test('extracts an empty range', () {
    final index = SourceOffsetIndex('');
    expect(
      index.textBetween(
        const SourceRange(
          startOffset: 0,
          endOffset: 0,
          startLine: 1,
          startColumn: 1,
          endLine: 1,
          endColumn: 1,
        ),
      ),
      '',
    );
  });
}
