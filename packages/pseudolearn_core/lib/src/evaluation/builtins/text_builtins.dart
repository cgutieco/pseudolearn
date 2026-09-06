final class TextBuiltins {
  static const int _maxCodePoint = 0x10FFFF;
  static const int _surrogateRangeStart = 0xD800;
  static const int _surrogateRangeEnd = 0xDFFF;

  const TextBuiltins();

  int length(String text) => text.runes.length;

  String? characterAt(String text, int index) {
    final codePoints = text.runes.toList();
    if (index < 0 || index >= codePoints.length) return null;
    return String.fromCharCode(codePoints[index]);
  }

  int characterCode(String character) => character.runes.first;

  String? characterFromCode(int code) {
    if (code < 0 || code > _maxCodePoint) return null;
    if (code >= _surrogateRangeStart && code <= _surrogateRangeEnd) return null;
    return String.fromCharCode(code);
  }
}
