final class ReferenceSearchEntry {
  final String text;
  final String kind;
  final String sectionId;
  final String anchor;

  const ReferenceSearchEntry({
    required this.text,
    required this.kind,
    required this.sectionId,
    this.anchor = '',
  });

  bool matches(String folded) => foldSearchText(text).contains(folded);
}

const Map<int, int> _accentFolding = {
  0xE1: 0x61,
  0xE9: 0x65,
  0xED: 0x69,
  0xF3: 0x6F,
  0xFA: 0x75,
  0xFC: 0x75,
};

String foldSearchText(String text) {
  final folded = text.toLowerCase().runes.map(
    (rune) => _accentFolding[rune] ?? rune,
  );
  return String.fromCharCodes(folded);
}
