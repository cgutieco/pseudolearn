import '../../../domain/model/documents/document_command_result.dart';
import '../../../domain/model/documents/document_title_policy.dart';
import '../../../domain/ports/clock.dart';
import '../../../domain/ports/document_repository.dart';

final class RenameDocument {
  final DocumentRepository _repository;
  final Clock _clock;

  const RenameDocument({
    required DocumentRepository repository,
    required Clock clock,
  }) : _repository = repository,
       _clock = clock;

  Future<DocumentCommandResult> call({
    required String documentId,
    required String title,
  }) async {
    try {
      final document = await _repository.loadDocument(documentId);
      if (document == null) {
        return const DocumentCommandRejected(DocumentCommandFailure.notFound);
      }
      final summaries = await _repository.listDocuments();
      final titles = summaries.map((summary) => summary.title);
      if (!isDocumentTitleAvailable(title, titles, currentTitle: document.title)) {
        return const DocumentCommandRejected(
          DocumentCommandFailure.titleUnavailable,
        );
      }
      final renamed = document.copyWith(
        title: normalizeDocumentTitle(title),
        updatedAt: _clock.now(),
      );
      return DocumentCommandSucceeded(await _repository.saveDocument(renamed));
    } catch (_) {
      return const DocumentCommandRejected(DocumentCommandFailure.storageFailed);
    }
  }
}
