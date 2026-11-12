final class ReferenceLinks {
  final Map<String, String> cards;
  final Map<String, String> diagnostics;

  const ReferenceLinks({required this.cards, required this.diagnostics});

  const ReferenceLinks.empty() : cards = const {}, diagnostics = const {};

  String? sectionForCard(String cardId) => cards[cardId];

  String? sectionForDiagnostic(String code) => diagnostics[code];
}
