import '../../../domain/model/documents/document_command_result.dart';
import '../../../domain/ports/clock.dart';
import '../../../domain/ports/document_repository.dart';

final class SetExecutionArguments {
  final DocumentRepository _repository;
  final Clock _clock;

  const SetExecutionArguments({
    required DocumentRepository repository,
    required Clock clock,
  }) : _repository = repository,
       _clock = clock;

  Future<DocumentCommandResult> call({
    required String documentId,
    required List<String> arguments,
  }) async {
    try {
      final document = await _repository.loadDocument(documentId);
      if (document == null) {
        return const DocumentCommandRejected(DocumentCommandFailure.notFound);
      }
      final updated = document.copyWith(
        executionArguments: List.unmodifiable(arguments),
        updatedAt: _clock.now(),
        revision: document.revision + 1,
      );
      return DocumentCommandSucceeded(await _repository.saveDocument(updated));
    } catch (_) {
      return const DocumentCommandRejected(DocumentCommandFailure.storageFailed);
    }
  }
}
