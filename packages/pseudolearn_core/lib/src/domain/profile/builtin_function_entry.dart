final class BuiltinFunctionEntry {
  final String canonicalName;
  final Set<String> aliases;

  const BuiltinFunctionEntry(this.canonicalName, [this.aliases = const {}]);

  Iterable<String> get allForms sync* {
    yield canonicalName;
    yield* aliases;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BuiltinFunctionEntry &&
          runtimeType == other.runtimeType &&
          canonicalName == other.canonicalName &&
          aliases.length == other.aliases.length &&
          aliases.containsAll(other.aliases);

  @override
  int get hashCode => Object.hash(canonicalName, Object.hashAll(aliases));

  @override
  String toString() =>
      'BuiltinFunctionEntry("$canonicalName", aliases: $aliases)';
}
