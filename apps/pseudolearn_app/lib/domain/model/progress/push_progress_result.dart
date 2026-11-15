sealed class PushProgressResult {
  const PushProgressResult();
}

final class PushProgressSuccess extends PushProgressResult {
  final int serverRevision;

  const PushProgressSuccess(this.serverRevision);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PushProgressSuccess &&
          runtimeType == other.runtimeType &&
          serverRevision == other.serverRevision;

  @override
  int get hashCode => serverRevision.hashCode;
}

final class PushProgressFailure extends PushProgressResult {
  final String error;

  const PushProgressFailure(this.error);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PushProgressFailure &&
          runtimeType == other.runtimeType &&
          error == other.error;

  @override
  int get hashCode => error.hashCode;
}
