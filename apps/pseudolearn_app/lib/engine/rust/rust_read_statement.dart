final class RustReadStatement {
  final String text;
  final List<String> designators;

  const RustReadStatement._(this.text, this.designators);

  factory RustReadStatement.parse(String source) {
    final text = _collapsedWhitespace(source.trim());
    final withoutTerminator = text.endsWith(';')
        ? text.substring(0, text.length - 1).trimRight()
        : text;
    final separator = withoutTerminator.indexOf(' ');
    final arguments = separator < 0
        ? ''
        : withoutTerminator.substring(separator + 1);
    return RustReadStatement._(text, _topLevelParts(arguments));
  }

  String designatorAt(int position) {
    if (designators.isEmpty) return '';
    if (position < 0 || position >= designators.length) {
      return designators.join(', ');
    }
    return designators[position];
  }

  static String _collapsedWhitespace(String text) {
    final buffer = StringBuffer();
    var previousWasSpace = false;
    for (final rune in text.runes) {
      final isSpace =
          rune == 0x20 || rune == 0x09 || rune == 0x0A || rune == 0x0D;
      if (isSpace && previousWasSpace) continue;
      buffer.writeCharCode(isSpace ? 0x20 : rune);
      previousWasSpace = isSpace;
    }
    return buffer.toString();
  }

  static List<String> _topLevelParts(String arguments) {
    final scanner = _ArgumentScanner();
    for (final unit in arguments.codeUnits) {
      scanner.accept(unit);
    }
    return scanner.finish();
  }
}

final class _ArgumentScanner {
  final List<String> _parts = [];
  final StringBuffer _current = StringBuffer();
  int _depth = 0;
  int? _quote;

  void accept(int unit) {
    if (_quote != null) {
      if (unit == _quote) _quote = null;
      _current.writeCharCode(unit);
      return;
    }
    if (unit == 0x2C && _depth == 0) {
      _close();
      return;
    }
    _track(unit);
    _current.writeCharCode(unit);
  }

  void _track(int unit) {
    switch (unit) {
      case 0x22 || 0x27:
        _quote = unit;
      case 0x28 || 0x5B || 0x7B:
        _depth++;
      case 0x29 || 0x5D || 0x7D:
        if (_depth > 0) _depth--;
    }
  }

  void _close() {
    final part = _current.toString().trim();
    if (part.isNotEmpty) _parts.add(part);
    _current.clear();
  }

  List<String> finish() {
    _close();
    return List.unmodifiable(_parts);
  }
}
