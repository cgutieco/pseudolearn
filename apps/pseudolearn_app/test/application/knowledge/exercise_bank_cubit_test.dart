import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/knowledge/bank/exercise_bank_cubit.dart';
import 'package:pseudolearn_app/application/knowledge/bank/exercise_bank_state.dart';
import 'package:pseudolearn_app/domain/model/knowledge/ast_construct.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_kind.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_level.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry_type.dart';
import 'package:pseudolearn_app/domain/model/knowledge/structural_assertion.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import '../../fakes/fake_knowledge_repository.dart';
import '../../fakes/in_memory_local_progress_store.dart';

void main() {
  group('ExerciseBankCubit (CON-F14)', () {
    late FakeKnowledgeRepository repository;
    late InMemoryLocalProgressStore progressStore;
    late ExerciseBankCubit cubit;

    const entry1 = KnowledgeEntry(
      id: 'con-b4-ej1',
      title: 'Tabla de multiplicar',
      summary: 'Ej 2',
      path: 'exercises/con-b4-ej1.json',
      type: KnowledgeEntryType.exercise,
    );
    const entry2 = KnowledgeEntry(
      id: 'con-b1-ej1',
      title: 'Suma de dos números',
      summary: 'Ej 1',
      path: 'exercises/con-b1-ej1.json',
      type: KnowledgeEntryType.exercise,
    );
    const entry3 = KnowledgeEntry(
      id: 'con-gen-ej1',
      title: 'Simulador bancario',
      summary: 'Ej 3 sin módulo',
      path: 'exercises/con-gen-ej1.json',
      type: KnowledgeEntryType.exercise,
    );

    const exercise1 = Exercise(
      id: 'con-b4-ej1',
      title: 'Tabla de multiplicar',
      statement: 'Usa un bucle contado para imprimir la tabla.',
      level: ExerciseLevel.compose,
      kind: ExerciseKind.create,
      moduleId: 'CON-B4',
      visibleCases: [],
      hiddenCases: [],
      assertions: [
        ContainsConstructAssertion(
          requirement: 'Usa bucle Para',
          construct: AstConstruct.countedLoop,
        ),
      ],
    );

    const exercise2 = Exercise(
      id: 'con-b1-ej1',
      title: 'Suma de dos números',
      statement: 'Calcula la suma de dos enteros.',
      level: ExerciseLevel.reproduce,
      kind: ExerciseKind.create,
      moduleId: 'CON-B1',
      visibleCases: [],
      hiddenCases: [],
    );

    const exercise3 = Exercise(
      id: 'con-gen-ej1',
      title: 'Simulador bancario',
      statement: 'Diseña un sistema completo de cuentas.',
      level: ExerciseLevel.design,
      kind: ExerciseKind.create,
      visibleCases: [],
      hiddenCases: [],
      assertions: [
        ContainsConstructAssertion(
          requirement: 'Usa clases',
          construct: AstConstruct.classDeclaration,
        ),
      ],
    );

    setUp(() {
      repository = FakeKnowledgeRepository(
        entries: [entry1, entry2, entry3],
        exercisesByPath: {
          'exercises/con-b4-ej1.json': exercise1,
          'exercises/con-b1-ej1.json': exercise2,
          'exercises/con-gen-ej1.json': exercise3,
        },
      );
      progressStore = InMemoryLocalProgressStore();
      cubit = ExerciseBankCubit(
        repository: repository,
        progressStore: progressStore,
      );
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state has initial status and empty lists', () {
      expect(cubit.state.status, ExerciseBankStatus.initial);
      expect(cubit.state.allExercises, isEmpty);
      expect(cubit.state.filteredExercises, isEmpty);
      expect(cubit.state.isEmptyBank, isFalse);
    });

    test(
        'loadExercises sorts by difficulty and extracts available filter options',
        () async {
      await progressStore.markExerciseCompleted('con-b1-ej1');

      await cubit.loadExercises(UiLanguageId.spanish);

      expect(cubit.state.status, ExerciseBankStatus.success);
      expect(cubit.state.allExercises.length, 3);

      expect(cubit.state.allExercises.map((e) => e.id).toList(), [
        'con-b1-ej1',
        'con-b4-ej1',
        'con-gen-ej1',
      ]);
      expect(cubit.state.isExerciseCompleted('con-b1-ej1'), isTrue);
      expect(cubit.state.isExerciseCompleted('con-b4-ej1'), isFalse);
      expect(cubit.state.availableModuleIds, ['CON-B1', 'CON-B4']);
      expect(cubit.state.availableConstructs, [
        AstConstruct.countedLoop,
        AstConstruct.classDeclaration,
      ]);
      expect(cubit.state.isEmptyBank, isFalse);
      expect(cubit.state.isEmptyFilterResult, isFalse);
    });

    test(
        'setFilter and search filter exercises correctly and clearFilters resets them',
        () async {
      await cubit.loadExercises(UiLanguageId.spanish);

      cubit.setFilter(level: ExerciseLevel.reproduce);
      expect(cubit.state.filteredExercises.map((e) => e.id), ['con-b1-ej1']);

      cubit.setFilter(clearLevel: true, moduleId: 'CON-B4');
      expect(cubit.state.filteredExercises.map((e) => e.id), ['con-b4-ej1']);

      cubit.setFilter(
          clearModule: true, construct: AstConstruct.classDeclaration);
      expect(cubit.state.filteredExercises.map((e) => e.id), ['con-gen-ej1']);

      cubit.search('suma');
      expect(cubit.state.filteredExercises, isEmpty);
      expect(cubit.state.isEmptyFilterResult, isTrue);

      cubit.clearFilters();
      expect(cubit.state.filteredExercises.length, 3);
      expect(cubit.state.isAnyFilterActive, isFalse);
    });

    test('isEmptyBank is true when repository has zero exercises', () async {
      final emptyRepo = FakeKnowledgeRepository(entries: []);
      final emptyCubit = ExerciseBankCubit(
        repository: emptyRepo,
        progressStore: progressStore,
      );

      await emptyCubit.loadExercises(UiLanguageId.spanish);

      expect(emptyCubit.state.status, ExerciseBankStatus.success);
      expect(emptyCubit.state.isEmptyBank, isTrue);
      expect(emptyCubit.state.isEmptyFilterResult, isFalse);

      await emptyCubit.close();
    });
  });
}
