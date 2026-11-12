import '../model/documents/document.dart';
import '../model/documents/document_change.dart';

abstract interface class DocumentRepository {
  Future<List<DocumentSummary>> listDocuments();
  Future<Document?> loadDocument(String id);
  Future<Document> saveDocument(Document document);
  Future<void> deleteDocument(String id);
  Future<void> rebuildIndex();
  Stream<DocumentChange> get changes;
}
