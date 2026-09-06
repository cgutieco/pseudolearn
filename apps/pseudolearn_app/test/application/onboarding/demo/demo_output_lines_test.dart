import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/onboarding/demo/demo_output_lines.dart';
import 'package:pseudolearn_app/domain/model/execution/output_line.dart';

const _lines = DemoOutputLines();

List<OutputLine> _fragments(List<String> texts) {
  return [
    for (final text in texts)
      OutputLine(text: text, kind: OutputLineKind.programOutput),
  ];
}

void main() {
  group('DemoOutputLines', () {
    test('joins the fragments of one statement into a single line', () {
      final lines = _lines.of(
        _fragments(['Lectura ', '1', ': ', '27', ' grados', '\n']),
      );

      expect(lines, ['Lectura 1: 27 grados']);
    });

    test('keeps one entry per emitted line', () {
      final lines = _lines.of(_fragments(['uno', '\n', 'dos', '\n']));

      expect(lines, ['uno', 'dos']);
    });

    test('preserves a blank line between two written lines', () {
      final lines = _lines.of(_fragments(['uno', '\n', '\n', 'dos', '\n']));

      expect(lines, ['uno', '', 'dos']);
    });

    test('keeps a line that was never closed with a newline', () {
      final lines = _lines.of(_fragments(['sin salto']));

      expect(lines, ['sin salto']);
    });

    test('an empty execution produces no lines', () {
      expect(_lines.of(const []), isEmpty);
    });

    test('fragments that are only newlines produce no lines', () {
      expect(_lines.of(_fragments(['\n', '\n'])), isEmpty);
    });
  });
}
