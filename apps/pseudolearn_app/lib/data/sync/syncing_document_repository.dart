import '../../domain/model/documents/document.dart';
import '../../domain/model/sync/outbox_entry.dart';
import '../../domain/ports/clock.dart';
import '../../domain/ports/document_repository.dart';
import '../../domain/ports/identifier_generator.dart';
import '../../domain/ports/sync_queue.dart';

final class SyncingDocumentRepository implements DocumentRepository {
  final DocumentRepository _inner;
  final SyncQueue _queue;
  final IdentifierGenerator _identifiers;
  final Clock _clock;

  const SyncingDocumentRepository({
    required DocumentRepository inner,
    required SyncQueue queue,
    required IdentifierGenerator identifiers,
    required Clock clock,
  })  : _inner = inner,
        _queue = queue,
        _identifiers = identifiers,
        _clock = clock;

  @override
  Future<List<DocumentSummary>> listDocuments() => _inner.listDocuments();

  @override
  Future<Document?> loadDocument(String id) => _inner.loadDocument(id);

  @override
  Future<Document> saveDocument(Document document) async {
    final saved = await _inner.saveDocument(document);
    await _queue.enqueue(OutboxEntry(
      entryId: _identifiers.generate(),
      entityType: 'document',
      entityId: saved.id,
      operation: 'upsert',
      enqueuedAt: _clock.now(),
    ));
    return saved;
  }

  @override
  Future<void> deleteDocument(String id) async {
    await _inner.deleteDocument(id);
    await _queue.enqueue(OutboxEntry(
      entryId: _identifiers.generate(),
      entityType: 'document',
      entityId: id,
      operation: 'delete',
      enqueuedAt: _clock.now(),
    ));
  }

  @override
  Future<void> rebuildIndex() => _inner.rebuildIndex();
}
