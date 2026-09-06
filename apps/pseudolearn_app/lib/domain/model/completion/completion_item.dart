enum CompletionFamily {
  structured,
  procedural,
  oop,
}

final class CompletionItem {
  final String label;
  final String template;
  final int caretOffset;
  final CompletionFamily family;

  const CompletionItem({
    required this.label,
    required this.template,
    required this.caretOffset,
    required this.family,
  });
}
