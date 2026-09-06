final class Position implements Comparable<Position> {
  final int line;
  final int column;
  final int offset;

  const Position({
    required this.line,
    required this.column,
    required this.offset,
  })  : assert(line >= 1, 'line must be 1-indexed (>= 1)'),
        assert(column >= 1, 'column must be 1-indexed (>= 1)'),
        assert(offset >= 0, 'offset must be 0-indexed (>= 0)');

  @override
  int compareTo(Position other) => offset.compareTo(other.offset);

  bool operator <(Position other) => offset < other.offset;
  bool operator <=(Position other) => offset <= other.offset;
  bool operator >(Position other) => offset > other.offset;
  bool operator >=(Position other) => offset >= other.offset;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position &&
          runtimeType == other.runtimeType &&
          line == other.line &&
          column == other.column &&
          offset == other.offset;

  @override
  int get hashCode => Object.hash(line, column, offset);

  @override
  String toString() => '$line:$column ($offset)';
}
