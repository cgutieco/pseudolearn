import 'dart:async';
import 'package:pseudolearn_app/domain/model/documents/document.dart';
import 'package:pseudolearn_app/domain/model/documents/document_change.dart';
import 'package:pseudolearn_app/domain/ports/document_repository.dart';

final class InMemoryDocumentRepository implements DocumentRepository {
  final Map<String, Document> documents = {};
  final bool emitsChanges;
  final StreamController<DocumentChange> _changes =
      StreamController<DocumentChange>.broadcast(sync: true);

  InMemoryDocumentRepository({this.emitsChanges = false});

  @override
  Stream<DocumentChange> get changes => _changes.stream;

  void announce(DocumentChange change) => _changes.add(change);

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
    if (emitsChanges) {
      announce(
        DocumentChange.saved(documentId: document.id, revision: document.revision),
      );
    }
    return document;
  }

  @override
  Future<void> deleteDocument(String id) async {
    documents.remove(id);
    if (emitsChanges) announce(DocumentChange.deleted(documentId: id));
  }

  @override
  Future<void> rebuildIndex() async {}
}
