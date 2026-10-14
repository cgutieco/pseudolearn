import 'dart:io';

import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

import '../../tool/check.dart' as verifier;

void main() {
  final rules =
      loadYaml(File('architecture.yaml').readAsStringSync()) as YamlMap;
  test('accepts empty source', () {
    expect(verifier.inspect('', 'lib/src/model/empty.dart', rules), isEmpty);
  });
  test('rejects deliberate comment', () {
    expect(
      verifier.inspect('// forbidden', 'lib/src/model/empty.dart', rules),
      contains(contains('QUALITY-NO-COMMENTS')),
    );
  });
  test('rejects outward dependency', () {
    expect(
      verifier.inspect(
        "import '../execution/analyze.dart';",
        'lib/src/model/empty.dart',
        rules,
      ),
      contains(contains('LAYER-DIRECTION')),
    );
  });
  test('rejects excessive file length', () {
    expect(
      verifier.inspect('\n' * 301, 'lib/src/model/empty.dart', rules),
      contains(contains('SIZE-FILE')),
    );
  });
  test('rejects unregistered layer', () {
    expect(
      verifier.inspect('', 'lib/src/unknown/empty.dart', rules),
      contains(contains('LAYER-DECLARED')),
    );
  });
}
