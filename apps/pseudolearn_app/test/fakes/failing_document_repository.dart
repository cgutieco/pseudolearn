import 'package:pseudolearn_app/domain/model/documents/document.dart';
import 'package:pseudolearn_app/domain/model/documents/document_change.dart';
import 'package:pseudolearn_app/domain/ports/document_repository.dart';

final class FailingDocumentRepository implements DocumentRepository {
  @override
  Stream<DocumentChange> get changes => const Stream.empty();

  @override
  Future<void> deleteDocument(String id) => Future.error(StateError('disk'));

  @override
  Future<List<DocumentSummary>> listDocuments() =>
      Future.error(StateError('disk'));

  @override
  Future<Document?> loadDocument(String id) => Future.error(StateError('disk'));

  @override
  Future<void> rebuildIndex() => Future.error(StateError('disk'));

  @override
  Future<Document> saveDocument(Document document) =>
      Future.error(StateError('disk'));
}
