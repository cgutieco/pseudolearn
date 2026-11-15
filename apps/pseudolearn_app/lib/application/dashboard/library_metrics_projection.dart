import '../../domain/model/dashboard/library_metrics.dart';
import '../../domain/model/documents/document.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';

LibraryMetrics projectLibraryMetrics(List<DocumentSummary> documents) {
  final byProfile = <SyntaxProfileId, int>{};
  for (final document in documents) {
    byProfile[document.profileId] = (byProfile[document.profileId] ?? 0) + 1;
  }
  return LibraryMetrics(total: documents.length, byProfile: byProfile);
}
