final class CoverageCount {
  final int done;
  final int total;

  const CoverageCount({required this.done, required this.total});

  const CoverageCount.empty()
      : done = 0,
        total = 0;

  double get ratio => total == 0 ? 0 : done / total;

  bool get isComplete => total > 0 && done >= total;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoverageCount &&
          runtimeType == other.runtimeType &&
          done == other.done &&
          total == other.total;

  @override
  int get hashCode => Object.hash(done, total);
}
