final class SubprogramSignature {
  final String name;
  final int arity;

  const SubprogramSignature({
    required this.name,
    required this.arity,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubprogramSignature &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          arity == other.arity;

  @override
  int get hashCode => Object.hash(name, arity);
}
