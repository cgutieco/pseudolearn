import '../../../domain/model/documents/document.dart';
import '../../../domain/model/documents/document_command_result.dart';
import '../../../domain/ports/clock.dart';
import '../../../domain/ports/document_repository.dart';

final class SaveDocumentSource {
  final DocumentRepository _repository;
  final Clock _clock;

  const SaveDocumentSource({
    required DocumentRepository repository,
    required Clock clock,
  }) : _repository = repository,
       _clock = clock;

  Future<DocumentCommandResult> call({
    required Document document,
    required String sourceCode,
  }) async {
    try {
      final updated = document.copyWith(
        content: sourceCode,
        updatedAt: _clock.now(),
        revision: document.revision + 1,
      );
      return DocumentCommandSucceeded(await _repository.saveDocument(updated));
    } catch (_) {
      return const DocumentCommandRejected(DocumentCommandFailure.storageFailed);
    }
  }

  Future<DocumentCommandResult> byId({
    required String documentId,
    required String sourceCode,
  }) async {
    try {
      final document = await _repository.loadDocument(documentId);
      if (document == null) {
        return const DocumentCommandRejected(DocumentCommandFailure.notFound);
      }
      return await call(document: document, sourceCode: sourceCode);
    } catch (_) {
      return const DocumentCommandRejected(DocumentCommandFailure.storageFailed);
    }
  }
}
