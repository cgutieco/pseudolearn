import '../../export/target_code_builder.dart';

/// Python reading of a `Leer` target. Like the engine, an invalid value is
/// asked for again instead of stopping the program.
String pythonReadCall(String primitive) => switch (primitive) {
  'integer' => 'read_integer()',
  'real' => 'read_real()',
  _ => 'input()',
};

const Map<String, (String, String)> _helpers = {
  'integer': ('read_integer', 'int'),
  'real': ('read_real', 'float'),
};

void writePythonReadHelpers(Set<String> primitives, TargetCodeBuilder buffer) {
  for (final MapEntry(key: primitive, value: (name, conversion))
      in _helpers.entries) {
    if (!primitives.contains(primitive)) continue;
    buffer.writeln('def $name():');
    buffer.writeln('    while True:');
    buffer.writeln('        try:');
    buffer.writeln('            return $conversion(input())');
    buffer.writeln('        except ValueError:');
    buffer.writeln('            pass');
    buffer.writeln();
  }
}
