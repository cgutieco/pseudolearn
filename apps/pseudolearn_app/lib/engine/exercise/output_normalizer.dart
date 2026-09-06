import '../../domain/model/knowledge/expected_value_kind.dart';

final class OutputNormalizer {
  static const double relativeTolerance = 1e-9;

  const OutputNormalizer();

  List<String> normalize(List<String> lines) {
    final normalized = <String>[];
    for (final line in lines) {
      normalized.add(_collapseSpaces(line));
    }
    while (normalized.isNotEmpty && normalized.last.isEmpty) {
      normalized.removeLast();
    }
    return normalized;
  }

  bool matches({
    required List<String> expected,
    required List<String> actual,
    required ExpectedValueKind kind,
  }) {
    final normalizedExpected = normalize(expected);
    final normalizedActual = normalize(actual);
    if (normalizedExpected.length != normalizedActual.length) return false;
    for (var i = 0; i < normalizedExpected.length; i++) {
      if (!_lineMatches(normalizedExpected[i], normalizedActual[i], kind)) {
        return false;
      }
    }
    return true;
  }

  bool _lineMatches(String expected, String actual, ExpectedValueKind kind) {
    if (expected == actual) return true;
    if (kind == ExpectedValueKind.text) return false;
    return _numbersMatch(expected, actual);
  }

  bool _numbersMatch(String expected, String actual) {
    final expectedInteger = int.tryParse(expected);
    final actualInteger = int.tryParse(actual);
    if (expectedInteger != null && actualInteger != null) {
      return expectedInteger == actualInteger;
    }
    final expectedReal = double.tryParse(expected);
    final actualReal = double.tryParse(actual);
    if (expectedReal == null || actualReal == null) return false;
    return _withinTolerance(expectedReal, actualReal);
  }

  bool _withinTolerance(double expected, double actual) {
    final difference = (expected - actual).abs();
    if (difference == 0) return true;
    final magnitude = expected.abs() > actual.abs() ? expected.abs() : actual.abs();
    return difference <= relativeTolerance * magnitude;
  }

  String _collapseSpaces(String line) {
    final buffer = StringBuffer();
    var pendingSpace = false;
    var hasContent = false;
    for (final unit in line.codeUnits) {
      if (_isSpace(unit)) {
        pendingSpace = hasContent;
        continue;
      }
      if (pendingSpace) buffer.write(' ');
      buffer.writeCharCode(unit);
      pendingSpace = false;
      hasContent = true;
    }
    return buffer.toString();
  }

  bool _isSpace(int unit) => unit == 0x20 || unit == 0x09;
}
