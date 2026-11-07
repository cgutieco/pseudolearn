import '../../export/target_code_builder.dart';

/// Helper functions a Rust translation calls to keep the engine semantics:
/// reads that ask again on an invalid value, reals printed with at least one
/// decimal and a division that stops on a zero divisor. Each one is written
/// once, after `main`, and only when the program uses it.
final class RustHelpers {
  final Set<String> _used = {};

  String read(String primitive) => switch (primitive) {
    'integer' => _use('read_integer()'),
    'real' => _use('read_real()'),
    _ => throw StateError('no Rust reading for $primitive'),
  };

  String realText(String value) => '${_use('real_text')}($value)';

  String divide(String left, String right) =>
      '${_use('divide')}($left, $right)';

  String _use(String call) {
    _used.add(call.split('(').first);
    return call;
  }

  void writeTo(TargetCodeBuilder buffer) {
    for (final name in _order) {
      if (!_used.contains(name)) continue;
      buffer.writeln();
      for (final line in _bodies[name]!) {
        buffer.writeln(line);
      }
    }
  }
}

const List<String> _order = [
  'read_integer',
  'read_real',
  'real_text',
  'divide',
];

List<String> _reader(String name, String type) => [
  'fn $name() -> $type {',
  '    loop {',
  '        let mut line = String::new();',
  '        if std::io::stdin().read_line(&mut line).expect("stdin") == 0 {',
  '            panic!("no more input");',
  '        }',
  '        if let Ok(value) = line.trim().parse::<$type>() {',
  '            return value;',
  '        }',
  '    }',
  '}',
];

final Map<String, List<String>> _bodies = {
  'read_integer': _reader('read_integer', 'i64'),
  'read_real': _reader('read_real', 'f64'),
  'real_text': [
    'fn real_text(value: f64) -> String {',
    '    let text = format!("{}", value);',
    '    if text.contains(\'.\') || !value.is_finite() {',
    '        text',
    '    } else {',
    '        format!("{}.0", text)',
    '    }',
    '}',
  ],
  'divide': [
    'fn divide(dividend: f64, divisor: f64) -> f64 {',
    '    if divisor == 0.0 {',
    '        panic!("division by zero");',
    '    }',
    '    dividend / divisor',
    '}',
  ],
};
