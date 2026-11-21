import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/engine/rust/utf8_line_offsets.dart';

Utf8LineOffsets offsetsFor(String source) {
  final lineStarts = [0];
  for (var unit = 0; unit < source.length; unit++) {
    if (source.codeUnitAt(unit) == 0x0A) lineStarts.add(unit + 1);
  }
  return Utf8LineOffsets(source, lineStarts);
}

int? referenceUtf16At(String source, int utf8Offset) {
  final bytes = utf8.encode(source);
  if (utf8Offset < 0 || utf8Offset > bytes.length) return null;
  try {
    return utf8.decode(bytes.sublist(0, utf8Offset)).length;
  } on FormatException {
    return null;
  }
}

bool splitsSurrogatePair(String source, int unit) =>
    unit > 0 &&
    unit < source.length &&
    source.codeUnitAt(unit - 1) >= 0xD800 &&
    source.codeUnitAt(unit - 1) <= 0xDBFF &&
    source.codeUnitAt(unit) >= 0xDC00 &&
    source.codeUnitAt(unit) <= 0xDFFF;

void expectMatchesReference(String source) {
  final offsets = offsetsFor(source);
  final byteLength = utf8.encode(source).length;
  expect(offsets.byteLength, byteLength);
  for (var unit = 0; unit <= source.length; unit++) {
    if (splitsSurrogatePair(source, unit)) continue;
    expect(
      offsets.utf8OffsetAt(unit),
      utf8.encode(source.substring(0, unit)).length,
      reason: 'utf8 offset at unit $unit',
    );
  }
  for (var byte = -1; byte <= byteLength + 1; byte++) {
    expect(
      offsets.utf16OffsetAt(byte),
      referenceUtf16At(source, byte),
      reason: 'utf16 offset at byte $byte',
    );
  }
}

void main() {
  group('Utf8LineOffsets', () {
    test('matches the encoder on ASCII across several lines', () {
      expectMatchesReference('Algoritmo A\nEscribir 1;\n\nFinAlgoritmo\n');
    });

    test('matches the encoder on two, three and four byte characters', () {
      expectMatchesReference('año €\n🧩 ñandú\r\n€🧩€\n');
    });

    test('counts unpaired surrogates as the replacement character', () {
      expectMatchesReference('a\uD800b\n\uDC00c\uD83D');
    });

    test('maps an empty source to zero in both directions', () {
      final offsets = offsetsFor('');
      expect(offsets.byteLength, 0);
      expect(offsets.utf8OffsetAt(0), 0);
      expect(offsets.utf16OffsetAt(0), 0);
      expect(offsets.utf16OffsetAt(1), isNull);
    });

    test('rejects byte offsets inside a multibyte character', () {
      final offsets = offsetsFor('€\n🧩');
      expect(offsets.utf16OffsetAt(1), isNull);
      expect(offsets.utf16OffsetAt(2), isNull);
      expect(offsets.utf16OffsetAt(5), isNull);
      expect(offsets.utf16OffsetAt(8), 4);
    });

    test('rejects negative and past-the-end byte offsets', () {
      final offsets = offsetsFor('ab');
      expect(offsets.utf16OffsetAt(-1), isNull);
      expect(offsets.utf16OffsetAt(3), isNull);
    });

    test('resolves offsets at the start of a single character line', () {
      final offsets = offsetsFor('x\ny\nz');
      expect(offsets.utf8OffsetAt(4), 4);
      expect(offsets.utf16OffsetAt(2), 2);
    });
  });
}
