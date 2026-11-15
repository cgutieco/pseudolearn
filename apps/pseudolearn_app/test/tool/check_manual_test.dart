import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import '../../tool/check_manual.dart';

Directory _workspace() => Directory.systemTemp.createTempSync('manual_check_');

void _source(Directory root, String code) {
  final file = File(p.join(root.path, 'lib', 'feature.dart'))..createSync(recursive: true);
  file.writeAsStringSync(code);
}

void _manual(Directory root, String language, List<Map<String, Object?>> entries) {
  final file = File(p.join(root.path, 'manual', language, 'manual.json'))
    ..createSync(recursive: true);
  file.writeAsStringSync(jsonEncode({'format': 'manual/1', 'entries': entries}));
}

Map<String, Object?> _entry(String id) => {
  'id': id,
  'anchor': 'feature:$id',
  'route': '/x',
  'title': 'T',
  'body': 'B',
  'keywords': <String>[],
};

List<String> _rules(Directory root) => [
  for (final violation in validateManual(
    sourceRoot: Directory(p.join(root.path, 'lib')),
    manualRoot: Directory(p.join(root.path, 'manual')),
  ))
    violation.rule,
];

void main() {
  test('the real manual documents every feature in both languages', () {
    final violations = validateManual(
      sourceRoot: Directory('lib'),
      manualRoot: Directory('assets/manual'),
    );
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('a matching manual passes', () {
    final root = _workspace();
    _source(root, "final key = ValueKey('feature:alpha');");
    _manual(root, 'es', [_entry('alpha')]);
    _manual(root, 'en', [_entry('alpha')]);
    expect(_rules(root), isEmpty);
  });

  test('an entry without a widget is an orphan', () {
    final root = _workspace();
    _source(root, "final key = ValueKey('feature:alpha');");
    _manual(root, 'es', [_entry('alpha'), _entry('ghost')]);
    _manual(root, 'en', [_entry('alpha')]);
    expect(_rules(root), ['MANUAL-ORPHAN']);
  });

  test('a feature without an entry is undocumented in each language', () {
    final root = _workspace();
    _source(root, "final a = ValueKey('feature:alpha'); final b = ValueKey('feature:beta');");
    _manual(root, 'es', [_entry('alpha')]);
    _manual(root, 'en', [_entry('alpha')]);
    expect(_rules(root), ['MANUAL-UNDOCUMENTED', 'MANUAL-UNDOCUMENTED']);
  });

  test('duplicates, wrong anchors, empty fields and missing files are reported', () {
    final root = _workspace();
    _source(root, "final key = ValueKey('feature:alpha');");
    _manual(root, 'es', [
      _entry('alpha'),
      _entry('alpha'),
      {..._entry('alpha'), 'id': 'alpha2', 'anchor': 'feature:other', 'body': ''},
    ]);
    expect(
      _rules(root),
      containsAll(['MANUAL-DUPLICATE', 'MANUAL-ANCHOR', 'MANUAL-FIELD', 'MANUAL-MISSING']),
    );
  });

  test('a malformed file and an empty source tree are handled', () {
    final root = _workspace();
    Directory(p.join(root.path, 'lib')).createSync();
    File(p.join(root.path, 'manual', 'es', 'manual.json'))
      ..createSync(recursive: true)
      ..writeAsStringSync('{');
    _manual(root, 'en', const []);
    expect(_rules(root), ['MANUAL-FORMAT']);
  });
}
