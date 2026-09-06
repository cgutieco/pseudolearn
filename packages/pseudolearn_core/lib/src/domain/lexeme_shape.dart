final class LexemeShape {
  const LexemeShape._();

  static bool isWord(String lexeme) {
    if (lexeme.isEmpty) return false;
    final first = lexeme[0];
    final code = first.codeUnitAt(0);
    final isAsciiLetter =
        (code >= 65 && code <= 90) || (code >= 97 && code <= 122);
    return isAsciiLetter || first == '_';
  }
}
