import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/engine/rust/rust_effect_tape_assembly.dart';

Map<String, Object?> _window(List<int> sequences, {String status = 'reproducible'}) => {
  'format': 'pseudolearn.tape/v1',
  'status': status,
  'entries': [
    for (final sequence in sequences) {'effect_seq': sequence},
  ],
};

List<Object?> _sequences(Map<String, Object?>? document) => [
  for (final entry in document!['entries'] as List<Object?>)
    (entry as Map<String, Object?>)['effect_seq'],
];

void main() {
  test('starts empty and without a document', () {
    final tape = RustEffectTapeAssembly();

    expect(tape.entryCount, 0);
    expect(tape.document(), isNull);
  });

  test('concatenates consecutive windows in order', () {
    final tape = RustEffectTapeAssembly()
      ..receive(_window([1]), from: 0)
      ..receive(_window([2, 3]), from: 1)
      ..receive(_window([]), from: 3)
      ..receive(_window([4]), from: 3);

    expect(tape.entryCount, 4);
    expect(_sequences(tape.document()), [1, 2, 3, 4]);
  });

  test('keeps the header of the latest window', () {
    final tape = RustEffectTapeAssembly()
      ..receive(_window([1]), from: 0)
      ..receive(_window([2], status: 'incomplete'), from: 1);

    expect(tape.document()!['status'], 'incomplete');
    expect(tape.document()!['format'], 'pseudolearn.tape/v1');
  });

  test('a full tape received from zero replaces what was assembled', () {
    final tape = RustEffectTapeAssembly()
      ..receive(_window([1, 2]), from: 0)
      ..receive(_window([1, 2, 3]), from: 0);

    expect(_sequences(tape.document()), [1, 2, 3]);
  });

  test('a response without tape changes nothing', () {
    final tape = RustEffectTapeAssembly()
      ..receive(_window([1]), from: 0)
      ..receive(null, from: 1);

    expect(_sequences(tape.document()), [1]);
  });

  test('a window past the assembled entries is rejected', () {
    final tape = RustEffectTapeAssembly()..receive(_window([1]), from: 0);

    expect(
      () => tape.receive(_window([3]), from: 2),
      throwsFormatException,
    );
    expect(tape.entryCount, 1);
  });

  test('a window without an entry list is rejected', () {
    final tape = RustEffectTapeAssembly();

    expect(
      () => tape.receive(const {'format': 'pseudolearn.tape/v1'}, from: 0),
      throwsFormatException,
    );
    expect(tape.document(), isNull);
  });

  test('the document is a copy that later windows do not change', () {
    final tape = RustEffectTapeAssembly()..receive(_window([1]), from: 0);
    final document = tape.document();

    tape.receive(_window([2]), from: 1);

    expect(_sequences(document), [1]);
  });

  test('clear forgets header and entries', () {
    final tape = RustEffectTapeAssembly()
      ..receive(_window([1]), from: 0)
      ..clear();

    expect(tape.entryCount, 0);
    expect(tape.document(), isNull);
  });
}
