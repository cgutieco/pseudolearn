import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/editor/caret_range.dart';
import 'package:pseudolearn_app/domain/model/editor/editor_key.dart';
import 'package:pseudolearn_app/domain/model/editor/source_edit.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/engine/editing/lexicon_source_editor.dart';

const _editor = LexiconSourceEditor();

const _assignment = EditorKey(
  label: '<-',
  insertion: '<-',
  kind: EditorKeyKind.assignment,
);

const _quote = EditorKey(
  label: '"',
  insertion: '""',
  caretOffset: 1,
  kind: EditorKeyKind.quote,
);

const _conditional = EditorKey.template(
  label: 'Si Entonces',
  insertion: 'Si condicion Entonces\n  \nFinSi',
  caretOffset: 3,
);

SourceEdit _apply({
  required String sourceCode,
  required CaretRange caret,
  required EditorKey key,
  SyntaxProfileId profileId = SyntaxProfileId.classicSpanish,
}) {
  return _editor.applyKey(
    sourceCode: sourceCode,
    caret: caret,
    key: key,
    profileId: profileId,
    revision: 1,
  );
}

void main() {
  group('LexiconSourceEditor · symbols', () {
    test('writes at the caret instead of at the end of the document', () {
      const source = 'Proceso P\n\ta \nFinProceso';

      final edit = _apply(
        sourceCode: source,
        caret: const CaretRange.collapsed(13),
        key: _assignment,
      );

      expect(edit.sourceCode, 'Proceso P\n\ta <-\nFinProceso');
      expect(edit.caret, const CaretRange.collapsed(15));
      expect(edit.revision, 1);
    });

    test('replaces a non empty selection', () {
      const source = 'Proceso P\n\tab\nFinProceso';

      final edit = _apply(
        sourceCode: source,
        caret: const CaretRange(start: 11, end: 13),
        key: _assignment,
      );

      expect(edit.sourceCode, 'Proceso P\n\t<-\nFinProceso');
      expect(edit.caret, const CaretRange.collapsed(13));
    });

    test('honours the caret slot of the key inside a string literal', () {
      const source = 'Escribir "hola"';

      final edit = _apply(
        sourceCode: source,
        caret: const CaretRange.collapsed(13),
        key: _quote,
      );

      expect(edit.sourceCode, 'Escribir "hol""a"');
      expect(edit.caret, const CaretRange.collapsed(14));
    });

    test('writes at the origin of the document', () {
      final edit = _apply(
        sourceCode: 'ab',
        caret: const CaretRange.collapsed(0),
        key: _assignment,
      );

      expect(edit.sourceCode, '<-ab');
      expect(edit.caret, const CaretRange.collapsed(2));
    });

    test('clamps a caret that no longer fits the document', () {
      final edit = _apply(
        sourceCode: 'abc',
        caret: const CaretRange(start: 900, end: 900),
        key: _assignment,
      );

      expect(edit.sourceCode, 'abc<-');
      expect(edit.caret, const CaretRange.collapsed(5));
    });
  });

  group('LexiconSourceEditor · templates', () {
    test('opens a fresh line and inherits the indentation of the caret line', () {
      const source = 'Proceso P\n\tEscribir "x"\nFinProceso';

      final edit = _apply(
        sourceCode: source,
        caret: const CaretRange.collapsed(23),
        key: _conditional,
      );

      expect(
        edit.sourceCode,
        'Proceso P\n\tEscribir "x"\n\tSi condicion Entonces\n\t  \n\tFinSi\nFinProceso',
      );
      expect(edit.caret, const CaretRange.collapsed(28));
    });

    test('indents one more level under a line that opens a block', () {
      const source = 'Proceso P';

      final edit = _apply(
        sourceCode: source,
        caret: const CaretRange.collapsed(9),
        key: _conditional,
      );

      expect(
        edit.sourceCode,
        'Proceso P\n  Si condicion Entonces\n    \n  FinSi',
      );
      expect(edit.caret, const CaretRange.collapsed(15));
    });

    test('the opening lexeme comes from the profile and is not embedded', () {
      const source = 'Proceso P';

      final edit = _apply(
        sourceCode: source,
        caret: const CaretRange.collapsed(9),
        key: _conditional,
        profileId: SyntaxProfileId.english,
      );

      expect(
        edit.sourceCode,
        'Proceso P\nSi condicion Entonces\n  \nFinSi',
      );
    });

    test('does not open a fresh line on an empty document', () {
      final edit = _apply(
        sourceCode: '',
        caret: const CaretRange.collapsed(0),
        key: _conditional,
      );

      expect(edit.sourceCode, 'Si condicion Entonces\n  \nFinSi');
      expect(edit.caret, const CaretRange.collapsed(3));
    });

    test('reuses the indentation already typed on a blank line', () {
      const source = 'Proceso P\n\t';

      final edit = _apply(
        sourceCode: source,
        caret: const CaretRange.collapsed(11),
        key: _conditional,
      );

      expect(
        edit.sourceCode,
        'Proceso P\n\tSi condicion Entonces\n\t  \n\tFinSi',
      );
    });
  });

  group('LexiconSourceEditor · indentation', () {
    test('the indent key writes two spaces when the document has no tabs', () {
      final edit = _apply(
        sourceCode: 'a',
        caret: const CaretRange.collapsed(0),
        key: const EditorKey.indent(),
      );

      expect(edit.sourceCode, '  a');
      expect(edit.caret, const CaretRange.collapsed(2));
    });

    test('the indent key follows the tab already used by the document', () {
      const source = 'Proceso P\n\ta\nFinProceso';

      final edit = _apply(
        sourceCode: source,
        caret: const CaretRange.collapsed(12),
        key: const EditorKey.indent(),
      );

      expect(edit.sourceCode, 'Proceso P\n\ta\t\nFinProceso');
      expect(edit.caret, const CaretRange.collapsed(13));
    });

    test('the dedent key removes one level from the caret line', () {
      const source = 'Proceso P\n\t\tEscribir "x"';

      final edit = _apply(
        sourceCode: source,
        caret: const CaretRange.collapsed(15),
        key: const EditorKey.dedent(),
      );

      expect(edit.sourceCode, 'Proceso P\n\tEscribir "x"');
      expect(edit.caret, const CaretRange.collapsed(14));
    });

    test('the dedent key leaves an unindented line untouched', () {
      const source = 'Proceso P';

      final edit = _apply(
        sourceCode: source,
        caret: const CaretRange.collapsed(4),
        key: const EditorKey.dedent(),
      );

      expect(edit.sourceCode, source);
      expect(edit.caret, const CaretRange(start: 4, end: 4));
    });

    test('the dedent key parks the caret at the start of the line it emptied', () {
      const source = '  a';

      final edit = _apply(
        sourceCode: source,
        caret: const CaretRange.collapsed(1),
        key: const EditorKey.dedent(),
      );

      expect(edit.sourceCode, 'a');
      expect(edit.caret, const CaretRange.collapsed(0));
    });
  });
}
