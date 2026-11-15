import '../../fakes/native_test_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/editor/caret_range.dart';
import 'package:pseudolearn_app/domain/model/editor/editor_key.dart';
import 'package:pseudolearn_app/domain/model/editor/source_edit.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';

final _editor = nativeTestEngine.sourceEditor;

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
  label: 'Si',
  insertion: 'Si condicion Entonces\n  \nFinSi',
  caretOffset: 3,
  construction: 'if',
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
  group('RustLexiconSourceEditor · symbols', () {
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

  group('RustLexiconSourceEditor · templates', () {
    String selected(SourceEdit edit) =>
        edit.sourceCode.substring(edit.caret.start, edit.caret.end);

    test('opens a fresh line, inherits the indentation and selects the stop', () {
      const source = 'Algoritmo P\n\tEscribir "x"\nFinAlgoritmo';

      final edit = _apply(
        sourceCode: source,
        caret: const CaretRange.collapsed(25),
        key: _conditional,
      );

      expect(
        edit.sourceCode,
        'Algoritmo P\n\tEscribir "x"\n\tSi condicion Entonces\n\t  \n\tSino\n\t  \n\tFinSi\nFinAlgoritmo',
      );
      expect(selected(edit), 'condicion');
      expect(edit.templateActive, isTrue);
    });

    test('indents one more level under a line that opens a block', () {
      const source = 'Algoritmo P';

      final edit = _apply(
        sourceCode: source,
        caret: const CaretRange.collapsed(11),
        key: _conditional,
      );

      expect(
        edit.sourceCode,
        'Algoritmo P\n  Si condicion Entonces\n    \n  Sino\n    \n  FinSi',
      );
      expect(selected(edit), 'condicion');
    });

    test('the lexemes come from the profile of the document', () {
      const source = 'Algorithm P';

      final edit = _apply(
        sourceCode: source,
        caret: const CaretRange.collapsed(11),
        key: _conditional,
        profileId: SyntaxProfileId.english,
      );

      expect(edit.sourceCode, startsWith('Algorithm P\n  If condition Then'));
      expect(selected(edit), 'condition');
    });

    test('does not open a fresh line on an empty document', () {
      final edit = _apply(
        sourceCode: '',
        caret: const CaretRange.collapsed(0),
        key: _conditional,
      );

      expect(edit.sourceCode, startsWith('Si condicion Entonces\n  \nSino'));
      expect(selected(edit), 'condicion');
    });

    test('reuses the indentation already typed on a blank line', () {
      const source = 'Algoritmo P\n\t';

      final edit = _apply(
        sourceCode: source,
        caret: const CaretRange.collapsed(13),
        key: _conditional,
      );

      expect(
        edit.sourceCode,
        startsWith('Algoritmo P\n\tSi condicion Entonces\n\t  \n\tSino'),
      );
    });

    test('a template key without a construction is inserted as plain text', () {
      final edit = _apply(
        sourceCode: '',
        caret: const CaretRange.collapsed(0),
        key: const EditorKey.template(
          label: 'x',
          insertion: 'abc',
          caretOffset: 1,
        ),
      );

      expect(edit.sourceCode, 'abc');
      expect(edit.caret, const CaretRange.collapsed(1));
      expect(edit.templateActive, isFalse);
    });

    test('stop keys walk the template and leave it at the body', () {
      const source = 'Algoritmo P\n  Par\nFinAlgoritmo';
      final inserted = _apply(
        sourceCode: source,
        caret: const CaretRange(start: 14, end: 17),
        key: const EditorKey.template(
          label: 'Para',
          insertion: '',
          caretOffset: 0,
          construction: 'for',
        ),
      );
      expect(selected(inserted), 'indice');
      final next = _apply(
        sourceCode: inserted.sourceCode,
        caret: inserted.caret,
        key: const EditorKey.stop(EditorKeyKind.stopNext),
      );
      expect(selected(next), 'limite');
      expect(next.templateActive, isTrue);
      final done = _apply(
        sourceCode: next.sourceCode,
        caret: next.caret,
        key: const EditorKey.stop(EditorKeyKind.stopExit),
      );
      expect(done.caret.isCollapsed, isTrue);
      expect(done.templateActive, isFalse);
    });

    test('stop keys outside a template keep text and selection', () {
      final edit = _apply(
        sourceCode: 'abc',
        caret: const CaretRange.collapsed(1),
        key: const EditorKey.stop(EditorKeyKind.stopNext),
      );

      expect(edit.sourceCode, 'abc');
      expect(edit.caret, const CaretRange.collapsed(1));
    });
  });

  group('RustLexiconSourceEditor · completions', () {
    test('accepting a structure re-indents it and selects its first stop', () {
      const source = 'Algoritmo P\n  Mie\nFinAlgoritmo';
      final result = _editor.applyKey(
        sourceCode: source,
        caret: const CaretRange.collapsed(17),
        key: const EditorKey.completion(
          label: 'Mientras',
          insertion: 'Mientras',
          replacementRange: CaretRange(start: 14, end: 17),
          revision: 4,
        ),
        profileId: SyntaxProfileId.classicSpanish,
        revision: 1,
      );
      expect(
        result.sourceCode,
        'Algoritmo P\n  Mientras condicion Hacer\n    \n  FinMientras\nFinAlgoritmo',
      );
      expect(
        result.sourceCode.substring(result.caret.start, result.caret.end),
        'condicion',
      );
      expect(result.templateActive, isTrue);
    });

    test('accepting a bilingual hint inserts only the native word', () {
      const source = 'Algoritmo P\n  whi\nFinAlgoritmo';
      final result = _editor.applyKey(
        sourceCode: source,
        caret: const CaretRange.collapsed(17),
        key: const EditorKey.completion(
          label: 'Mientras',
          insertion: 'Mientras',
          replacementRange: CaretRange(start: 14, end: 17),
          revision: 4,
        ),
        profileId: SyntaxProfileId.classicSpanish,
        revision: 1,
      );
      expect(result.sourceCode, 'Algoritmo P\n  Mientras\nFinAlgoritmo');
      expect(result.templateActive, isFalse);
    });

    test('accepting a plain word leaves the caret after it', () {
      const source = 'Algoritmo P\n  Esc\nFinAlgoritmo';
      final result = _editor.applyKey(
        sourceCode: source,
        caret: const CaretRange.collapsed(17),
        key: const EditorKey.completion(
          label: 'Escribir',
          insertion: 'Escribir',
          replacementRange: CaretRange(start: 14, end: 17),
          revision: 4,
        ),
        profileId: SyntaxProfileId.classicSpanish,
        revision: 1,
      );
      expect(result.sourceCode, 'Algoritmo P\n  Escribir\nFinAlgoritmo');
      expect(result.caret, const CaretRange.collapsed(22));
      expect(result.templateActive, isFalse);
    });

    test(
      'falls back to the plain replacement when the service does not offer it',
      () {
        final result = _editor.applyKey(
          sourceCode: 'whi\n',
          caret: const CaretRange.collapsed(3),
          key: const EditorKey.completion(
            label: 'Inexistente',
            insertion: 'Inexistente',
            replacementRange: CaretRange(start: 0, end: 3),
            revision: 4,
          ),
          profileId: SyntaxProfileId.classicSpanish,
          revision: 1,
        );
        expect(result.sourceCode, 'Inexistente\n');
        expect(result.caret, const CaretRange.collapsed(11));
      },
    );
  });

  group('RustLexiconSourceEditor · typing assistance', () {
    test('Enter after a block header closes it', () {
      const source = 'Algoritmo P\n  Mientras 1 = 1 Hacer\n\nFinAlgoritmo\n';
      final edit = _editor.afterTyping(
        sourceCode: source,
        cursorUtf16: 35,
        character: '\n',
        profileId: SyntaxProfileId.classicSpanish,
        revision: 1,
      );
      expect(
        edit!.sourceCode,
        'Algoritmo P\n  Mientras 1 = 1 Hacer\n    \n  FinMientras\nFinAlgoritmo\n',
      );
      expect(edit.caret, const CaretRange.collapsed(39));
    });

    test('an opening parenthesis is paired', () {
      final edit = _editor.afterTyping(
        sourceCode: 'Algoritmo P\n  Escribir (\nFinAlgoritmo\n',
        cursorUtf16: 24,
        character: '(',
        profileId: SyntaxProfileId.classicSpanish,
        revision: 1,
      );
      expect(edit!.sourceCode, contains('Escribir ()'));
      expect(edit.caret, const CaretRange.collapsed(24));
    });

    test('an ordinary character keeps the text', () {
      final edit = _editor.afterTyping(
        sourceCode: 'Algoritmo P\n  x\nFinAlgoritmo\n',
        cursorUtf16: 15,
        character: 'x',
        profileId: SyntaxProfileId.classicSpanish,
        revision: 1,
      );
      expect(edit!.sourceCode, 'Algoritmo P\n  x\nFinAlgoritmo\n');
    });
  });

  group('RustLexiconSourceEditor · indentation', () {
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

    test(
      'the dedent key parks the caret at the start of the line it emptied',
      () {
        const source = '  a';

        final edit = _apply(
          sourceCode: source,
          caret: const CaretRange.collapsed(1),
          key: const EditorKey.dedent(),
        );

        expect(edit.sourceCode, 'a');
        expect(edit.caret, const CaretRange.collapsed(0));
      },
    );
  });
}
