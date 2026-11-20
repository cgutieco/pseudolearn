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

    test('an echo keeps the variable and the line that read it', () {
      final assembler = RustOutputAssembler()
        ..echoInput('5', target: 'numero', sourceLine: 4);
      final echo = assembler.lines.single;
      expect(echo.target, 'numero');
      expect(echo.sourceLine, 4);
    });

    test('a rejected value is its own line and closes the open line', () {
      final assembler = RustOutputAssembler()
        ..append('edad? ')
        ..rejectInput('veinte', target: 'edad', sourceLine: 7)
        ..append('z');
      expect(assembler.lines.map((line) => line.kind), [
        OutputLineKind.programOutput,
        OutputLineKind.rejectedInput,
        OutputLineKind.programOutput,
      ]);
      expect(assembler.lines[1].text, 'veinte');
      expect(assembler.lines[1].target, 'edad');
    });

    test('an empty echo is still recorded', () {
      final assembler = RustOutputAssembler()..echoInput('');
      expect(assembler.lines.single.text, '');
    });

    test('keeps blank lines produced by consecutive newlines', () {
      final assembler = RustOutputAssembler()..append('\n\nz');
      expect(assembler.lines.map((line) => line.text), ['', '', 'z']);
    });
  });
}
