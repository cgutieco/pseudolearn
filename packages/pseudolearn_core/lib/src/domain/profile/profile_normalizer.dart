import 'accent_policy.dart';
import 'case_policy.dart';

final class ProfileNormalizer {
  final CasePolicy casePolicy;
  final AccentPolicy accentPolicy;

  const ProfileNormalizer({
    required this.casePolicy,
    required this.accentPolicy,
  });

  String normalize(String input) {
    var result = input.trim();
    result = _collapseWhitespace(result);
    if (casePolicy == CasePolicy.insensitive) {
      result = result.toLowerCase();
    }
    if (accentPolicy == AccentPolicy.insensitive) {
      result = _removeAccents(result);
    }
    return result;
  }

  static String _collapseWhitespace(String input) {
    final buffer = StringBuffer();
    var inWhitespace = false;
    for (var i = 0; i < input.length; i++) {
      final character = input[i];
      if (character == ' ' || character == '\t') {
        if (!inWhitespace) {
          buffer.write(' ');
          inWhitespace = true;
        }
      } else {
        buffer.write(character);
        inWhitespace = false;
      }
    }
    return buffer.toString();
  }

  static String _removeAccents(String input) {
    final buffer = StringBuffer();
    for (var i = 0; i < input.length; i++) {
      final character = input[i];
      buffer.write(switch (character) {
        'á' => 'a',
        'Á' => 'A',
        'é' => 'e',
        'É' => 'E',
        'í' => 'i',
        'Í' => 'I',
        'ó' => 'o',
        'Ó' => 'O',
        'ú' || 'ü' => 'u',
        'Ú' || 'Ü' => 'U',
        _ => character,
      });
    }
    return buffer.toString();
  }
}
