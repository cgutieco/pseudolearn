import 'dart:convert';

import '../../domain/model/analysis/source_range.dart';

final class SourceOffsetIndex {
  final String _source;
  final List<int> _lineStarts = [0];

  SourceOffsetIndex(this._source) {
    for (var offset = 0; offset < _source.length; offset++) {
      if (_source.codeUnitAt(offset) == 0x0A) _lineStarts.add(offset + 1);
    }
  }

  String get sourceCode => _source;

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

  bool isValidPosition(int line, int column) {
    if (line < 1 || line > _lineStarts.length || column < 1) return false;
    final lineIndex = line - 1;
    final start = _lineStarts[lineIndex];
    var end = lineIndex + 1 < _lineStarts.length
        ? _lineStarts[lineIndex + 1] - 1
        : _source.length;
    if (end > start && _source.codeUnitAt(end - 1) == 0x0D) end--;
    var offset = start;
    var currentColumn = 1;
    while (offset < end) {
      final first = _source.codeUnitAt(offset);
      final paired =
          first >= 0xD800 &&
          first <= 0xDBFF &&
          offset + 1 < end &&
          _isLowSurrogate(_source.codeUnitAt(offset + 1));
      offset += paired ? 2 : 1;
      currentColumn++;
    }
    return column <= currentColumn;
  }

  int? utf8OffsetAtUtf16(int offset) {
    if (offset < 0 || offset > _source.length) return null;
    if (offset > 0 && offset < _source.length) {
      final previous = _source.codeUnitAt(offset - 1);
      final current = _source.codeUnitAt(offset);
      if (_isHighSurrogate(previous) && _isLowSurrogate(current)) return null;
    }
    return utf8.encode(_source.substring(0, offset)).length;
  }

  int? utf16OffsetAtUtf8(int offset) {
    final bytes = utf8.encode(_source);
    if (offset < 0 || offset > bytes.length) return null;
    try {
      return utf8.decode(bytes.sublist(0, offset)).length;
    } on FormatException {
      return null;
    }
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

  bool _isHighSurrogate(int codeUnit) =>
      codeUnit >= 0xD800 && codeUnit <= 0xDBFF;

  bool _isLowSurrogate(int codeUnit) =>
      codeUnit >= 0xDC00 && codeUnit <= 0xDFFF;
}
