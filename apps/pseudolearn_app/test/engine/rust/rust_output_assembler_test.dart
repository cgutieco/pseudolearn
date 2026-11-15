import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/execution/output_line.dart';
import 'package:pseudolearn_app/engine/rust/rust_output_assembler.dart';

void main() {
  group('RustOutputAssembler', () {
    test('joins fragments until a newline closes the line', () {
      final assembler = RustOutputAssembler()
        ..append('a')
        ..append('b\n')
        ..append('c');
      expect(assembler.lines.map((line) => line.text), ['ab', 'c']);
    });

    test('ignores empty output', () {
      final assembler = RustOutputAssembler()..append('');
      expect(assembler.lines, isEmpty);
    });

    test('echoes input as a separate line and closes the open line', () {
      final assembler = RustOutputAssembler()
        ..append('x')
        ..echoInput('5')
        ..append('y');
      expect(assembler.lines.map((line) => line.kind), [
        OutputLineKind.programOutput,
        OutputLineKind.userInputEcho,
        OutputLineKind.programOutput,
      ]);
    });

    test('keeps blank lines produced by consecutive newlines', () {
      final assembler = RustOutputAssembler()..append('\n\nz');
      expect(assembler.lines.map((line) => line.text), ['', '', 'z']);
    });
  });
}
