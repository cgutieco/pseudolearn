import '../fakes/native_test_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/editor/editor_cubit.dart';
import 'package:pseudolearn_app/domain/model/completion/completion_item.dart';
import 'package:pseudolearn_app/domain/model/completion/completion_query_result.dart';
import 'package:pseudolearn_app/domain/model/documents/document.dart';
import 'package:pseudolearn_app/domain/model/editor/caret_range.dart';
import 'package:pseudolearn_app/domain/model/editor/editor_key.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/ports/contextual_completion_source.dart';
import '../fakes/fake_clock.dart';
import '../fakes/fake_text_entry_modality.dart';
import '../fakes/in_memory_document_repository.dart';

final class _ContextualCompletions implements ContextualCompletionSource {
  final List<(String, SyntaxProfileId, int, int)> requests = [];
  int? responseRevisionOffset;

  @override
  CompletionQueryResult complete({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required int cursorUtf16,
    required int revision,
  }) {
    requests.add((sourceCode, profileId, cursorUtf16, revision));
    return CompletionQueryResult(
      revision: revision + (responseRevisionOffset ?? 0),
      candidates: [
        CompletionItem(
          label: 'Mientras',
          template: 'Mientras',
          caretOffset: 8,
          family: CompletionFamily.structured,
          replacementRange: const CaretRange(start: 0, end: 3),
          revision: revision,
        ),
      ],
    );
  }
}

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
        analyzer: nativeTestEngine.analyzer,
        completionSource: nativeTestEngine.completionSource,
        keySource: nativeTestEngine.editorKeySource,
        sourceEditor: nativeTestEngine.sourceEditor,
        textEntry: const FakeTextEntryModality(),
        clock: clock,
      );

      final doc = Document(
        id: 'doc-edit',
        title: 'Editor Test',
        content: 'Algoritmo Test\n  Definir a Como Entero <- 0\nFinAlgoritmo',
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
        'Algoritmo Nuevo\n  Definir b Como Entero <- 0\nFinAlgoritmo',
      );
      expect(cubit.state.isDirty, isTrue);

      await cubit.saveDocument();
      expect(cubit.state.isDirty, isFalse);
      expect(cubit.state.document?.revision, 2);

      final saved = await repo.loadDocument('doc-edit');
      expect(saved?.content, contains('Algoritmo Nuevo'));
    });

    test(
      'applying a key writes at the caret and marks the document dirty',
      () async {
        await cubit.loadDocument('doc-edit');
        final caretOffset =
            cubit.state.sourceCode.indexOf('Definir') + 'Definir'.length;

        cubit.applyKey(
          const EditorKey(
            label: '<-',
            insertion: '<-',
            kind: EditorKeyKind.assignment,
          ),
          CaretRange.collapsed(caretOffset),
        );

        expect(cubit.state.sourceCode, contains('Definir<- a Como Entero'));
        expect(cubit.state.isDirty, isTrue);
        expect(cubit.state.pendingEdit?.caret.start, caretOffset + 2);
      },
    );

    test(
      'every applied key raises the revision so the field reapplies it',
      () async {
        await cubit.loadDocument('doc-edit');
        const key = EditorKey(
          label: '(',
          insertion: '(',
          kind: EditorKeyKind.openParenthesis,
        );

        cubit.applyKey(key, const CaretRange.collapsed(0));
        final first = cubit.state.pendingEdit!.revision;
        cubit.applyKey(key, const CaretRange.collapsed(0));

        expect(cubit.state.pendingEdit!.revision, first + 1);
      },
    );

    test(
      'applying a key without a loaded document falls back to the classic profile',
      () {
        cubit.applyKey(const EditorKey.indent(), const CaretRange.collapsed(0));

        expect(cubit.state.sourceCode, '  ');
        expect(cubit.state.pendingEdit?.caret.start, 2);
        expect(cubit.state.errorMessage, isNull);
      },
    );

    test(
      'queries completion with the active document revision and cursor',
      () async {
        await cubit.close();
        final completions = _ContextualCompletions();
        cubit = EditorCubit(
          repository: repo,
          analyzer: nativeTestEngine.analyzer,
          completionSource: nativeTestEngine.completionSource,
          contextualCompletionSource: completions,
          keySource: nativeTestEngine.editorKeySource,
          sourceEditor: nativeTestEngine.sourceEditor,
          textEntry: const FakeTextEntryModality(),
          clock: clock,
        );
        await cubit.loadDocument('doc-edit');
        const source = 'Mientras';

        cubit.updateSourceCode(source, cursorUtf16: 4);
        cubit.updateCompletionCursor(2);

        expect(completions.requests[1], (
          source,
          SyntaxProfileId.classicSpanish,
          4,
          2,
        ));
        expect(completions.requests[2], (
          source,
          SyntaxProfileId.classicSpanish,
          2,
          2,
        ));
        expect(cubit.state.contextualCompletions.single.revision, 2);
      },
    );

    test(
      'discards completion results from a stale document revision',
      () async {
        await cubit.close();
        final completions = _ContextualCompletions()
          ..responseRevisionOffset = -1;
        cubit = EditorCubit(
          repository: repo,
          analyzer: nativeTestEngine.analyzer,
          completionSource: nativeTestEngine.completionSource,
          contextualCompletionSource: completions,
          keySource: nativeTestEngine.editorKeySource,
          sourceEditor: nativeTestEngine.sourceEditor,
          textEntry: const FakeTextEntryModality(),
          clock: clock,
        );
        await cubit.loadDocument('doc-edit');

        cubit.updateSourceCode('Algoritmo P', cursorUtf16: 11);

        expect(cubit.state.completionRevision, 2);
        expect(cubit.state.contextualCompletions, isEmpty);
      },
    );

    test('does not apply a completion from a superseded revision', () async {
      await cubit.loadDocument('doc-edit');
      const source = 'whi';
      cubit.updateSourceCode(source, cursorUtf16: source.length);

      cubit.applyKey(
        const EditorKey.completion(
          label: 'Mientras',
          insertion: 'Mientras',
          replacementRange: CaretRange(start: 0, end: 3),
          revision: 0,
        ),
        const CaretRange.collapsed(3),
      );

      expect(cubit.state.sourceCode, source);
    });

    test(
      'applying a key re-analyses the program and reports the new diagnostics',
      () async {
        await cubit.loadDocument('doc-edit');
        expect(cubit.state.report.isExecutable, isTrue);

        cubit.applyKey(
          const EditorKey(
            label: '(',
            insertion: '(',
            kind: EditorKeyKind.openParenthesis,
          ),
          const CaretRange.collapsed(0),
        );

        expect(cubit.state.report.isExecutable, isFalse);
        expect(cubit.state.report.diagnostics, isNotEmpty);
      },
    );

    test(
      'automatically saves document after debounce period on updateSourceCode',
      () async {
        await cubit.loadDocument('doc-edit');
        cubit.updateSourceCode(
          'Algoritmo AutoSaved\n  Escribir 42\nFinAlgoritmo',
        );
        expect(cubit.state.isDirty, isTrue);

        await Future<void>.delayed(const Duration(milliseconds: 1600));

        expect(cubit.state.isDirty, isFalse);
        final saved = await repo.loadDocument('doc-edit');
        expect(saved?.content, contains('Algoritmo AutoSaved'));
      },
    );

    test(
      'automatically saves document after debounce period on applyKey',
      () async {
        await cubit.loadDocument('doc-edit');
        cubit.applyKey(const EditorKey.indent(), const CaretRange.collapsed(0));
        expect(cubit.state.isDirty, isTrue);

        await Future<void>.delayed(const Duration(milliseconds: 1600));

        expect(cubit.state.isDirty, isFalse);
        final saved = await repo.loadDocument('doc-edit');
        expect(saved?.content, startsWith('  '));
      },
    );
  });
}
