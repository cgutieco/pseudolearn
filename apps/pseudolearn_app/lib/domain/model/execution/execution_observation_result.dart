sealed class ExecutionObservationResult<T> {
  const ExecutionObservationResult();
}

final class ExecutionObservationValue<T> extends ExecutionObservationResult<T> {
  final T value;

  const ExecutionObservationValue(this.value);
}

final class ExecutionObservationUsage<T> extends ExecutionObservationResult<T> {
  const ExecutionObservationUsage();
}

final class ExecutionObservationFailure<T>
    extends ExecutionObservationResult<T> {
  final String reason;

  const ExecutionObservationFailure(this.reason);
}
