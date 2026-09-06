final class SourceRange {
  final int startOffset;
  final int endOffset;
  final int startLine;
  final int startColumn;
  final int endLine;
  final int endColumn;

  const SourceRange({
    required this.startOffset,
    required this.endOffset,
    required this.startLine,
    required this.startColumn,
    required this.endLine,
    required this.endColumn,
  });

  int get length => endOffset - startOffset;

  bool containsOffset(int offset) {
    return offset >= startOffset && offset <= endOffset;
  }
}
