import '../../export/target_code_builder.dart';

/// Rust reading of a `Leer` target. Like the engine, an invalid value is
/// asked for again instead of stopping the program.
String rustReadCall(String primitive) => switch (primitive) {
  'integer' => 'read_integer()',
  _ => throw StateError('no Rust reading for $primitive'),
};

void writeRustReadHelpers(Set<String> primitives, TargetCodeBuilder buffer) {
  if (!primitives.contains('integer')) return;
  buffer.writeln('fn read_integer() -> i64 {');
  buffer.writeln('    loop {');
  buffer.writeln('        let mut line = String::new();');
  buffer.writeln(
    '        if std::io::stdin().read_line(&mut line).expect("stdin") == 0 {',
  );
  buffer.writeln('            panic!("no more input");');
  buffer.writeln('        }');
  buffer.writeln('        if let Ok(value) = line.trim().parse::<i64>() {');
  buffer.writeln('            return value;');
  buffer.writeln('        }');
  buffer.writeln('    }');
  buffer.writeln('}');
  buffer.writeln();
}
