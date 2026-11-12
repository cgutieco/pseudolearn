import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/dashboard/dashboard_inputs.dart';
import 'package:pseudolearn_app/application/dashboard/dashboard_loader.dart';
import 'package:pseudolearn_app/domain/model/documents/document.dart';
import 'package:pseudolearn_app/domain/model/knowledge/ast_construct.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_load_result.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import '../../fakes/fake_clock.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_edition.dart';
import 'package:pseudolearn_app/domain/model/route/route_toc.dart';
import '../../fakes/fake_reference_repository.dart';
import '../../fakes/fake_route_repository.dart';
import '../../fakes/route_fixtures.dart';
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
  group('DashboardLoader', () {
    late InMemoryDocumentRepository documents;
    late FakeRouteRepository route;
    late InMemoryProgressHistory history;
    late FakeSyncQueue queue;
    late FakeProgramConstructReader constructs;
    late DashboardLoader loader;

    setUp(() {
      documents = InMemoryDocumentRepository();
      route = FakeRouteRepository(toc: sampleToc);
      history = InMemoryProgressHistory();
      queue = FakeSyncQueue();
      constructs = FakeProgramConstructReader();
      loader = DashboardLoader(
        documents: documents,
        route: route,
        reference: FakeReferenceRepository(index: sampleIndex()),
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
      expect(inputs.toc.lessons.length, 2);
      expect(inputs.specificationSections.single.id, 'control.si');
      expect(route.requestedEditions.single, isA<ReferenceEdition>());
      expect(inputs.now, DateTime(2026, 9, 2, 12));
    });

    test('a missing route bundle is reported as a failed load', () async {
      final failing = DashboardLoader(
        documents: documents,
        route: FakeRouteRepository(failToc: true),
        reference: FakeReferenceRepository(),
        progressHistory: history,
        syncQueue: queue,
        constructReader: constructs,
        clock: FakeClock(DateTime(2026, 9, 2, 12)),
      );

      final result = await failing.load(UiLanguageId.spanish);

      expect(result, isA<ContentLoadFailed<DashboardInputs>>());
    });

    test('an empty device loads an empty batch without failing', () async {
      final result = await loader.load(UiLanguageId.spanish);
      final inputs = (result as ContentLoaded<DashboardInputs>).value;

      expect(inputs.documents, isEmpty);
      expect(inputs.constructsByDocument, isEmpty);
      expect(inputs.progress, isEmpty);
      expect(inputs.pending, isEmpty);
      expect(inputs.toc, isA<RouteToc>());
    });
  });
}
