import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/diagram/diagram_cubit.dart';
import 'package:pseudolearn_app/application/editor/editor_cubit.dart';
import 'package:pseudolearn_app/application/execution/execution_cubit.dart';
import 'package:pseudolearn_app/application/execution/step_pace.dart';
import 'package:pseudolearn_app/application/execution/execution_state.dart';
import 'package:pseudolearn_app/application/execution/step_batch_runner.dart';
import 'package:pseudolearn_app/application/export/export_cubit.dart';
import 'package:pseudolearn_app/application/export/export_state.dart';
import 'package:pseudolearn_app/application/library/library_cubit.dart';
import 'package:pseudolearn_app/application/library/library_state.dart';
import 'package:pseudolearn_app/application/onboarding/onboarding_cubit.dart';
import 'package:pseudolearn_app/application/settings/settings_cubit.dart';
import 'package:pseudolearn_app/application/trace/trace_cubit.dart';
import 'package:pseudolearn_app/data/documents/file_document_repository.dart';
import 'package:pseudolearn_app/data/index/index_rebuild.dart';
import 'package:pseudolearn_app/data/index/index_schema.dart';
import 'package:pseudolearn_app/data/index/metadata_index.dart';
import 'package:pseudolearn_app/domain/model/documents/document.dart';
import 'package:pseudolearn_app/domain/model/export/target_language_id.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/app_theme_mode.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/analysis/core_program_analyzer.dart';
import 'package:pseudolearn_app/engine/completion/profile_completion_source.dart';
import 'package:pseudolearn_app/engine/editing/lexicon_source_editor.dart';
import 'package:pseudolearn_app/engine/editing/profile_key_source.dart';
import 'package:pseudolearn_app/engine/classdiagram/core_class_diagram_builder.dart';
import 'package:pseudolearn_app/engine/diagram/flowchart_layout.dart';
import 'package:pseudolearn_app/engine/structogram/structogram_layout.dart';
import 'package:pseudolearn_app/engine/execution/core_program_execution.dart';
import 'package:pseudolearn_app/engine/export/core_program_exporter.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../fakes/fake_clock.dart';
import '../fakes/fake_text_entry_modality.dart';
import '../fakes/fake_identifier_generator.dart';
import '../fakes/fake_knowledge_repository.dart';
import '../fakes/in_memory_document_repository.dart';
import '../fakes/in_memory_preferences_store.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  group('CIE-F1 · Transversal Integration and Edge Cases', () {
    late InMemoryPreferencesStore preferences;
    late InMemoryDocumentRepository docRepo;
    late FakeIdentifierGenerator idGen;
    late FakeClock clock;
    late FakeKnowledgeRepository knowledgeRepo;
    late CoreProgramAnalyzer analyzer;
    late CoreProgramExecution execution;
    late FlowchartLayout flowchartLayout;
    late ProfileCompletionSource completionSource;

    const sampleDemoCode = '''
Proceso DemostracionGuiada
  Definir mensaje Como Cadena
  mensaje <- "Bienvenido"
  Escribir mensaje
FinProceso
''';

    setUp(() {
      preferences = InMemoryPreferencesStore();
      docRepo = InMemoryDocumentRepository();
      idGen = FakeIdentifierGenerator(['doc-101', 'doc-102', 'doc-103']);
      clock = FakeClock(DateTime(2026, 8, 15, 12, 0));
      knowledgeRepo = FakeKnowledgeRepository(
        rawContentByPath: {
          'examples/guided_demo_es.pseudo': sampleDemoCode,
          'examples/guided_demo_en.pseudo': sampleDemoCode,
          'examples/condicional_es.pseudo': '''
Algoritmo EjemploCondicional
  Definir n Como Entero
  n <- 42
  Si n > 0 Entonces
    Escribir "Positivo"
  FinSi
FinAlgoritmo
''',
        },
      );
      analyzer = CoreProgramAnalyzer();
      execution = CoreProgramExecution();
      flowchartLayout = FlowchartLayout();
      completionSource = const ProfileCompletionSource();
    });

    test('1. Full journey: Onboarding -> Library -> Create -> Edit -> Run & Input -> Diagram -> Trace -> Reopen', () async {
      final onboardingCubit = OnboardingCubit(
        preferences: preferences,
        knowledgeRepository: knowledgeRepo,
      );

      expect(onboardingCubit.state.isCompleted, isFalse);
      await onboardingCubit.nextStep();
      await onboardingCubit.nextStep();
      await onboardingCubit.nextStep();
      await onboardingCubit.nextStep();
      expect(onboardingCubit.state.isCompleted, isTrue);
      final savedPrefs = await preferences.read();
      expect(savedPrefs.hasSeenOnboarding, isTrue);
      await onboardingCubit.close();

      final libraryCubit = LibraryCubit(
        repository: docRepo,
        idGenerator: idGen,
        clock: clock,
      );
      await libraryCubit.loadDocuments();
      expect(libraryCubit.state.isEmptyLibrary, isTrue);

      final createdDoc = await libraryCubit.createDocument(
        title: 'Programa Interactivo',
        profileId: SyntaxProfileId.classicSpanish,
      );
      expect(createdDoc, isNotNull);
      expect(createdDoc!.id, 'doc-101');
      expect(libraryCubit.state.allDocuments.length, 1);

      final editorCubit = EditorCubit(
        repository: docRepo,
        analyzer: analyzer,
        completionSource: completionSource,
        keySource: const ProfileKeySource(),
        sourceEditor: const LexiconSourceEditor(),
        textEntry: const FakeTextEntryModality(),
        clock: clock,
      );
      await editorCubit.loadDocument(createdDoc.id);

      const interactiveProgram = '''
Proceso Interactivo
  Definir entrada Como Entero
  Leer entrada
  Escribir entrada
FinProceso
''';
      editorCubit.updateSourceCode(interactiveProgram);
      expect(editorCubit.state.isDirty, isTrue);
      expect(editorCubit.state.report.isExecutable, isTrue);
      await editorCubit.saveDocument();
      expect(editorCubit.state.isDirty, isFalse);

      final executionCubit = ExecutionCubit(
        execution: execution,
        runner: const StepBatchRunner(maxSteps: 1000, batchSize: 10),
      );

      for (var i = 0; i < 10 && executionCubit.state.status != ExecutionStatus.pausedAwaitingInput; i++) {
        await executionCubit.advance(
          pace: StepPace.nextStatement,
          sourceCode: interactiveProgram,
          profileId: SyntaxProfileId.classicSpanish,
          languageId: UiLanguageId.spanish,
        );
      }

      expect(executionCubit.state.status, ExecutionStatus.pausedAwaitingInput);
      await executionCubit.provideInput('42');

      for (var i = 0; i < 10 && executionCubit.state.status != ExecutionStatus.finishedSuccess; i++) {
        await executionCubit.advance(
          pace: StepPace.nextStatement,
          sourceCode: interactiveProgram,
          profileId: SyntaxProfileId.classicSpanish,
          languageId: UiLanguageId.spanish,
        );
      }
      expect(executionCubit.state.status, ExecutionStatus.finishedSuccess);
      expect(executionCubit.state.outputLines.any((l) => l.text.contains('42')), isTrue);

      final diagramCubit = DiagramCubit(
        flowchartBuilder: flowchartLayout,
        structogramBuilder: StructogramLayout(),
        classDiagramBuilder: CoreClassDiagramBuilder(),
      );
      diagramCubit.updateDiagram(
        sourceCode: interactiveProgram,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );
      expect(diagramCubit.state.hasValidAst, isTrue);
      expect(diagramCubit.state.scene.nodes, isNotEmpty);

      final traceCubit = TraceCubit(executionStates: executionCubit.stream);
      for (var i = 0; i < 2; i++) {
        await executionCubit.advance(
          pace: StepPace.nextStatement,
          sourceCode: interactiveProgram,
          profileId: SyntaxProfileId.classicSpanish,
          languageId: UiLanguageId.spanish,
        );
      }
      await Future<void>.delayed(Duration.zero);
      expect(traceCubit.state.hasExecution, isTrue,
          reason: 'a row appears once a statement has settled, not when the first one is entered');

      final exportCubit = ExportCubit(
        exporter: CoreProgramExporter(),
        executionStates: executionCubit.stream,
      );
      exportCubit.updateSource(
        sourceCode: interactiveProgram,
        profileId: SyntaxProfileId.classicSpanish,
      );
      expect(exportCubit.state.status, ExportStatus.ready);
      expect(exportCubit.state.exportedCode, contains('input()'));

      exportCubit.selectLanguage(
        TargetLanguageId.rust,
        sourceCode: interactiveProgram,
        profileId: SyntaxProfileId.classicSpanish,
      );
      expect(exportCubit.state.exportedCode, contains('fn main()'));

      await libraryCubit.loadDocuments();
      expect(libraryCubit.state.allDocuments.length, 1);
      final reloaded = await docRepo.loadDocument('doc-101');
      expect(reloaded?.content, interactiveProgram);

      await editorCubit.close();
      await executionCubit.close();
      await diagramCubit.close();
      await traceCubit.close();
      await exportCubit.close();
      await libraryCubit.close();
    });

    test('2. Open knowledge example as a new document, edit and save it', () async {
      final libraryCubit = LibraryCubit(
        repository: docRepo,
        idGenerator: idGen,
        clock: clock,
      );
      final rawExample = await knowledgeRepo.getRawContent('examples/condicional_es.pseudo');
      expect(rawExample, isNotEmpty);

      final createdDoc = await libraryCubit.createDocument(
        title: 'Ejemplo Condicional Copiado',
        profileId: SyntaxProfileId.classicSpanish,
      );
      expect(createdDoc, isNotNull);

      final editorCubit = EditorCubit(
        repository: docRepo,
        analyzer: analyzer,
        completionSource: completionSource,
        keySource: const ProfileKeySource(),
        sourceEditor: const LexiconSourceEditor(),
        textEntry: const FakeTextEntryModality(),
        clock: clock,
      );
      await editorCubit.loadDocument(createdDoc!.id);

      final modifiedCode = rawExample.replaceAll('"Positivo"', '"Resultado Positivo"');
      editorCubit.updateSourceCode(modifiedCode);
      await editorCubit.saveDocument();

      final persistedDoc = await docRepo.loadDocument(createdDoc.id);
      expect(persistedDoc?.content, contains('"Resultado Positivo"'));

      await editorCubit.close();
      await libraryCubit.close();
    });

    test('3. Change UI language with open document: diagnostics change text and NOT code', () async {
      final settingsCubit = SettingsCubit(
        preferences: preferences,
      );
      await settingsCubit.init();

      const invalidCode = '''
Algoritmo ErrorSintaxis
  Definir x Como
FinAlgoritmo
''';
      final reportEs = analyzer.analyze(
        sourceCode: invalidCode,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );
      expect(reportEs.isExecutable, isFalse);
      expect(reportEs.diagnostics, isNotEmpty);
      final diagEs = reportEs.diagnostics.first;

      await settingsCubit.setLanguage(UiLanguageId.english);
      expect(settingsCubit.state.language, UiLanguageId.english);

      final reportEn = analyzer.analyze(
        sourceCode: invalidCode,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.english,
      );
      expect(reportEn.diagnostics, isNotEmpty);
      final diagEn = reportEn.diagnostics.first;

      expect(diagEn.code, equals(diagEs.code));
      expect(diagEn.primaryRange.startOffset, equals(diagEs.primaryRange.startOffset));
      expect(diagEn.primaryRange.endOffset, equals(diagEs.primaryRange.endOffset));
      expect(diagEn.severity, equals(diagEs.severity));

      await settingsCubit.close();
    });

    test('4. Change theme with ongoing execution: execution state is preserved', () async {
      final settingsCubit = SettingsCubit(
        preferences: preferences,
      );
      await settingsCubit.init();

      final executionCubit = ExecutionCubit(execution: execution);
      const loopProgram = '''
Algoritmo Bucle
  Definir i Como Entero
  i <- 1
  i <- i + 1
  i <- i + 1
FinAlgoritmo
''';
      await executionCubit.advance(
          pace: StepPace.nextStatement,
        sourceCode: loopProgram,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );
      await executionCubit.advance(
          pace: StepPace.nextStatement,
        sourceCode: loopProgram,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );

      final activeStepBefore = executionCubit.state.currentStep.stepNumber;
      expect(activeStepBefore, greaterThan(0));
      expect(executionCubit.state.status, ExecutionStatus.pausedAtStatement);

      await settingsCubit.setThemeMode(AppThemeMode.dark);
      expect(settingsCubit.state.themeMode, AppThemeMode.dark);

      expect(executionCubit.state.currentStep.stepNumber, equals(activeStepBefore));
      expect(executionCubit.state.status, equals(ExecutionStatus.pausedAtStatement));

      await settingsCubit.close();
      await executionCubit.close();
    });

    test('5. Metadata index deleted with intact .pseudo files: rebuilt cleanly', () async {
      final tempDir = Directory.systemTemp.createTempSync('cie_index_test_');
      try {
        final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
        await db.execute(IndexSchema.createTableSql);
        final index = MetadataIndex(db);
        final fileRepo = FileDocumentRepository(directory: tempDir, index: index);

        final doc1 = Document(
          id: 'doc-file-1',
          title: 'Primero',
          content: 'Algoritmo Uno\nFinAlgoritmo',
          profileId: SyntaxProfileId.classicSpanish,
          revision: 1,
          createdAt: DateTime(2026, 8, 15, 10, 0),
          updatedAt: DateTime(2026, 8, 15, 10, 0),
        );
        final doc2 = Document(
          id: 'doc-file-2',
          title: 'Segundo',
          content: 'Algoritmo Dos\nFinAlgoritmo',
          profileId: SyntaxProfileId.classicSpanish,
          revision: 1,
          createdAt: DateTime(2026, 8, 15, 11, 0),
          updatedAt: DateTime(2026, 8, 15, 11, 0),
        );

        await fileRepo.saveDocument(doc1);
        await fileRepo.saveDocument(doc2);

        var summaries = await fileRepo.listDocuments();
        expect(summaries.length, 2);

        await IndexSchema.clear(index.database);
        summaries = await fileRepo.listDocuments();
        expect(summaries, isEmpty);

        await rebuildMetadataIndex(directory: tempDir, index: index);
        summaries = await fileRepo.listDocuments();
        expect(summaries.length, 2);
        expect(summaries.map((s) => s.title), containsAll(['Primero', 'Segundo']));

        await db.close();
      } finally {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      }
    });

    test('6. Document with syntax profile distinct from UI language: analyzed with its own profile', () {
      const spanishProfileCode = '''
Algoritmo PerfilEspanol
  Definir a Como Entero
  a <- 10
  Escribir a
FinAlgoritmo
''';
      final reportSpanish = analyzer.analyze(
        sourceCode: spanishProfileCode,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.english,
      );
      expect(reportSpanish.isExecutable, isTrue);
      expect(reportSpanish.diagnostics, isEmpty);
    });

    test('7. Offline startup end-to-end: all components initialize without network', () async {
      final settingsCubit = SettingsCubit(
        preferences: preferences,
      );
      final libraryCubit = LibraryCubit(
        repository: docRepo,
        idGenerator: idGen,
        clock: clock,
      );
      final onboardingCubit = OnboardingCubit(
        preferences: preferences,
        knowledgeRepository: knowledgeRepo,
      );

      await settingsCubit.init();
      await libraryCubit.loadDocuments();
      await onboardingCubit.init();

      expect(settingsCubit.state.language, equals(UiLanguageId.system));
      expect(libraryCubit.state.status, equals(LibraryStatus.success));
      expect(onboardingCubit.state.step, isNotNull);

      await settingsCubit.close();
      await libraryCubit.close();
      await onboardingCubit.close();
    });

    test('8. Step budget: infinite recursion or loop halts cleanly without hanging UI', () async {
      const infiniteLoopCode = '''
Algoritmo BucleInfinito
  Definir contador Como Entero
  contador <- 0
  Mientras Verdadero Hacer
    contador <- contador + 1
  FinMientras
FinAlgoritmo
''';
      const runner = StepBatchRunner(maxSteps: 50, batchSize: 10);
      final executionCubit = ExecutionCubit(
        execution: execution,
        runner: runner,
      );

      await executionCubit.advance(
        pace: StepPace.toEnd,
        sourceCode: infiniteLoopCode,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );

      expect(executionCubit.state.status, equals(ExecutionStatus.stepLimitReached));
      expect(executionCubit.state.currentStep.isStepLimitReached, isTrue);
      expect(executionCubit.state.currentStep.isTerminal, isTrue);

      executionCubit.stop();
      expect(executionCubit.state.status, equals(ExecutionStatus.idle));
      await executionCubit.close();
    });
  });
}
