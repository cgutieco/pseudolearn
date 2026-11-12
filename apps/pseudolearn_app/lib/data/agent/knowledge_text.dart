final RegExp _separators = RegExp('[^a-z0-9${String.fromCharCode(0xF1)}]+');

const Map<int, int> _folded = {
  0xE1: 0x61, 0xE9: 0x65, 0xED: 0x69, 0xF3: 0x6F, 0xFA: 0x75, 0xFC: 0x75,
  0xE0: 0x61, 0xE8: 0x65, 0xEC: 0x69, 0xF2: 0x6F, 0xF9: 0x75,
};

const Set<String> _stopWords = {
  'el', 'la', 'los', 'las', 'un', 'una', 'de', 'del', 'en', 'y', 'o', 'que', 'para', 'por',
  'con', 'sin', 'se', 'es', 'su', 'sus', 'al', 'lo', 'como', 'mi', 'mis', 'me',
  'the', 'a', 'an', 'of', 'in', 'and', 'or', 'to', 'for', 'is', 'it', 'on', 'with', 'by',
  'how', 'what', 'my', 'do', 'does', 'can', 'be', 'are', 'this', 'that',
};

String foldKnowledgeText(String text) {
  final lowered = text.toLowerCase();
  final buffer = StringBuffer();
  for (final rune in lowered.runes) {
    buffer.writeCharCode(_folded[rune] ?? rune);
  }
  return buffer.toString();
}

List<String> knowledgeTokens(String text) => [
  for (final token in foldKnowledgeText(text).split(_separators))
    if (token.length >= 2 && !_stopWords.contains(token)) token,
];
