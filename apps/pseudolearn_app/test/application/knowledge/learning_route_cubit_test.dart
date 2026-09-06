import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/knowledge/route/learning_route_cubit.dart';
import 'package:pseudolearn_app/application/knowledge/route/learning_route_state.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry_type.dart';
import 'package:pseudolearn_app/domain/model/knowledge/learning_module.dart';
import 'package:pseudolearn_app/domain/model/knowledge/learning_track.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import '../../fakes/fake_knowledge_repository.dart';
import '../../fakes/in_memory_local_progress_store.dart';

void main() {
  group('LearningRouteCubit (CON-F9)', () {
    late FakeKnowledgeRepository repository;
    late InMemoryLocalProgressStore progressStore;
    late LearningRouteCubit cubit;

    const entryA1 = KnowledgeEntry(
      id: 'con-a1',
      title: 'Qué es un algoritmo',
      summary: 'Resumen A1',
      path: 'modules/con-a1.md',
      type: KnowledgeEntryType.module,
      track: LearningTrack.foundations,
      order: 1,
    );
    const entryB1 = KnowledgeEntry(
      id: 'con-b1',
      title: 'Datos',
      summary: 'Resumen B1',
      path: 'modules/con-b1.md',
      type: KnowledgeEntryType.module,
      track: LearningTrack.imperative,
      order: 1,
    );
    const entryC1 = KnowledgeEntry(
      id: 'con-c1',
      title: 'Por qué objetos',
      summary: 'Resumen C1',
      path: 'modules/con-c1.md',
      type: KnowledgeEntryType.module,
      track: LearningTrack.objectOriented,
      order: 1,
    );

    const moduleA1 = LearningModule(
      id: 'con-a1',
      track: LearningTrack.foundations,
      order: 1,
      title: 'Qué es un algoritmo',
      sections: [],
    );

    setUp(() {
      repository = FakeKnowledgeRepository(
        entries: [entryB1, entryA1, entryC1],
        modulesByEntryId: {'con-a1': moduleA1},
      );
      progressStore = InMemoryLocalProgressStore();
      cubit = LearningRouteCubit(
        repository: repository,
        progressStore: progressStore,
      );
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state has initial status and empty tracks', () {
      expect(cubit.state.status, LearningRouteStatus.initial);
      expect(cubit.state.trackA, isEmpty);
      expect(cubit.state.trackB, isEmpty);
      expect(cubit.state.trackC, isEmpty);
      expect(cubit.state.activeModule, isNull);
    });

    test('loadRoute organizes tracks A, B, and C and reflects visited modules', () async {
      await progressStore.markModuleVisited('con-a1');

      await cubit.loadRoute(UiLanguageId.spanish);

      expect(cubit.state.status, LearningRouteStatus.success);
      expect(cubit.state.trackA.map((e) => e.id), ['con-a1']);
      expect(cubit.state.trackB.map((e) => e.id), ['con-b1']);
      expect(cubit.state.trackC.map((e) => e.id), ['con-c1']);
      expect(cubit.state.filteredTrackA, cubit.state.trackA);
      expect(cubit.state.filteredTrackB, cubit.state.trackB);
      expect(cubit.state.filteredTrackC, cubit.state.trackC);
      expect(cubit.state.isModuleVisited('con-a1'), isTrue);
      expect(cubit.state.isModuleVisited('con-b1'), isFalse);
    });

    test('search narrows each track independently and empty query restores it', () async {
      await cubit.loadRoute(UiLanguageId.spanish);

      cubit.search('datos');
      expect(cubit.state.filteredTrackB.map((e) => e.id), ['con-b1']);
      expect(cubit.state.filteredTrackA, isEmpty);
      expect(cubit.state.filteredTrackC, isEmpty);

      cubit.search('');
      expect(cubit.state.filteredTrackA, cubit.state.trackA);
      expect(cubit.state.filteredTrackB, cubit.state.trackB);
      expect(cubit.state.filteredTrackC, cubit.state.trackC);
    });

    test('reloading the route reapplies an active search', () async {
      await cubit.loadRoute(UiLanguageId.spanish);
      cubit.search('objetos');

      await cubit.loadRoute(UiLanguageId.spanish);

      expect(cubit.state.searchQuery, 'objetos');
      expect(cubit.state.filteredTrackC.map((e) => e.id), ['con-c1']);
      expect(cubit.state.filteredTrackA, isEmpty);
    });

    test('the two route empty states are distinct', () async {
      await cubit.loadRoute(UiLanguageId.spanish);
      expect(cubit.state.isRouteEmpty, isFalse);
      expect(cubit.state.isRouteSearchEmpty, isFalse);

      cubit.search('nonexistentterm');
      expect(cubit.state.isRouteSearchEmpty, isTrue);
      expect(cubit.state.isRouteEmpty, isFalse);
    });

    test('an empty repository reports isRouteEmpty, not search-empty', () async {
      final emptyRepo = FakeKnowledgeRepository(entries: const []);
      final emptyCubit = LearningRouteCubit(repository: emptyRepo, progressStore: progressStore);

      await emptyCubit.loadRoute(UiLanguageId.spanish);

      expect(emptyCubit.state.isRouteEmpty, isTrue);
      expect(emptyCubit.state.isRouteSearchEmpty, isFalse);
      await emptyCubit.close();
    });

    test('loadModule marks module as visited and sets activeModule', () async {
      expect(await progressStore.isModuleVisited('con-a1'), isFalse);

      await cubit.loadModule(
        moduleId: 'con-a1',
        languageId: UiLanguageId.spanish,
        profileId: SyntaxProfileId.classicSpanish,
      );

      expect(cubit.state.status, LearningRouteStatus.success);
      expect(cubit.state.activeModule, moduleA1);
      expect(cubit.state.isModuleVisited('con-a1'), isTrue);
      expect(await progressStore.isModuleVisited('con-a1'), isTrue);
    });

    test('loadModule with non-existent id emits moduleNotFound', () async {
      await cubit.loadModule(
        moduleId: 'con-unknown',
        languageId: UiLanguageId.spanish,
        profileId: SyntaxProfileId.classicSpanish,
      );

      expect(cubit.state.status, LearningRouteStatus.moduleNotFound);
      expect(cubit.state.activeModule, isNull);
    });

    test('loadRoute with failing repository emits error status', () async {
      final failingRepo = FailingKnowledgeRepository();
      final failingCubit = LearningRouteCubit(
        repository: failingRepo,
        progressStore: progressStore,
      );

      await failingCubit.loadRoute(UiLanguageId.spanish);

      expect(failingCubit.state.status, LearningRouteStatus.error);
      expect(failingCubit.state.errorMessage, isNotNull);
      await failingCubit.close();
    });

    test('closeModule resets activeModule to null', () async {
      await cubit.loadModule(
        moduleId: 'con-a1',
        languageId: UiLanguageId.spanish,
        profileId: SyntaxProfileId.classicSpanish,
      );
      expect(cubit.state.activeModule, isNotNull);

      cubit.closeModule();
      expect(cubit.state.activeModule, isNull);
    });
  });
}
