sealed class PushBatchResult {
  const PushBatchResult();
}

final class PushBatchSuccess extends PushBatchResult {
  final int serverRevision;

  const PushBatchSuccess(this.serverRevision);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PushBatchSuccess &&
          runtimeType == other.runtimeType &&
          serverRevision == other.serverRevision;

  @override
  int get hashCode => serverRevision.hashCode;
}

final class PushBatchFailure extends PushBatchResult {
  final String error;

  const PushBatchFailure(this.error);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PushBatchFailure &&
          runtimeType == other.runtimeType &&
          error == other.error;

  @override
  int get hashCode => error.hashCode;
}
