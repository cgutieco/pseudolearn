import '../../domain/model/documents/document.dart';

final class ConflictProjection {
  const ConflictProjection();

  bool isConflict(DocumentSummary summary) {
    return summary.title.contains('(conflicto)');
  }

  int countConflicts(List<DocumentSummary> documents) {
    var count = 0;
    for (final doc in documents) {
      if (isConflict(doc)) {
        count++;
      }
    }
    return count;
  }
}
