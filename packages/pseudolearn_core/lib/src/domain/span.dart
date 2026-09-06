import 'position.dart';

final class Span implements Comparable<Span> {
  final Position start;
  final Position end;

  static final Span zero = Span(
    start: const Position(line: 1, column: 1, offset: 0),
    end: const Position(line: 1, column: 1, offset: 0),
  );

  Span({
    required this.start,
    required this.end,
  }) : assert(start.offset <= end.offset, 'start must not be after end');

  int get length => end.offset - start.offset;

  bool get isEmpty => start.offset == end.offset;

  bool get crossesLines => start.line != end.line;

  Span union(Span other) {
    final minimumStart = start < other.start ? start : other.start;
    final maximumEnd = end > other.end ? end : other.end;
    return Span(start: minimumStart, end: maximumEnd);
  }

  bool contains(Position position) =>
      start.offset <= position.offset && position.offset <= end.offset;

  bool containsSpan(Span other) =>
      start.offset <= other.start.offset && other.end.offset <= end.offset;

  @override
  int compareTo(Span other) {
    final startComparison = start.compareTo(other.start);
    if (startComparison != 0) {
      return startComparison;
    }
    return end.compareTo(other.end);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Span &&
          runtimeType == other.runtimeType &&
          start == other.start &&
          end == other.end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => '$start..$end';
}
