import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/editor/editor_cubit.dart';
import 'package:pseudolearn_app/domain/model/documents/document.dart';
import 'package:pseudolearn_app/domain/model/editor/caret_range.dart';
import 'package:pseudolearn_app/domain/model/editor/editor_key.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/engine/analysis/core_program_analyzer.dart';
import 'package:pseudolearn_app/engine/completion/profile_completion_source.dart';
import 'package:pseudolearn_app/engine/editing/lexicon_source_editor.dart';
import 'package:pseudolearn_app/engine/editing/profile_key_source.dart';
import '../fakes/fake_clock.dart';
import '../fakes/fake_text_entry_modality.dart';
import '../fakes/in_memory_document_repository.dart';

void main() {
  group('EditorCubit', () {
    late InMemoryDocumentRepository repo;
    late FakeClock clock;
    late EditorCubit cubit;

    setUp(() async {
      repo = InMemoryDocumentRepository();
      clock = FakeClock(DateTime(2026, 8, 15, 12, 0));
      cubit = EditorCubit(
        repository: repo,
        analyzer: CoreProgramAnalyzer(),
        completionSource: const ProfileCompletionSource(),
        keySource: const ProfileKeySource(),
        sourceEditor: const LexiconSourceEditor(),
        textEntry: const FakeTextEntryModality(),
        clock: clock,
      );

      final doc = Document(
        id: 'doc-edit',
        title: 'Editor Test',
        content: 'Algoritmo Test\n  Definir a Como Entero\nFinAlgoritmo',
        profileId: SyntaxProfileId.classicSpanish,
        revision: 1,
        createdAt: clock.now(),
        updatedAt: clock.now(),
      );
      await repo.saveDocument(doc);
    });

    tearDown(() {
      cubit.close();
    });

    test('loads document, updates code and saves', () async {
      await cubit.loadDocument('doc-edit');
      expect(cubit.state.document, isNotNull);
      expect(cubit.state.sourceCode, contains('Algoritmo Test'));
      expect(cubit.state.completions, isNotEmpty);
      expect(cubit.state.report.isExecutable, isTrue);

      cubit.updateSourceCode(
          'Algoritmo Nuevo\n  Definir b Como Entero\nFinAlgoritmo');
      expect(cubit.state.isDirty, isTrue);

      await cubit.saveDocument();
      expect(cubit.state.isDirty, isFalse);
      expect(cubit.state.document?.revision, 2);

      final saved = await repo.loadDocument('doc-edit');
      expect(saved?.content, contains('Algoritmo Nuevo'));
    });

    test('applying a key writes at the caret and marks the document dirty',
        () async {
      await cubit.loadDocument('doc-edit');
      final caretOffset =
          cubit.state.sourceCode.indexOf('Definir') + 'Definir'.length;

      cubit.applyKey(
        const EditorKey(
            label: '<-', insertion: '<-', kind: EditorKeyKind.assignment),
        CaretRange.collapsed(caretOffset),
      );

      expect(cubit.state.sourceCode, contains('Definir<- a Como Entero'));
      expect(cubit.state.isDirty, isTrue);
      expect(cubit.state.pendingEdit?.caret.start, caretOffset + 2);
    });

    test('every applied key raises the revision so the field reapplies it',
        () async {
      await cubit.loadDocument('doc-edit');
      const key = EditorKey(
          label: '(', insertion: '(', kind: EditorKeyKind.openParenthesis);

      cubit.applyKey(key, const CaretRange.collapsed(0));
      final first = cubit.state.pendingEdit!.revision;
      cubit.applyKey(key, const CaretRange.collapsed(0));

      expect(cubit.state.pendingEdit!.revision, first + 1);
    });

    test(
        'applying a key without a loaded document falls back to the classic profile',
        () {
      cubit.applyKey(
        const EditorKey.indent(),
        const CaretRange.collapsed(0),
      );

      expect(cubit.state.sourceCode, '  ');
      expect(cubit.state.pendingEdit?.caret.start, 2);
      expect(cubit.state.errorMessage, isNull);
    });

    test(
        'applying a key re-analyses the program and reports the new diagnostics',
        () async {
      await cubit.loadDocument('doc-edit');
      expect(cubit.state.report.isExecutable, isTrue);

      cubit.applyKey(
        const EditorKey(
            label: '(', insertion: '(', kind: EditorKeyKind.openParenthesis),
        const CaretRange.collapsed(0),
      );

      expect(cubit.state.report.isExecutable, isFalse);
      expect(cubit.state.report.diagnostics, isNotEmpty);
    });

    test(
        'automatically saves document after debounce period on updateSourceCode',
        () async {
      await cubit.loadDocument('doc-edit');
      cubit
          .updateSourceCode('Algoritmo AutoSaved\n  Escribir 42\nFinAlgoritmo');
      expect(cubit.state.isDirty, isTrue);

      await Future<void>.delayed(const Duration(milliseconds: 1600));

      expect(cubit.state.isDirty, isFalse);
      final saved = await repo.loadDocument('doc-edit');
      expect(saved?.content, contains('Algoritmo AutoSaved'));
    });

    test('automatically saves document after debounce period on applyKey',
        () async {
      await cubit.loadDocument('doc-edit');
      cubit.applyKey(
        const EditorKey.indent(),
        const CaretRange.collapsed(0),
      );
      expect(cubit.state.isDirty, isTrue);

      await Future<void>.delayed(const Duration(milliseconds: 1600));

      expect(cubit.state.isDirty, isFalse);
      final saved = await repo.loadDocument('doc-edit');
      expect(saved?.content, startsWith('  '));
    });
  });
}
