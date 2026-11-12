import '../fakes/native_test_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/editor/editor_cubit.dart';
import 'package:pseudolearn_app/domain/model/editor/caret_range.dart';
import 'package:pseudolearn_app/domain/model/editor/editor_key.dart';
import 'package:pseudolearn_app/domain/model/editor/source_edit.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/ports/source_editor.dart';
import '../fakes/fake_clock.dart';
import '../fakes/fake_text_entry_modality.dart';
import '../fakes/in_memory_document_repository.dart';

final class _ScriptedEditor implements SourceEditor {
  final List<String> characters = [];
  SourceEdit? typingResult;
  SourceEdit keyResult = const SourceEdit(
    sourceCode: '',
    caret: CaretRange.collapsed(0),
    revision: 1,
  );

  @override
  SourceEdit applyKey({
    required String sourceCode,
    required CaretRange caret,
    required EditorKey key,
    required SyntaxProfileId profileId,
    required int revision,
  }) => keyResult;

  @override
  SourceEdit? afterTyping({
    required String sourceCode,
    required int cursorUtf16,
    required String character,
    required SyntaxProfileId profileId,
    required int revision,
  }) {
    characters.add(character);
    return typingResult;
  }
}

void main() {
  group('EditorCubit · typing assistance', () {
    late _ScriptedEditor editor;
    late EditorCubit cubit;

    setUp(() {
      editor = _ScriptedEditor();
      cubit = EditorCubit(
        repository: InMemoryDocumentRepository(),
        analyzer: nativeTestEngine.analyzer,
        completionSource: nativeTestEngine.completionSource,
        keySource: nativeTestEngine.editorKeySource,
        sourceEditor: editor,
        textEntry: const FakeTextEntryModality(),
        clock: FakeClock(DateTime(2026, 8, 15)),
      );
    });

    tearDown(() => cubit.close());

    test('asks for assistance only when the setting is on', () {
      cubit.updateSourceCode('a', cursorUtf16: 1);
      expect(editor.characters, isEmpty);

      cubit.updateSourceCode('ab', cursorUtf16: 2, assisted: true);
      expect(editor.characters, ['b']);
    });

    test('passes the typed character and applies the returned edit', () {
      cubit.updateSourceCode('Algoritmo P\n', cursorUtf16: 12);
      editor.typingResult = const SourceEdit(
        sourceCode: 'Algoritmo P\n  \nFinAlgoritmo\n',
        caret: CaretRange.collapsed(14),
        revision: 1,
        templateActive: false,
      );

      cubit.updateSourceCode(
        'Algoritmo P\n\n',
        cursorUtf16: 13,
        assisted: true,
      );

      expect(editor.characters.last, '\n');
      expect(cubit.state.sourceCode, 'Algoritmo P\n  \nFinAlgoritmo\n');
      expect(cubit.state.pendingEdit?.caret, const CaretRange.collapsed(14));
      expect(cubit.state.isDirty, isTrue);
    });

    test('a pasted block is not treated as a typed character', () {
      cubit.updateSourceCode('a', cursorUtf16: 1);
      cubit.updateSourceCode('abcd', cursorUtf16: 4, assisted: true);
      expect(editor.characters, ['']);
    });

    test(
      'an unchanged result keeps the pending edit and records the template',
      () {
        cubit.updateSourceCode('ab', cursorUtf16: 2);
        editor.typingResult = const SourceEdit(
          sourceCode: 'abc',
          caret: CaretRange.collapsed(3),
          revision: 1,
          templateActive: true,
        );

        cubit.updateSourceCode('abc', cursorUtf16: 3, assisted: true);

        expect(cubit.state.pendingEdit, isNull);
        expect(cubit.state.templateActive, isTrue);
      },
    );

    test(
      'keeps syncing while a template is active even if assistance is off',
      () {
        editor.keyResult = const SourceEdit(
          sourceCode: 'xyz',
          caret: CaretRange(start: 0, end: 1),
          revision: 1,
          templateActive: true,
        );
        cubit.applyKey(
          const EditorKey.stop(EditorKeyKind.stopNext),
          const CaretRange.collapsed(0),
        );
        expect(cubit.state.templateActive, isTrue);
        expect(
          cubit.state.pendingEdit?.caret,
          const CaretRange(start: 0, end: 1),
        );

        editor.typingResult = const SourceEdit(
          sourceCode: 'xyzw',
          caret: CaretRange.collapsed(4),
          revision: 2,
          templateActive: false,
        );
        cubit.updateSourceCode('xyzw', cursorUtf16: 4);

        expect(editor.characters, ['']);
        expect(cubit.state.templateActive, isFalse);
      },
    );

    test('a failed service call leaves the typed text untouched', () {
      cubit.updateSourceCode('a', cursorUtf16: 1);
      editor.typingResult = null;

      cubit.updateSourceCode('ab', cursorUtf16: 2, assisted: true);

      expect(cubit.state.sourceCode, 'ab');
      expect(cubit.state.templateActive, isFalse);
    });
  });
}
