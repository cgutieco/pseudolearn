import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

Set<String> _dependencyRoots(Map<String, Object?> metadata) {
  final packages = (metadata['packages'] as List<Object?>)
      .cast<Map<String, Object?>>();
  final resolution = metadata['resolve'] as Map<String, Object?>;
  final nodes = (resolution['nodes'] as List<Object?>)
      .cast<Map<String, Object?>>();
  final pending = <String>[resolution['root'] as String];
  final visited = <String>{};
  while (pending.isNotEmpty) {
    final identifier = pending.removeLast();
    if (!visited.add(identifier)) continue;
    final node = nodes.singleWhere((node) => node['id'] == identifier);
    for (final dependency
        in (node['deps'] as List<Object?>).cast<Map<String, Object?>>()) {
      final kinds = (dependency['dep_kinds'] as List<Object?>)
          .cast<Map<String, Object?>>();
      if (kinds.any((kind) => kind['kind'] != 'dev')) {
        pending.add(dependency['pkg'] as String);
      }
    }
  }
  return {
    for (final package in packages)
      if (visited.contains(package['id']) && package['source'] == null)
        path.dirname(package['manifest_path'] as String),
  };
}

Set<String> _embeddedRoots() {
  final result = Process.runSync('cargo', [
    'metadata',
    '--locked',
    '--offline',
    '--format-version',
    '1',
    '--manifest-path',
    'native/Cargo.toml',
  ]);
  if (result.exitCode != 0) throw StateError('${result.stderr}');
  return _dependencyRoots(
    jsonDecode(result.stdout as String) as Map<String, Object?>,
  );
}

DateTime _newestSource() {
  var newest = DateTime.fromMillisecondsSinceEpoch(0);
  for (final root in _embeddedRoots()) {
    for (final entity in Directory('$root/src').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.rs')) continue;
      if (entity.path.endsWith('_tests.rs')) continue;
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
  test(
    'the release bridge library is newer than every Rust source it embeds',
    () {
      final library = _library();
      expect(
        library,
        isNotNull,
        reason: 'build the release bridge library first',
      );
      expect(
        library!.lastModifiedSync().isBefore(_newestSource()),
        isFalse,
        reason:
            'rebuild with cargo build --release --locked --lib --manifest-path native/Cargo.toml',
      );
    },
  );

  test('dependency traversal excludes tools and dev dependencies', () {
    final metadata = <String, Object?>{
      'packages': [
        for (final name in ['bridge', 'api', 'worker', 'fixture'])
          {'id': name, 'source': null, 'manifest_path': '/$name/Cargo.toml'},
      ],
      'resolve': {
        'root': 'bridge',
        'nodes': [
          {
            'id': 'bridge',
            'deps': [
              {
                'pkg': 'api',
                'dep_kinds': [
                  {'kind': null},
                ],
              },
              {
                'pkg': 'fixture',
                'dep_kinds': [
                  {'kind': 'dev'},
                ],
              },
            ],
          },
          for (final name in ['api', 'worker', 'fixture'])
            {'id': name, 'deps': <Object?>[]},
        ],
      },
    };
    expect(_dependencyRoots(metadata), {'/bridge', '/api'});
    (metadata['resolve'] as Map<String, Object?>)['root'] = 'worker';
    expect(_dependencyRoots(metadata), {'/worker'});
  });
}
