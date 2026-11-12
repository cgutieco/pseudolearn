import '../../domain/model/documents/document.dart';
import '../../domain/model/knowledge/ast_construct.dart';
import '../../domain/model/knowledge/content_progress.dart';
import '../../domain/model/progress/progress_entry.dart';
import '../../domain/model/reference/reference_index.dart';
import '../../domain/model/route/route_toc.dart';
import '../../domain/model/sync/outbox_entry.dart';

final class DashboardInputs {
  final List<DocumentSummary> documents;
  final Map<String, Set<AstConstruct>> constructsByDocument;
  final RouteToc toc;
  final List<ReferenceIndexEntry> specificationSections;
  final List<ProgressEntry> progress;
  final List<OutboxEntry> pending;
  final DateTime now;

  const DashboardInputs({
    required this.documents,
    required this.constructsByDocument,
    required this.toc,
    required this.specificationSections,
    required this.progress,
    required this.pending,
    required this.now,
  });

  ContentProgress get contentProgress => ContentProgress(
    visitedModuleIds: {
      for (final entry in progress)
        if (entry.visited) entry.contentId,
    },
    completedExerciseIds: {
      for (final entry in progress)
        if (entry.completed) entry.contentId,
    },
  );
}
