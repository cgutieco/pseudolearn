sealed class RunResult {
  const RunResult();
}

final class RunSample extends RunResult {
  final int steps;
  final int elapsedMicroseconds;
  final int events;

  const RunSample({
    required this.steps,
    required this.elapsedMicroseconds,
    required this.events,
  });
}

final class RunFailure extends RunResult {
  final String reason;

  const RunFailure(this.reason);
}
