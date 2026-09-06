import '../../domain/model/progress/progress_entry.dart';
import '../index/index_schema.dart';

ProgressEntry progressEntryOfRow(Map<String, Object?> row) {
  final firstVisited = row[IndexSchema.columnFirstVisitedAt] as String?;
  final firstCompleted = row[IndexSchema.columnFirstCompletedAt] as String?;
  return ProgressEntry(
    contentId: row[IndexSchema.columnContentId] as String,
    visited: (row[IndexSchema.columnVisited] as int? ?? 0) == 1,
    completed: (row[IndexSchema.columnCompleted] as int? ?? 0) == 1,
    firstVisitedAt: firstVisited == null ? null : DateTime.tryParse(firstVisited),
    firstCompletedAt:
        firstCompleted == null ? null : DateTime.tryParse(firstCompleted),
  );
}
