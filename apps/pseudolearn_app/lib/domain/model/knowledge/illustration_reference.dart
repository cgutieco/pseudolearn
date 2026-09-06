final class IllustrationReference {
  final String id;
  final String caption;

  const IllustrationReference({
    required this.id,
    required this.caption,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IllustrationReference &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          caption == other.caption;

  @override
  int get hashCode => Object.hash(id, caption);
}
