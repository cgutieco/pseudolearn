final RegExp _separators = RegExp(r'[^a-z0-9ñ]+');

const Map<String, String> _folded = {
  'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u', 'ü': 'u',
  'à': 'a', 'è': 'e', 'ì': 'i', 'ò': 'o', 'ù': 'u',
};

String foldKnowledgeText(String text) {
  final lowered = text.toLowerCase();
  final buffer = StringBuffer();
  for (final rune in lowered.runes) {
    final character = String.fromCharCode(rune);
    buffer.write(_folded[character] ?? character);
  }
  return buffer.toString();
}

const Set<String> _stopWords = {
  'el', 'la', 'los', 'las', 'un', 'una', 'de', 'del', 'en', 'y', 'o', 'que', 'para', 'por',
  'con', 'sin', 'se', 'es', 'su', 'sus', 'al', 'lo', 'como', 'mi', 'mis', 'me', 'qu',
  'the', 'a', 'an', 'of', 'in', 'and', 'or', 'to', 'for', 'is', 'it', 'on', 'with', 'by',
  'how', 'what', 'my', 'do', 'does', 'can', 'be', 'are', 'this', 'that',
};

List<String> knowledgeTokens(String text) => [
  for (final token in foldKnowledgeText(text).split(_separators))
    if (token.length >= 2 && !_stopWords.contains(token)) token,
];
