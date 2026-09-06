import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/knowledge/knowledge_cubit.dart';
import 'package:pseudolearn_app/application/knowledge/knowledge_state.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry_type.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import '../../fakes/fake_knowledge_repository.dart';
import '../../fakes/fake_syntax_reference_source.dart';

void main() {
  group('KnowledgeCubit (CON-F12)', () {
    late FakeKnowledgeRepository repository;
    late FakeSyntaxReferenceSource referenceSource;
    late KnowledgeCubit cubit;

    final sampleEntries = [
      const KnowledgeEntry(
        id: 'module-1',
        type: KnowledgeEntryType.module,
        title: 'Variables y tipos',
        summary: 'Aprende sobre enteros y reales.',
      ),
      const KnowledgeEntry(
        id: 'spec-1',
        type: KnowledgeEntryType.specificationSection,
        title: 'Tipos primitivos',
        summary: 'Enteros, reales, cadenas y lógicos.',
      ),
      const KnowledgeEntry(
        id: 'exercise-1',
        type: KnowledgeEntryType.exercise,
        title: 'Suma de dos enteros',
        summary: 'Ejercicio con entrada y salida.',
        profileId: SyntaxProfileId.classicSpanish,
      ),
      const KnowledgeEntry(
        id: 'exercise-2',
        type: KnowledgeEntryType.exercise,
        title: 'Calculadora basica',
        summary: 'Ejercicio para calcular operaciones con enteros.',
        profileId: SyntaxProfileId.english,
      ),
      const KnowledgeEntry(
        id: 'contact-support',
        type: KnowledgeEntryType.contact,
        title: 'Contacto y soporte',
        summary: 'Canales de atencion.',
      ),
    ];

    final sampleReferenceEntries = [
      const KnowledgeEntry(
        id: 'reference-classic-spanish',
        type: KnowledgeEntryType.reference,
        title: 'Referencia de sintaxis (Español)',
        summary: 'Palabras reservadas y tipos.',
        profileId: SyntaxProfileId.classicSpanish,
      ),
      const KnowledgeEntry(
        id: 'reference-english',
        type: KnowledgeEntryType.reference,
        title: 'Syntax Reference (English)',
        summary: 'Reserved keywords and types.',
        profileId: SyntaxProfileId.english,
      ),
    ];

    setUp(() {
      repository = FakeKnowledgeRepository(entries: sampleEntries);
      referenceSource = FakeSyntaxReferenceSource(referenceEntries: sampleReferenceEntries);
      cubit = KnowledgeCubit(repository: repository, referenceSource: referenceSource);
    });

    test('initial state is initial and empty', () {
      expect(cubit.state.status, KnowledgeStatus.initial);
      expect(cubit.state.specificationEntries, isEmpty);
      expect(cubit.state.exerciseEntries, isEmpty);
    });

    test('load partitions entries into specification and exercises, module and contact excluded', () async {
      await cubit.load(UiLanguageId.spanish);

      expect(cubit.state.status, KnowledgeStatus.success);
      expect(cubit.state.specificationEntries.length, 3);
      expect(cubit.state.specificationEntries.any((e) => e.id == 'spec-1'), isTrue);
      expect(cubit.state.specificationEntries.any((e) => e.id == 'reference-classic-spanish'), isTrue);
      expect(cubit.state.specificationEntries.any((e) => e.id == 'reference-english'), isTrue);
      expect(cubit.state.exerciseEntries.map((e) => e.id), ['exercise-1', 'exercise-2']);
      expect(cubit.state.specificationEntries.any((e) => e.type == KnowledgeEntryType.module), isFalse);
      expect(cubit.state.specificationEntries.any((e) => e.type == KnowledgeEntryType.contact), isFalse);
      expect(cubit.state.filteredSpecificationEntries, cubit.state.specificationEntries);
      expect(cubit.state.filteredExerciseEntries, cubit.state.exerciseEntries);
    });

    test('a malformed manifest transitions to the error status', () async {
      cubit = KnowledgeCubit(
        repository: FailingKnowledgeRepository(),
        referenceSource: referenceSource,
      );

      await cubit.load(UiLanguageId.spanish);

      expect(cubit.state.status, KnowledgeStatus.error);
      expect(cubit.state.errorMessage, contains('malformedManifest'));
    });

    test('search narrows both sections independently by title or summary', () async {
      await cubit.load(UiLanguageId.spanish);

      cubit.search('calculadora');
      expect(cubit.state.filteredExerciseEntries.map((e) => e.id), ['exercise-2']);
      expect(cubit.state.filteredSpecificationEntries, isEmpty);

      cubit.search('primitivos');
      expect(cubit.state.filteredSpecificationEntries.map((e) => e.id), ['spec-1']);

      cubit.search('');
      expect(cubit.state.filteredSpecificationEntries, cubit.state.specificationEntries);
      expect(cubit.state.filteredExerciseEntries, cubit.state.exerciseEntries);
    });

    test('the two empty states are distinct per section', () async {
      await cubit.load(UiLanguageId.spanish);

      expect(cubit.state.isSpecificationEmpty, isFalse);
      expect(cubit.state.isExerciseEmpty, isFalse);

      cubit.search('nonexistentterm');
      expect(cubit.state.isSpecificationSearchEmpty, isTrue);
      expect(cubit.state.isExerciseSearchEmpty, isTrue);
      expect(cubit.state.isSpecificationEmpty, isFalse);
      expect(cubit.state.isExerciseEmpty, isFalse);
    });

    test('an empty repository reports isSpecificationEmpty and isExerciseEmpty, not search-empty', () async {
      repository = FakeKnowledgeRepository(entries: const []);
      referenceSource = FakeSyntaxReferenceSource(referenceEntries: const []);
      cubit = KnowledgeCubit(repository: repository, referenceSource: referenceSource);

      await cubit.load(UiLanguageId.spanish);

      expect(cubit.state.isSpecificationEmpty, isTrue);
      expect(cubit.state.isExerciseEmpty, isTrue);
      expect(cubit.state.isSpecificationSearchEmpty, isFalse);
      expect(cubit.state.isExerciseSearchEmpty, isFalse);
    });

    test('reports error status when repository throws', () async {
      repository.shouldThrow = true;
      await cubit.load(UiLanguageId.spanish);

      expect(cubit.state.status, KnowledgeStatus.error);
      expect(cubit.state.errorMessage, isNotNull);
    });
  });
}
