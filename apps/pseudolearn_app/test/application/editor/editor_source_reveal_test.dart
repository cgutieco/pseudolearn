import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/editor/editor_cubit.dart';
import 'package:pseudolearn_app/domain/model/analysis/source_range.dart';
import 'package:pseudolearn_app/domain/model/editor/caret_range.dart';

import '../../fakes/fake_clock.dart';
import '../../fakes/fake_text_entry_modality.dart';
import '../../fakes/in_memory_document_repository.dart';
import '../../fakes/native_test_engine.dart';

const String _source = 'Algoritmo Principal\nEscribir 1;\nFinAlgoritmo\n';

SourceRange _range(int start, int end) => SourceRange(
  startOffset: start,
  endOffset: end,
  startLine: 2,
  startColumn: 1,
  endLine: 2,
  endColumn: end - start + 1,
);

void main() {
  group('EditorCubit · revealing a source range', () {
    late EditorCubit cubit;

    setUp(() {
      cubit = EditorCubit(
        repository: InMemoryDocumentRepository(),
        analyzer: nativeTestEngine.analyzer,
        completionSource: nativeTestEngine.completionSource,
        keySource: nativeTestEngine.editorKeySource,
        sourceEditor: nativeTestEngine.sourceEditor,
        textEntry: const FakeTextEntryModality(),
        clock: FakeClock(DateTime(2026, 11, 1)),
      );
      cubit.updateSourceCode(_source, cursorUtf16: 0);
    });

    tearDown(() => cubit.close());

    test('selects the exact range without changing the text', () {
      final dirty = cubit.state.isDirty;

      cubit.revealSource(_range(20, 30));

      expect(cubit.state.sourceCode, _source);
      expect(cubit.state.isDirty, dirty);
      expect(cubit.state.pendingEdit?.sourceCode, _source);
      expect(cubit.state.pendingEdit?.caret, const CaretRange(start: 20, end: 30));
    });

    test('each reveal is a new revision so the same range can be shown again', () {
      cubit.revealSource(_range(20, 30));
      final first = cubit.state.pendingEdit!.revision;

      cubit.revealSource(_range(20, 30));

      expect(cubit.state.pendingEdit!.revision, first + 1);
    });

    test('a range beyond the text is clamped to the document', () {
      cubit.revealSource(_range(40, 400));

      expect(
        cubit.state.pendingEdit?.caret,
        CaretRange(start: 40, end: _source.length),
      );
    });

    test('an empty range places a collapsed caret', () {
      cubit.revealSource(_range(0, 0));

      expect(cubit.state.pendingEdit?.caret, const CaretRange.collapsed(0));
    });
  });
}
