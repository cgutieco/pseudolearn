final class Utf16LinePosition {
  final int line;
  final int column;

  const Utf16LinePosition({required this.line, required this.column});
}

final class Utf16LineIndex {
  final String _source;
  final List<int> _lineStarts = [0];

  Utf16LineIndex(this._source) {
    for (var offset = 0; offset < _source.length; offset++) {
      if (_source.codeUnitAt(offset) == 0x0A) _lineStarts.add(offset + 1);
    }
  }

  Utf16LinePosition? positionAt(int offset) {
    if (offset < 0 || offset > _source.length) return null;
    if (_splitsSurrogatePair(offset)) return null;
    var line = _lineStarts.length - 1;
    while (_lineStarts[line] > offset) {
      line--;
    }
    return Utf16LinePosition(
      line: line + 1,
      column: offset - _lineStarts[line] + 1,
    );
  }

  int? offsetAtScalarColumn({required int line, required int column}) {
    if (line < 1 || line > _lineStarts.length || column < 1) return null;
    var offset = _lineStarts[line - 1];
    for (var skipped = 1; skipped < column; skipped++) {
      if (offset >= _source.length) return null;
      offset += _isHighSurrogateAt(offset) ? 2 : 1;
    }
    return offset > _source.length ? null : offset;
  }

  bool _isHighSurrogateAt(int offset) {
    final unit = _source.codeUnitAt(offset);
    return unit >= 0xD800 && unit <= 0xDBFF && offset + 1 < _source.length;
  }

  bool _splitsSurrogatePair(int offset) {
    if (offset == 0 || offset == _source.length) return false;
    final previous = _source.codeUnitAt(offset - 1);
    final current = _source.codeUnitAt(offset);
    return previous >= 0xD800 &&
        previous <= 0xDBFF &&
        current >= 0xDC00 &&
        current <= 0xDFFF;
  }
}
