enum IdentifierAlphabet {
  standard,
  extended;

  bool isValidStartCharacter(String character) {
    if (character.isEmpty) return false;
    if (character == '_') return true;
    return isValidLetter(character);
  }

  bool isValidContinuationCharacter(String character) {
    if (character.isEmpty) return false;
    if (character == '_') return true;
    final codeUnit = character.codeUnitAt(0);
    if (codeUnit >= 48 && codeUnit <= 57) return true;
    return isValidLetter(character);
  }

  bool isValidLetter(String character) {
    if (character.isEmpty) return false;
    final codeUnit = character.codeUnitAt(0);
    final isAsciiLetter = (codeUnit >= 65 && codeUnit <= 90) ||
        (codeUnit >= 97 && codeUnit <= 122);
    if (isAsciiLetter) return true;

    if (this == IdentifierAlphabet.extended) {
      return switch (character) {
        'ñ' || 'Ñ' => true,
        'á' || 'é' || 'í' || 'ó' || 'ú' => true,
        'Á' || 'É' || 'Í' || 'Ó' || 'Ú' => true,
        'ü' || 'Ü' => true,
        _ => false,
      };
    }
    return false;
  }
}
