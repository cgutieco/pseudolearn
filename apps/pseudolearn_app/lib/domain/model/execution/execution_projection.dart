final class ExecutionProjection {
  final List<String> events;
  final List<String> output;
  final String termination;
  final String? failure;

  const ExecutionProjection({
    required this.events,
    required this.output,
    required this.termination,
    this.failure,
  });

  int? firstDivergence(ExecutionProjection other) {
    final shared = events.length < other.events.length
        ? events.length
        : other.events.length;
    for (var index = 0; index < shared; index++) {
      if (events[index] != other.events[index]) return index;
    }
    if (events.length != other.events.length || !_sameTail(other)) {
      return shared;
    }
    return null;
  }

  bool _sameTail(ExecutionProjection other) =>
      termination == other.termination &&
      failure == other.failure &&
      _sameLines(output, other.output);

  static bool _sameLines(List<String> left, List<String> right) {
    if (left.length != right.length) return false;
    for (var index = 0; index < left.length; index++) {
      if (left[index] != right[index]) return false;
    }
    return true;
  }

  @override
  bool operator ==(Object other) =>
      other is ExecutionProjection && firstDivergence(other) == null;

  @override
  int get hashCode => Object.hash(
    Object.hashAll(events),
    Object.hashAll(output),
    termination,
    failure,
  );
}
