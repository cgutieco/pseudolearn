import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

final RegExp _import = RegExp(r'''(?:import|export|part)\s+['"]([^'"]+)['"]''');

File? _resolve(File from, String target) {
  if (target.startsWith('package:pseudolearn_app/')) {
    return File('lib/${target.substring('package:pseudolearn_app/'.length)}');
  }
  if (target.startsWith('package:') || target.startsWith('dart:')) return null;
  return File(from.parent.uri.resolve(target).toFilePath());
}

Set<String> _closure(String entry) {
  final visited = <String>{};
  final pending = [File(entry)];
  while (pending.isNotEmpty) {
    final file = pending.removeLast();
    if (!visited.add(file.path) || !file.existsSync()) continue;
    for (final match in _import.allMatches(file.readAsStringSync())) {
      final next = _resolve(file, match.group(1)!);
      if (next != null) pending.add(next);
    }
  }
  return visited;
}

void main() {
  test('the Rust engine set reaches no file that imports the Dart core', () {
    final offenders = [
      for (final path in _closure('lib/composition/rust_engine_services.dart'))
        if (File(path).existsSync() &&
            File(path).readAsStringSync().contains('package:pseudolearn_core'))
          path,
    ];

    expect(offenders, isEmpty);
  });

  test('domain and application files import neither transport', () {
    for (final directory in ['lib/domain', 'lib/application']) {
      for (final file in Directory(
        directory,
      ).listSync(recursive: true).whereType<File>()) {
        final text = file.readAsStringSync();
        expect(text.contains('engine/rust/'), isFalse, reason: file.path);
        expect(text.contains('engine/bridge/'), isFalse, reason: file.path);
        expect(
          text.contains('package:pseudolearn_core'),
          isFalse,
          reason: file.path,
        );
      }
    }
  });
}
