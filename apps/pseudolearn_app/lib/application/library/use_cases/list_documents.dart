import '../../../domain/model/documents/document.dart';
import '../../../domain/ports/document_repository.dart';

final class ListDocuments {
  final DocumentRepository _repository;

  const ListDocuments({required DocumentRepository repository})
    : _repository = repository;

  Future<List<DocumentSummary>?> call() async {
    try {
      return await _repository.listDocuments();
    } catch (_) {
      return null;
    }
  }
}
