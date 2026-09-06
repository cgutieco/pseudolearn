import 'package:pseudolearn_app/domain/model/documents/document.dart';
import 'package:pseudolearn_app/domain/ports/document_repository.dart';

final class InMemoryDocumentRepository implements DocumentRepository {
  final Map<String, Document> documents = {};

  @override
  Future<List<DocumentSummary>> listDocuments() async {
    return documents.values.map((d) => d.toSummary()).toList();
  }

  @override
  Future<Document?> loadDocument(String id) async {
    return documents[id];
  }

  @override
  Future<Document> saveDocument(Document document) async {
    documents[document.id] = document;
    return document;
  }

  @override
  Future<void> deleteDocument(String id) async {
    documents.remove(id);
  }

  @override
  Future<void> rebuildIndex() async {}
}
