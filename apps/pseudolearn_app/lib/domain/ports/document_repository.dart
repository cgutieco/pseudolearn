import '../model/documents/document.dart';

abstract interface class DocumentRepository {
  Future<List<DocumentSummary>> listDocuments();
  Future<Document?> loadDocument(String id);
  Future<Document> saveDocument(Document document);
  Future<void> deleteDocument(String id);
  Future<void> rebuildIndex();
}
