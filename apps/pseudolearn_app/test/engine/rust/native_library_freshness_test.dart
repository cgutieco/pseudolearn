import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const List<String> _sourceRoots = [
  'native/src',
  '../../packages/pseudolearn_engine/crates',
];

DateTime _newestSource() {
  var newest = DateTime.fromMillisecondsSinceEpoch(0);
  for (final root in _sourceRoots) {
    for (final entity in Directory(root).listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.rs')) continue;
      if (entity.path.contains('/target/') || entity.path.contains('/tests/')) {
        continue;
      }
      final modified = entity.lastModifiedSync();
      if (modified.isAfter(newest)) newest = modified;
    }
  }
  return newest;
}

File? _library() {
  for (final name in [
    'libpseudolearn_bridge.dylib',
    'libpseudolearn_bridge.so',
    'pseudolearn_bridge.dll',
  ]) {
    final file = File('native/target/release/$name');
    if (file.existsSync()) return file;
  }
  return null;
}

void main() {
  test('the release bridge library is newer than every Rust source it embeds', () {
    final library = _library();

    expect(library, isNotNull, reason: 'build the release bridge library first');
    expect(
      library!.lastModifiedSync().isBefore(_newestSource()),
      isFalse,
      reason: 'rebuild with cargo build --release --locked --lib --manifest-path native/Cargo.toml',
    );
  });
}
