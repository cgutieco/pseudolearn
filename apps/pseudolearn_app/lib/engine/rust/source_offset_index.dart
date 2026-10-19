import '../../domain/model/analysis/source_range.dart';

final class SourceOffsetIndex {
  final String _source;
  final List<int> _lineStarts = [0];

  SourceOffsetIndex(this._source) {
    for (var offset = 0; offset < _source.length; offset++) {
      if (_source.codeUnitAt(offset) == 0x0A) _lineStarts.add(offset + 1);
    }
  }

  int offsetOf(int line, int column) {
    final index = (line - 1).clamp(0, _lineStarts.length - 1);
    var offset = _lineStarts[index];
    var remaining = column - 1;
    while (remaining > 0 && offset < _source.length) {
      offset +=
          _source.codeUnitAt(offset) >= 0xD800 &&
              _source.codeUnitAt(offset) <= 0xDBFF
          ? 2
          : 1;
      remaining--;
    }
    return offset.clamp(0, _source.length);
  }

  SourceRange rangeOf({
    required int startLine,
    required int startColumn,
    required int endLine,
    required int endColumn,
  }) {
    return SourceRange(
      startOffset: offsetOf(startLine, startColumn),
      endOffset: offsetOf(endLine, endColumn),
      startLine: startLine,
      startColumn: startColumn,
      endLine: endLine,
      endColumn: endColumn,
    );
  }

  String textBetween(SourceRange range) =>
      _source.substring(range.startOffset, range.endOffset);
}
