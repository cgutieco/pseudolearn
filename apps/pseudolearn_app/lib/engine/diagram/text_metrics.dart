final class TextMetrics {
  const TextMetrics();

  static const double _narrowAdvance = 0.36;
  static const double _wideAdvance = 1.0;
  static const double _regularAdvance = 0.62;
  static const String _narrowCharacters = " iljtIfr.,:;'|!()[]{}";
  static const String _wideCharacters = 'mwMW@%#';
  static const String _ellipsis = '…';

  double advanceUnits(String text) {
    var units = 0.0;
    for (final unit in text.split('')) {
      units += _advanceOf(unit);
    }
    return units;
  }

  List<String> wrapText(
    String text, {
    required double maxUnits,
    required int maxLines,
  }) {
    if (text.isEmpty) return const [''];
    final lines = <String>[];
    var remaining = text;
    while (remaining.isNotEmpty && lines.length < maxLines) {
      final taken = _lineBreakIndex(remaining, maxUnits);
      lines.add(remaining.substring(0, taken).trim());
      remaining = remaining.substring(taken).trimLeft();
    }
    if (remaining.isEmpty) return lines;
    return [...lines.sublist(0, lines.length - 1), _shortened(lines.last, maxUnits)];
  }

  double _advanceOf(String character) {
    if (_narrowCharacters.contains(character)) return _narrowAdvance;
    if (_wideCharacters.contains(character)) return _wideAdvance;
    return _regularAdvance;
  }

  int _lineBreakIndex(String text, double maxUnits) {
    var units = 0.0;
    var lastSpace = 0;
    for (var index = 0; index < text.length; index++) {
      units += _advanceOf(text[index]);
      if (text[index] == ' ') lastSpace = index;
      if (units <= maxUnits) continue;
      if (lastSpace > 0) return lastSpace;
      return index > 0 ? index : 1;
    }
    return text.length;
  }

  String _shortened(String line, double maxUnits) {
    var candidate = line;
    while (candidate.isNotEmpty && advanceUnits('$candidate$_ellipsis') > maxUnits) {
      candidate = candidate.substring(0, candidate.length - 1);
    }
    return '$candidate$_ellipsis';
  }
}
