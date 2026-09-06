import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

const String _stateTableHeading = '## Estado por sección';
const String _notProjected = 'No se proyecta';
const String _pending = 'pendiente';

final class _SpecRow {
  final String section;
  final String projection;

  const _SpecRow({required this.section, required this.projection});

  String? get declaredId {
    final open = projection.indexOf('`');
    if (open < 0) return null;
    final close = projection.indexOf('`', open + 1);
    if (close < 0) return null;
    return projection.substring(open + 1, close);
  }

  bool get isProjected => !projection.contains(_notProjected);

  bool get isPending => projection.contains(_pending);
}

List<_SpecRow> _readStateTable() {
  final file = File(p.join(
    Directory.current.path,
    '..',
    '..',
    'packages',
    'pseudolearn_core',
    'docs',
    'language-spec.md',
  ));
  final lines = file.readAsLinesSync();
  final rows = <_SpecRow>[];
  var insideTable = false;
  for (final line in lines) {
    if (line.startsWith(_stateTableHeading)) {
      insideTable = true;
      continue;
    }
    if (!insideTable) continue;
    if (!line.startsWith('|')) {
      if (rows.isNotEmpty) break;
      continue;
    }
    final cells = line.split('|').map((cell) => cell.trim()).toList();
    if (cells.length < 5) continue;
    if (cells[1].startsWith('---') || cells[1] == 'Sección') continue;
    rows.add(_SpecRow(section: cells[1], projection: cells[3]));
  }
  return rows;
}

Set<String> _publishedSectionIds() {
  final ids = <String>{};
  final directory = Directory(p.join(Directory.current.path, 'assets', 'knowledge'));
  for (final file in directory.listSync().whereType<File>()) {
    final name = p.basename(file.path);
    if (!name.startsWith('manifest_') || !name.endsWith('.json')) continue;
    final manifest = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final sections = manifest['specification'];
    if (sections is! List) continue;
    for (final raw in sections) {
      if (raw is Map<String, dynamic>) ids.add(raw['id'] as String);
    }
  }
  return ids;
}

void main() {
  group('Specification coverage', () {
    test('the state table declares a projection for every normative section', () {
      final rows = _readStateTable();

      expect(rows, isNotEmpty);
      for (final row in rows) {
        expect(
          row.projection,
          isNotEmpty,
          reason: 'Section "${row.section}" declares no projection',
        );
      }
    });

    test('a projected section names the published section it projects into', () {
      for (final row in _readStateTable()) {
        if (!row.isProjected) continue;
        expect(
          row.declaredId,
          isNotNull,
          reason: 'Section "${row.section}" does not name its published section',
        );
      }
    });

    test('every section projected and not pending exists in the published content', () {
      final published = _publishedSectionIds();

      for (final row in _readStateTable()) {
        if (!row.isProjected || row.isPending) continue;
        expect(
          published,
          contains(row.declaredId),
          reason: 'Section "${row.section}" claims to be projected into '
              '"${row.declaredId}", which no manifest declares',
        );
      }
    });

    test('every published section is declared by the state table', () {
      final declared = <String>{};
      for (final row in _readStateTable()) {
        final id = row.declaredId;
        if (id != null) declared.add(id);
      }

      for (final id in _publishedSectionIds()) {
        expect(
          declared,
          contains(id),
          reason: 'Published section "$id" is not declared in the state table',
        );
      }
    });
  });
}
