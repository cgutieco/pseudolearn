import '../../../domain/ports/document_repository.dart';

final class DeleteDocument {
  final DocumentRepository _repository;

  const DeleteDocument({required this._repository});

  Future<bool> call(String documentId) async {
    try {
      await _repository.deleteDocument(documentId);
      return true;
    } catch (_) {
      return false;
    }
  }
}
