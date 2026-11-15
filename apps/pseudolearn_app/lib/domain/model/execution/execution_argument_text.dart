abstract final class ExecutionArgumentText {
  static List<String>? parse(String text) => _ArgumentScanner().scan(text);

  static String format(List<String> values) => values
      .map(
        (value) => '"${value.replaceAll(r'\', r'\\').replaceAll('"', r'\"')}"',
      )
      .join(' ');
}

final class _ArgumentScanner {
  final values = <String>[];
  var buffer = StringBuffer();
  String? quote;
  var active = false;

  List<String>? scan(String text) {
    for (var index = 0; index < text.length; index++) {
      final character = text[index];
      if (character == r'\' &&
          index + 1 < text.length &&
          _escapable(text[index + 1])) {
        buffer.write(text[++index]);
        active = true;
      } else {
        _accept(character);
      }
    }
    if (quote != null) return null;
    _flush();
    return List.unmodifiable(values);
  }

  bool _escapable(String character) =>
      character == r'\' ||
      character == '"' ||
      character == "'" ||
      (quote == null && character.trim().isEmpty);

  void _accept(String character) {
    if (quote != null) {
      if (character == quote) {
        quote = null;
      } else {
        buffer.write(character);
      }
    } else if (character == '"' || character == "'") {
      quote = character;
      active = true;
    } else if (character.trim().isEmpty) {
      _flush();
    } else {
      buffer.write(character);
      active = true;
    }
  }

  void _flush() {
    if (!active) return;
    values.add(buffer.toString());
    buffer = StringBuffer();
    active = false;
  }
}
