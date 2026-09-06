import '../../domain/model/documents/document.dart';
import '../../domain/model/knowledge/ast_construct.dart';
import '../../domain/model/knowledge/knowledge_entry.dart';
import '../../domain/model/progress/progress_entry.dart';
import '../../domain/model/sync/outbox_entry.dart';

final class DashboardInputs {
  final List<DocumentSummary> documents;
  final Map<String, Set<AstConstruct>> constructsByDocument;
  final List<KnowledgeEntry> entries;
  final List<ProgressEntry> progress;
  final List<OutboxEntry> pending;
  final DateTime now;

  const DashboardInputs({
    required this.documents,
    required this.constructsByDocument,
    required this.entries,
    required this.progress,
    required this.pending,
    required this.now,
  });
}
