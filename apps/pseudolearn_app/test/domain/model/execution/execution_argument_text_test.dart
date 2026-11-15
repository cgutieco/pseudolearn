import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_argument_text.dart';

void main() {
  test(
    'empty input has no arguments and explicit quotes preserve empty values',
    () {
      expect(ExecutionArgumentText.parse(''), isEmpty);
      expect(ExecutionArgumentText.parse('"" plain "two words" λ'), [
        '',
        'plain',
        'two words',
        'λ',
      ]);
    },
  );

  test('format and parse preserve paths quotes and Unicode', () {
    const values = [
      '',
      r'C:\work\datos.txt',
      'a "quoted" word',
      'ñ 🌍',
      r'back\',
    ];
    expect(
      ExecutionArgumentText.parse(ExecutionArgumentText.format(values)),
      values,
    );
    expect(ExecutionArgumentText.parse(r'C:\work\datos.txt'), [
      r'C:\work\datos.txt',
    ]);
  });

  test('unclosed quotes are rejected without replacing saved arguments', () {
    expect(ExecutionArgumentText.parse('"unfinished'), isNull);
    expect(ExecutionArgumentText.parse("'unfinished"), isNull);
  });
}
