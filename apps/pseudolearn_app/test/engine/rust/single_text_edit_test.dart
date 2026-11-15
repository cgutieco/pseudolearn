import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/engine/rust/single_text_edit.dart';

String _apply(String before, SingleTextEdit edit) =>
    before.replaceRange(edit.start, edit.end, edit.replacement);

void main() {
  group('SingleTextEdit', () {
    test('identical texts need no edit', () {
      expect(SingleTextEdit.between('abc', 'abc'), isNull);
      expect(SingleTextEdit.between('', ''), isNull);
    });

    test('describes an insertion in the middle', () {
      final edit = SingleTextEdit.between('abcd', 'abXcd')!;
      expect((edit.start, edit.end, edit.replacement), (2, 2, 'X'));
    });

    test('describes a deletion and a replacement', () {
      final deletion = SingleTextEdit.between('abcd', 'ad')!;
      expect((deletion.start, deletion.end, deletion.replacement), (1, 3, ''));
      final replacement = SingleTextEdit.between('abcd', 'aXYd')!;
      expect(_apply('abcd', replacement), 'aXYd');
    });

    test('handles an empty side', () {
      final created = SingleTextEdit.between('', 'hola')!;
      expect(_apply('', created), 'hola');
      final erased = SingleTextEdit.between('hola', '')!;
      expect(_apply('hola', erased), '');
    });

    test('repeated characters never overlap prefix and suffix', () {
      final edit = SingleTextEdit.between('aa', 'aaa')!;
      expect(_apply('aa', edit), 'aaa');
      final shrunk = SingleTextEdit.between('aaa', 'aa')!;
      expect(_apply('aaa', shrunk), 'aa');
    });

    test('never splits a surrogate pair', () {
      const before = 'a🧩b';
      const after = 'a🧪b';
      final edit = SingleTextEdit.between(before, after)!;
      expect(edit.start, 1);
      expect(edit.end, 3);
      expect(edit.replacement, '🧪');
      expect(_apply(before, edit), after);
    });

    test('a pair that only shares its high surrogate is replaced whole', () {
      const before = '🧩';
      const after = '🧪';
      final edit = SingleTextEdit.between(before, after)!;
      expect((edit.start, edit.end), (0, 2));
    });
  });
}
