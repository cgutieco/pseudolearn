import 'package:flutter_test/flutter_test.dart';

import 'package:pseudolearn_app/domain/model/editor/caret_range.dart';
import 'package:pseudolearn_app/domain/model/editor/editor_key.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/engine/rust/rust_editor_key_source.dart';
import 'package:pseudolearn_app/engine/rust/rust_editor_vocabulary.dart';
import 'package:pseudolearn_app/engine/rust/rust_source_editor.dart';
import 'package:pseudolearn_app/engine/rust/rust_transport.dart';

final class _VocabularyTransport implements RustTransport {
  final List<String> openers;

  const _VocabularyTransport(this.openers);

  @override
  Object? call(String operation, Map<String, Object?> arguments) => {
    'profile': arguments['profile'],
    'keywords': const <Object?>[],
    'block_openers': openers,
    'symbols': const {
      'assignment': '<-',
      'quote': '"',
      'left_parenthesis': '(',
      'right_parenthesis': ')',
      'greater_equal': '>=',
      'less_equal': '<=',
    },
  };

  @override
  void close() {}
}

void main() {
  group('Rust editor services', () {
    test('keyboard keys use service grammar symbols', () {
      final source = RustEditorKeySource(
        RustEditorVocabulary(const _VocabularyTransport([])),
      );

      final keys = source.keysFor(SyntaxProfileId.english);

      expect(keys.map((key) => key.label), [
        'TAB',
        '<-',
        '"',
        '(',
        ')',
        '>=',
        '<=',
      ]);
      expect(keys[2].insertion, '""');
      expect(keys[2].caretOffset, 1);
    });

    test('template insertion indents from generated block openers', () {
      final editor = RustSourceEditor(
        RustEditorVocabulary(const _VocabularyTransport(['algorithm', 'if'])),
      );

      final edit = editor.applyKey(
        sourceCode: 'algorithm P',
        caret: const CaretRange.collapsed(11),
        key: const EditorKey.template(
          label: 'if',
          insertion: 'if condition then\n\nelse\n\nendIf',
          caretOffset: 13,
        ),
        profileId: SyntaxProfileId.english,
        revision: 4,
      );

      expect(
        edit.sourceCode,
        'algorithm P\n  if condition then\n  \n  else\n  \n  endIf',
      );
      expect(edit.caret.start, 27);
      expect(edit.revision, 4);
    });

    test('dedent at the left edge keeps source and caret intact', () {
      final editor = RustSourceEditor(
        RustEditorVocabulary(const _VocabularyTransport([])),
      );

      final edit = editor.applyKey(
        sourceCode: 'write 1',
        caret: const CaretRange.collapsed(0),
        key: const EditorKey.dedent(),
        profileId: SyntaxProfileId.classicSpanish,
        revision: 8,
      );

      expect(edit.sourceCode, 'write 1');
      expect(edit.caret.start, 0);
      expect(edit.revision, 8);
    });
  });
}
