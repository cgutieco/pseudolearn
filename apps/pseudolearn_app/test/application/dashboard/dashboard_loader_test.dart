import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/dashboard/dashboard_inputs.dart';
import 'package:pseudolearn_app/application/dashboard/dashboard_loader.dart';
import 'package:pseudolearn_app/domain/model/documents/document.dart';
import 'package:pseudolearn_app/domain/model/knowledge/ast_construct.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_load_result.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import '../../fakes/fake_clock.dart';
import '../../fakes/fake_knowledge_repository.dart';
import '../../fakes/fake_program_construct_reader.dart';
import '../../fakes/fake_sync_queue.dart';
import '../../fakes/in_memory_document_repository.dart';
import '../../fakes/in_memory_progress_history.dart';
import 'dashboard_fixtures.dart';

Document _documentOf(String id, String content) {
  return Document(
    id: id,
    title: id,
    content: content,
    profileId: SyntaxProfileId.classicSpanish,
    revision: 1,
    createdAt: DateTime(2026, 9, 1),
    updatedAt: DateTime(2026, 9, 1),
  );
}

void main() {
  group('DashboardLoader (PANT-06-F5)', () {
    late InMemoryDocumentRepository documents;
    late FakeKnowledgeRepository knowledge;
    late InMemoryProgressHistory history;
    late FakeSyncQueue queue;
    late FakeProgramConstructReader constructs;
    late DashboardLoader loader;

    setUp(() {
      documents = InMemoryDocumentRepository();
      knowledge = FakeKnowledgeRepository(entries: const []);
      history = InMemoryProgressHistory();
      queue = FakeSyncQueue();
      constructs = FakeProgramConstructReader();
      loader = DashboardLoader(
        documents: documents,
        knowledge: knowledge,
        progressHistory: history,
        syncQueue: queue,
        constructReader: constructs,
        clock: FakeClock(DateTime(2026, 9, 2, 12)),
      );
    });

    test('gathers documents, constructs, progress and queue in one batch', () async {
      await documents.saveDocument(_documentOf('doc-1', 'Escribir 1'));
      constructs.constructsBySource = {
        'Escribir 1': {AstConstruct.conditional},
      };
      history.entries = [visitedEntry('CON-A1', at: DateTime(2026, 9, 1))];
      await queue.enqueue(outboxEntry('doc-1', enqueuedAt: DateTime(2026, 9, 1)));

      final result = await loader.load(UiLanguageId.spanish);

      expect(result, isA<ContentLoaded<DashboardInputs>>());
      final inputs = (result as ContentLoaded<DashboardInputs>).value;
      expect(inputs.documents.single.id, 'doc-1');
      expect(inputs.constructsByDocument['doc-1'], {AstConstruct.conditional});
      expect(inputs.progress.single.contentId, 'CON-A1');
      expect(inputs.pending.length, 1);
      expect(inputs.now, DateTime(2026, 9, 2, 12));
    });

    test('a failing knowledge base is reported, never swallowed', () async {
      knowledge.shouldThrow = true;

      expect(
        () => loader.load(UiLanguageId.spanish),
        throwsA(isA<Exception>()),
      );
    });

    test('an empty device loads an empty batch without failing', () async {
      final result = await loader.load(UiLanguageId.spanish);
      final inputs = (result as ContentLoaded<DashboardInputs>).value;

      expect(inputs.documents, isEmpty);
      expect(inputs.constructsByDocument, isEmpty);
      expect(inputs.progress, isEmpty);
      expect(inputs.pending, isEmpty);
    });
  });
}
