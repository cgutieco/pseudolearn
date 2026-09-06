import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/knowledge/diagram_block_resolver.dart';
import 'package:pseudolearn_app/application/knowledge/knowledge_detail_cubit.dart';
import 'package:pseudolearn_app/application/knowledge/knowledge_detail_state.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_notation.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_block.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_kind.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_level.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_detail_content.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry_type.dart';
import 'package:pseudolearn_app/domain/model/knowledge/learning_module.dart';
import 'package:pseudolearn_app/domain/model/knowledge/learning_track.dart';
import 'package:pseudolearn_app/domain/model/knowledge/module_part.dart';
import 'package:pseudolearn_app/domain/model/knowledge/module_section.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/diagram/flowchart_layout.dart';
import '../../fakes/fake_clock.dart';
import '../../fakes/fake_identifier_generator.dart';
import '../../fakes/fake_knowledge_repository.dart';
import '../../fakes/fake_syntax_reference_source.dart';
import '../../fakes/in_memory_document_repository.dart';
import '../../fakes/in_memory_local_progress_store.dart';
import '../../fakes/test_dependencies.dart';

const String _diagramSource = '''
Proceso Saludo
    Escribir "Hola";
FinProceso
''';

void main() {
  group('KnowledgeDetailCubit Tests (CON-F13)', () {
    late FakeKnowledgeRepository knowledgeRepo;
    late FakeSyntaxReferenceSource referenceSource;
    late InMemoryDocumentRepository documentRepo;
    late InMemoryLocalProgressStore progressStore;
    late FakeClock clock;
    late FakeIdentifierGenerator idGen;
    late KnowledgeDetailCubit cubit;

    const contactEntry = KnowledgeEntry(
      id: 'contact-support',
      type: KnowledgeEntryType.contact,
      title: 'Contacto y soporte',
      summary: 'Canales de asistencia del proyecto.',
      path: 'support/contact_es.md',
      profileId: SyntaxProfileId.classicSpanish,
    );

    const specEntry = KnowledgeEntry(
      id: 'esp-i-tipos',
      type: KnowledgeEntryType.specificationSection,
      title: 'Tipos primitivos',
      summary: 'Los cinco tipos.',
      path: 'specification/tipos_es.md',
      anchor: 'tipos',
    );

    const moduleEntry = KnowledgeEntry(
      id: 'CON-B1',
      type: KnowledgeEntryType.module,
      title: 'Datos',
      summary: 'Tipos, variables, expresiones y asignación.',
      path: 'modules/CON-B1_es.md',
      track: LearningTrack.imperative,
    );

    const exerciseEntry = KnowledgeEntry(
      id: 'CON-B1-E1',
      type: KnowledgeEntryType.exercise,
      title: 'Sumar dos números',
      summary: 'Ejercicio de reproducción.',
      path: 'exercises/CON-B1-E1_es.json',
    );

    const exercise = Exercise(
      id: 'CON-B1-E1',
      title: 'Sumar dos números',
      statement: 'Escribe un algoritmo que sume dos números y muestre el resultado.',
      level: ExerciseLevel.reproduce,
      kind: ExerciseKind.complete,
      moduleId: 'CON-B1',
      visibleCases: [],
      hiddenCases: [],
    );

    const referenceEntry = KnowledgeEntry(
      id: 'reference-classic-spanish',
      type: KnowledgeEntryType.reference,
      title: 'Referencia de sintaxis (Español)',
      summary: 'Resumen completo de sintaxis.',
      profileId: SyntaxProfileId.classicSpanish,
    );

    const learningModule = LearningModule(
      id: 'CON-B1',
      track: LearningTrack.imperative,
      order: 1,
      title: 'Datos',
      sections: [
        ModuleSection(
          part: ModulePart.question,
          blocks: [ParagraphBlock(text: 'Por qué existen los datos.')],
        ),
        ModuleSection(
          part: ModulePart.development,
          blocks: [
            HeadingBlock(level: 2, text: 'Declaración'),
            CodeBlock(code: 'definir x como entero;'),
          ],
        ),
      ],
      anchorIds: ['esp-i-tipos'],
      exerciseIds: ['CON-B1-E1'],
    );

    setUp(() {
      knowledgeRepo = FakeKnowledgeRepository(
        entries: [contactEntry, specEntry, moduleEntry, exerciseEntry],
        exercisesByPath: {'exercises/CON-B1-E1_es.json': exercise},
        blocksByPath: {
          'support/contact_es.md': const [
            HeadingBlock(level: 1, text: 'Capítulo 1'),
            ParagraphBlock(text: 'Los algoritmos son secuencias de pasos.'),
            HeadingBlock(level: 2, text: 'Variables'),
            DiagramBlock(code: _diagramSource, notation: DiagramNotation.flowchart),
          ],
          'specification/tipos_es.md': const [
            HeadingBlock(level: 1, text: 'Tipos primitivos'),
            ParagraphBlock(text: 'Cinco tipos.'),
          ],
        },
        modulesByEntryId: {'CON-B1': learningModule},
      );

      referenceSource = FakeSyntaxReferenceSource(
        referenceEntries: [referenceEntry],
        blocksByProfile: {
          SyntaxProfileId.classicSpanish: const [
            HeadingBlock(level: 1, text: 'Referencia de sintaxis'),
            ListBlock(items: ['algoritmo', 'definir']),
          ],
        },
      );

      documentRepo = InMemoryDocumentRepository();
      progressStore = InMemoryLocalProgressStore();
      clock = FakeClock(DateTime(2026, 8, 15, 14, 0));
      idGen = FakeIdentifierGenerator(['doc-new-123']);

      final deps = buildTestDependencies(
        knowledgeRepository: knowledgeRepo,
        syntaxReferenceSource: referenceSource,
        repository: documentRepo,
        clock: clock,
        identifiers: idGen,
      );

      cubit = KnowledgeDetailCubit(
        repository: deps.knowledgeRepository,
        referenceSource: deps.syntaxReferenceSource,
        analyzer: deps.programAnalyzer,
        progressStore: progressStore,
        diagramResolver: DiagramBlockResolver(
          flowchartBuilder: deps.flowchartBuilder,
          structogramBuilder: deps.structogramBuilder,
          classDiagramBuilder: deps.classDiagramBuilder,
        ),
      );
    });

    tearDown(() {
      cubit.close();
    });

    test('Initial state is clean', () {
      final entryState = cubit.state.forEntry('non-existent');
      expect(entryState.status, equals(KnowledgeDetailStatus.initial));
      expect(entryState.entry, isNull);
      expect(entryState.content, isNull);
    });

    test('Loads a module entry, marks it visited, and resolves code highlights', () async {
      await cubit.loadEntry('CON-B1', UiLanguageId.spanish);

      final state = cubit.state.forEntry('CON-B1');
      expect(state.status, equals(KnowledgeDetailStatus.success));
      expect(state.entry, equals(moduleEntry));
      expect(state.content, isA<ModuleDetailContent>());

      final content = state.content as ModuleDetailContent;
      expect(content.module.id, equals('CON-B1'));
      expect(content.module.sections.length, equals(2));
      expect(content.headings.length, equals(1));
      expect(content.headings.first.text, equals('Declaración'));
      expect(await progressStore.isModuleVisited('CON-B1'), isTrue);

      final devSection = content.module.sections[1];
      final codeBlock = devSection.blocks.whereType<CodeBlock>().first;
      expect(codeBlock.highlightSpans.isNotEmpty, isTrue);
    });

    test('Loads a specification section entry with anchor and backlink', () async {
      await cubit.loadEntry(
        'esp-i-tipos',
        UiLanguageId.spanish,
        anchor: 'tipos',
        fromModuleId: 'CON-B1',
      );

      final state = cubit.state.forEntry('esp-i-tipos');
      expect(state.status, equals(KnowledgeDetailStatus.success));
      expect(state.entry, equals(specEntry));
      expect(state.content, isA<SpecificationDetailContent>());

      final content = state.content as SpecificationDetailContent;
      expect(content.selectedAnchor, equals('tipos'));
      expect(content.fromModuleId, equals('CON-B1'));
      expect(content.fromModuleTitle, equals('Datos'));
      expect(content.blocks.length, equals(2));
      expect(content.headings.length, equals(1));
      expect(content.headings.first.text, equals('Tipos primitivos'));
    });

    test('Loads a document with diagram blocks and resolves scenes', () async {
      await cubit.loadEntry('contact-support', UiLanguageId.spanish);

      final state = cubit.state.forEntry('contact-support');
      final document = state.content as DocumentDetailContent;
      final diagram = document.blocks.whereType<DiagramBlock>().single;
      final expectedScene = FlowchartLayout()
          .buildDiagram(
            sourceCode: _diagramSource,
            profileId: SyntaxProfileId.classicSpanish,
            languageId: UiLanguageId.spanish,
          )
          .sceneFor(null);

      expect(diagram.scene.isNotEmpty, isTrue);
      expect(diagram.scene, equals(expectedScene));
    });

    test('Loads an exercise entry', () async {
      await cubit.loadEntry('CON-B1-E1', UiLanguageId.spanish);

      final state = cubit.state.forEntry('CON-B1-E1');
      expect(state.status, equals(KnowledgeDetailStatus.success));
      expect(state.entry, equals(exerciseEntry));
      expect(state.content, isA<ExerciseDetailContent>());

      final content = state.content as ExerciseDetailContent;
      expect(content.exercise, equals(exercise));
      expect(content.isCompleted, isFalse);
    });

    test('Loads an exercise entry with isCompleted true when progress store has it', () async {
      await progressStore.markExerciseCompleted('CON-B1-E1');
      await cubit.loadEntry('CON-B1-E1', UiLanguageId.spanish);

      final state = cubit.state.forEntry('CON-B1-E1');
      final content = state.content as ExerciseDetailContent;
      expect(content.isCompleted, isTrue);
    });

    test('Exercise entry whose bundled content is missing transitions to notFound', () async {
      const orphanExerciseEntry = KnowledgeEntry(
        id: 'CON-B1-E404',
        type: KnowledgeEntryType.exercise,
        title: 'Ejercicio sin datos',
        summary: 'Entrada de catálogo sin ejercicio empaquetado.',
        path: 'exercises/CON-B1-E404_es.json',
      );
      knowledgeRepo.entries = [...knowledgeRepo.entries, orphanExerciseEntry];

      await cubit.loadEntry('CON-B1-E404', UiLanguageId.spanish);

      final state = cubit.state.forEntry('CON-B1-E404');
      expect(state.status, equals(KnowledgeDetailStatus.notFound));
      expect(state.entry, isNull);
      expect(state.content, isNull);
    });

    test('Non-existent entry transitions to notFound status', () async {
      await cubit.loadEntry('non-existent-id', UiLanguageId.spanish);

      final state = cubit.state.forEntry('non-existent-id');
      expect(state.status, equals(KnowledgeDetailStatus.notFound));
      expect(state.entry, isNull);
      expect(state.content, isNull);
    });

    test('Repository error transitions to error status', () async {
      knowledgeRepo.shouldThrow = true;
      await cubit.loadEntry('contact-support', UiLanguageId.spanish);

      final state = cubit.state.forEntry('contact-support');
      expect(state.status, equals(KnowledgeDetailStatus.error));
      expect(state.errorMessage, isNotNull);
    });

    test('Loads a specification section in English resolving english profile', () async {
      const englishSpecEntry = KnowledgeEntry(
        id: 'esp-o-clases',
        type: KnowledgeEntryType.specificationSection,
        title: 'Classes',
        summary: 'Class declarations.',
        path: 'specification/esp-o-clases_en.md',
      );
      knowledgeRepo = FakeKnowledgeRepository(
        entries: const [englishSpecEntry],
        blocksByPath: {
          'specification/esp-o-clases_en.md': const [
            HeadingBlock(level: 1, text: 'Classes'),
            ParagraphBlock(text: 'Class notation.'),
          ],
        },
      );
      final deps = buildTestDependencies(
        knowledgeRepository: knowledgeRepo,
        syntaxReferenceSource: referenceSource,
        repository: documentRepo,
        clock: clock,
        identifiers: idGen,
      );
      final englishCubit = KnowledgeDetailCubit(
        repository: deps.knowledgeRepository,
        referenceSource: deps.syntaxReferenceSource,
        analyzer: deps.programAnalyzer,
        progressStore: progressStore,
        diagramResolver: DiagramBlockResolver(
          flowchartBuilder: deps.flowchartBuilder,
          structogramBuilder: deps.structogramBuilder,
          classDiagramBuilder: deps.classDiagramBuilder,
        ),
      );

      await englishCubit.loadEntry('esp-o-clases', UiLanguageId.english);

      final state = englishCubit.state.forEntry('esp-o-clases');
      expect(state.status, equals(KnowledgeDetailStatus.success));
      expect(state.entry, equals(englishSpecEntry));
      expect(state.content, isA<SpecificationDetailContent>());
      await englishCubit.close();
    });

    test('saveScrollOffset remembers offset across module reload', () async {
      await cubit.loadEntry('CON-B1', UiLanguageId.spanish);
      cubit.saveScrollOffset('CON-B1', 320.0);

      final state = cubit.state.forEntry('CON-B1');
      expect((state.content as ModuleDetailContent).scrollOffset, equals(320.0));
      expect(cubit.getScrollOffset('CON-B1'), equals(320.0));

      await cubit.loadEntry('CON-B1', UiLanguageId.spanish);
      final reloadedState = cubit.state.forEntry('CON-B1');
      expect((reloadedState.content as ModuleDetailContent).scrollOffset, equals(320.0));
    });

    test('Preserves state isolation between multiple loaded entries', () async {
      await cubit.loadEntry('CON-B1', UiLanguageId.spanish);
      expect(cubit.state.forEntry('CON-B1').status, equals(KnowledgeDetailStatus.success));
      expect(cubit.state.forEntry('CON-B1').entry, equals(moduleEntry));

      await cubit.loadEntry('esp-i-tipos', UiLanguageId.spanish);
      expect(cubit.state.forEntry('esp-i-tipos').status, equals(KnowledgeDetailStatus.success));
      expect(cubit.state.forEntry('esp-i-tipos').entry, equals(specEntry));

      expect(cubit.state.forEntry('CON-B1').status, equals(KnowledgeDetailStatus.success));
      expect(cubit.state.forEntry('CON-B1').entry, equals(moduleEntry));
    });
  });
}
