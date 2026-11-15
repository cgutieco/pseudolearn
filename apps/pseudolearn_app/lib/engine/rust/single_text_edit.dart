final class SingleTextEdit {
  final int start;
  final int end;
  final String replacement;

  const SingleTextEdit({
    required this.start,
    required this.end,
    required this.replacement,
  });

  static SingleTextEdit? between(String before, String after) {
    if (before == after) return null;
    final limit = before.length < after.length ? before.length : after.length;
    var prefix = 0;
    while (prefix < limit &&
        before.codeUnitAt(prefix) == after.codeUnitAt(prefix)) {
      prefix++;
    }
    prefix = _outsidePair(before, prefix, -1);
    var suffix = 0;
    while (suffix < limit - prefix &&
        before.codeUnitAt(before.length - 1 - suffix) ==
            after.codeUnitAt(after.length - 1 - suffix)) {
      suffix++;
    }
    suffix = _suffixOutsidePair(before, suffix);
    return SingleTextEdit(
      start: prefix,
      end: before.length - suffix,
      replacement: after.substring(prefix, after.length - suffix),
    );
  }

  static int _outsidePair(String text, int boundary, int direction) {
    if (boundary <= 0 || boundary >= text.length) return boundary;
    final previous = text.codeUnitAt(boundary - 1);
    final current = text.codeUnitAt(boundary);
    final splits =
        previous >= 0xD800 &&
        previous <= 0xDBFF &&
        current >= 0xDC00 &&
        current <= 0xDFFF;
    return splits ? boundary + direction : boundary;
  }

  static int _suffixOutsidePair(String text, int suffix) {
    final boundary = text.length - suffix;
    return text.length - _outsidePair(text, boundary, 1);
  }
}
