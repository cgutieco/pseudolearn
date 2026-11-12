enum DocumentChangeKind { saved, deleted, reindexed }

final class DocumentChange {
  final DocumentChangeKind kind;
  final String? documentId;
  final int? revision;

  const DocumentChange.saved({required String this.documentId, required int this.revision})
    : kind = DocumentChangeKind.saved;

  const DocumentChange.deleted({required String this.documentId})
    : kind = DocumentChangeKind.deleted,
      revision = null;

  const DocumentChange.reindexed()
    : kind = DocumentChangeKind.reindexed,
      documentId = null,
      revision = null;

  bool concerns(String id) => documentId == null || documentId == id;

  @override
  bool operator ==(Object other) =>
      other is DocumentChange &&
      other.kind == kind &&
      other.documentId == documentId &&
      other.revision == revision;

  @override
  int get hashCode => Object.hash(kind, documentId, revision);
}
