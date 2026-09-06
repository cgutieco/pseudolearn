final class DocumentHeading {
  final int level;
  final String text;
  final int blockIndex;

  const DocumentHeading({
    required this.level,
    required this.text,
    required this.blockIndex,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentHeading &&
          runtimeType == other.runtimeType &&
          level == other.level &&
          text == other.text &&
          blockIndex == other.blockIndex;

  @override
  int get hashCode => Object.hash(level, text, blockIndex);
}
