final class OutboxEntry {
  final String entryId;
  final String entityType;
  final String entityId;
  final String operation;
  final DateTime enqueuedAt;
  final int attempts;
  final String? lastError;

  const OutboxEntry({
    required this.entryId,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.enqueuedAt,
    this.attempts = 0,
    this.lastError,
  });

  OutboxEntry copyWith({
    int? attempts,
    String? lastError,
  }) {
    return OutboxEntry(
      entryId: entryId,
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      enqueuedAt: enqueuedAt,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OutboxEntry &&
          runtimeType == other.runtimeType &&
          entryId == other.entryId &&
          entityType == other.entityType &&
          entityId == other.entityId &&
          operation == other.operation &&
          enqueuedAt == other.enqueuedAt &&
          attempts == other.attempts &&
          lastError == other.lastError;

  @override
  int get hashCode => Object.hash(
        entryId,
        entityType,
        entityId,
        operation,
        enqueuedAt,
        attempts,
        lastError,
      );
}
