import '../../../domain/model/documents/document_command_result.dart';
import '../../../domain/ports/document_repository.dart';

final class LoadDocument {
  final DocumentRepository _repository;

  const LoadDocument({required this._repository});

  Future<DocumentCommandResult> call(String documentId) async {
    try {
      final document = await _repository.loadDocument(documentId);
      return document == null
          ? const DocumentCommandRejected(DocumentCommandFailure.notFound)
          : DocumentCommandSucceeded(document);
    } catch (_) {
      return const DocumentCommandRejected(DocumentCommandFailure.storageFailed);
    }
  }
}
