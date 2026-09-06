final class LexemeEntry {
  final String canonicalLexeme;
  final Set<String> aliases;

  const LexemeEntry(this.canonicalLexeme, [this.aliases = const {}]);

  Iterable<String> get allForms sync* {
    yield canonicalLexeme;
    yield* aliases;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LexemeEntry &&
          runtimeType == other.runtimeType &&
          canonicalLexeme == other.canonicalLexeme &&
          aliases.length == other.aliases.length &&
          aliases.containsAll(other.aliases);

  @override
  int get hashCode => Object.hash(canonicalLexeme, Object.hashAll(aliases));

  @override
  String toString() => 'LexemeEntry("$canonicalLexeme", aliases: $aliases)';
}
