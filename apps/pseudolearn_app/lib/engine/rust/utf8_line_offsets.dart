final class Utf8LineOffsets {
  final String _source;
  final List<int> _lineStartUnits;
  final List<int> _lineStartBytes;
  final int byteLength;

  const Utf8LineOffsets._({
    required this._source,
    required this._lineStartUnits,
    required this._lineStartBytes,
    required this.byteLength,
  });

  factory Utf8LineOffsets(String source, List<int> lineStartUnits) {
    final lineStartBytes = <int>[0];
    var bytes = 0;
    var unit = 0;
    while (unit < source.length) {
      final (unitWidth, byteWidth) = _encodedWidth(source, unit);
      if (source.codeUnitAt(unit) == 0x0A) {
        lineStartBytes.add(bytes + byteWidth);
      }
      unit += unitWidth;
      bytes += byteWidth;
    }
    return Utf8LineOffsets._(
      source: source,
      lineStartUnits: lineStartUnits,
      lineStartBytes: lineStartBytes,
      byteLength: bytes,
    );
  }

  int utf8OffsetAt(int utf16Offset) {
    final line = _lastStartAtOrBefore(_lineStartUnits, utf16Offset);
    var unit = _lineStartUnits[line];
    var bytes = _lineStartBytes[line];
    while (unit < utf16Offset) {
      final (unitWidth, byteWidth) = _encodedWidth(_source, unit);
      unit += unitWidth;
      bytes += byteWidth;
    }
    return bytes;
  }

  int? utf16OffsetAt(int utf8Offset) {
    if (utf8Offset < 0 || utf8Offset > byteLength) return null;
    final line = _lastStartAtOrBefore(_lineStartBytes, utf8Offset);
    var unit = _lineStartUnits[line];
    var bytes = _lineStartBytes[line];
    while (bytes < utf8Offset) {
      final (unitWidth, byteWidth) = _encodedWidth(_source, unit);
      unit += unitWidth;
      bytes += byteWidth;
    }
    return bytes == utf8Offset ? unit : null;
  }

  static int _lastStartAtOrBefore(List<int> starts, int target) {
    var low = 0;
    var high = starts.length - 1;
    while (low < high) {
      final middle = (low + high + 1) ~/ 2;
      if (starts[middle] <= target) {
        low = middle;
      } else {
        high = middle - 1;
      }
    }
    return low;
  }

  static (int, int) _encodedWidth(String source, int unit) {
    final codeUnit = source.codeUnitAt(unit);
    if (codeUnit < 0x80) return (1, 1);
    if (codeUnit < 0x800) return (1, 2);
    final startsPair =
        codeUnit >= 0xD800 &&
        codeUnit <= 0xDBFF &&
        unit + 1 < source.length &&
        source.codeUnitAt(unit + 1) >= 0xDC00 &&
        source.codeUnitAt(unit + 1) <= 0xDFFF;
    return startsPair ? (2, 4) : (1, 3);
  }
}
