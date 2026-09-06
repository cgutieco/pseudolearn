final class SyncConflict {
  final String originalDocumentId;
  final String conflictDocumentId;
  final String conflictTitle;
  final DateTime detectedAt;

  const SyncConflict({
    required this.originalDocumentId,
    required this.conflictDocumentId,
    required this.conflictTitle,
    required this.detectedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncConflict &&
          runtimeType == other.runtimeType &&
          originalDocumentId == other.originalDocumentId &&
          conflictDocumentId == other.conflictDocumentId &&
          conflictTitle == other.conflictTitle &&
          detectedAt == other.detectedAt;

  @override
  int get hashCode => Object.hash(
        originalDocumentId,
        conflictDocumentId,
        conflictTitle,
        detectedAt,
      );
}
