import 'dart:io';

const String _apiSourcePath =
    '../../packages/pseudolearn_engine/crates/pseudolearn_api/src';

const List<String> _inventoryFiles = [
  'program_view_kind.rs',
  'program_view_tasks.rs',
];

Map<String, String> readEngineInventory({String? sourceDirectory}) {
  final directory = sourceDirectory ?? _apiSourcePath;
  final sources = [
    for (final name in _inventoryFiles)
      File('$directory/$name').readAsStringSync(),
  ];
  return inventoryOf(sources);
}

Map<String, String> inventoryOf(List<String> sources) {
  final names = <String, String>{};
  for (final source in sources) {
    for (final match in RegExp(
      r'NodeKind::(\w+)\s*=>\s*"(\w+)"',
    ).allMatches(source)) {
      names[match.group(1)!] = match.group(2)!;
    }
  }
  final roles = <String, String>{};
  for (final source in sources) {
    _collectRoles(source, roles);
  }
  return {
    for (final entry in names.entries)
      if (roles.containsKey(entry.key)) entry.value: roles[entry.key]!,
  };
}

void _collectRoles(String source, Map<String, String> roles) {
  for (final entry in _functionRoles.entries) {
    final body = _functionBody(source, entry.key);
    if (body == null) continue;
    for (final match in RegExp(r'NodeKind::(\w+)').allMatches(body)) {
      roles.putIfAbsent(match.group(1)!, () => entry.value);
    }
  }
  roles.putIfAbsent('Identifier', () => 'symbol');
  for (final match in RegExp(
    r'((?:\s*\|?\s*NodeKind::\w+)+)\s*=>\s*\{?\s*Some\(ViewKind::(\w+)\)',
  ).allMatches(source)) {
    final role = match.group(2)!.toLowerCase();
    for (final kind in RegExp(r'NodeKind::(\w+)').allMatches(match.group(1)!)) {
      roles.putIfAbsent(kind.group(1)!, () => role);
    }
  }
}

const Map<String, String> _functionRoles = {
  'is_declaration': 'declaration',
  'is_expression': 'expression',
};

String? _functionBody(String source, String name) {
  final start = source.indexOf('fn $name(');
  if (start < 0) return null;
  final end = source.indexOf('\n}\n', start);
  return end < 0 ? source.substring(start) : source.substring(start, end);
}
