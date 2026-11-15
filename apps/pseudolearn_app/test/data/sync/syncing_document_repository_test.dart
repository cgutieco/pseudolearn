import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/sync/syncing_document_repository.dart';
import 'package:pseudolearn_app/domain/model/documents/document.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import '../../fakes/fake_clock.dart';
import '../../fakes/fake_identifier_generator.dart';
import '../../fakes/fake_sync_queue.dart';
import '../../fakes/in_memory_document_repository.dart';

void main() {
  group('SyncingDocumentRepository', () {
    late InMemoryDocumentRepository inner;
    late FakeSyncQueue queue;
    late FakeIdentifierGenerator identifiers;
    late FakeClock clock;
    late SyncingDocumentRepository repository;

    setUp(() {
      inner = InMemoryDocumentRepository();
      queue = FakeSyncQueue();
      identifiers = FakeIdentifierGenerator();
      clock = FakeClock(DateTime(2026, 9, 1, 10, 0));
      repository = SyncingDocumentRepository(
        inner: inner,
        queue: queue,
        identifiers: identifiers,
        clock: clock,
      );
    });

    test('saveDocument saves in inner repo and enqueues upsert in queue', () async {
      final doc = Document(
        id: 'doc-1',
        title: 'Algoritmo Test',
        content: 'Inicio\nFin',
        profileId: SyntaxProfileId.classicSpanish,
        revision: 1,
        createdAt: clock.now(),
        updatedAt: clock.now(),
      );

      final saved = await repository.saveDocument(doc);
      expect(saved.id, equals('doc-1'));

      final loaded = await inner.loadDocument('doc-1');
      expect(loaded, isNotNull);

      final pending = await queue.pendingEntries();
      expect(pending.length, equals(1));
      expect(pending.first.entityId, equals('doc-1'));
      expect(pending.first.operation, equals('upsert'));
    });

    test('deleteDocument deletes in inner repo and enqueues delete in queue', () async {
      final doc = Document(
        id: 'doc-2',
        title: 'Para Borrar',
        content: '',
        profileId: SyntaxProfileId.classicSpanish,
        revision: 1,
        createdAt: clock.now(),
        updatedAt: clock.now(),
      );
      await inner.saveDocument(doc);

      await repository.deleteDocument('doc-2');
      final loaded = await inner.loadDocument('doc-2');
      expect(loaded, isNull);

      final pending = await queue.pendingEntries();
      expect(pending.length, equals(1));
      expect(pending.first.entityId, equals('doc-2'));
      expect(pending.first.operation, equals('delete'));
    });

    test('delegates listDocuments and rebuildIndex transparently', () async {
      final list = await repository.listDocuments();
      expect(list, isEmpty);
      await repository.rebuildIndex();
    });
  });
}
