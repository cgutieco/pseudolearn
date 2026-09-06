import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

final class ArbDifference {
  final String key;
  final String message;

  const ArbDifference(this.key, this.message);

  @override
  String toString() => '$key: $message';
}

List<String> extractPlaceholders(String text) {
  final placeholders = <String>{};
  final placeholderRegex = RegExp(r'\{([a-zA-Z0-9_]+)(?:,[^}]*)?\}');

  for (final match in placeholderRegex.allMatches(text)) {
    final name = match.group(1);
    if (name != null && name.isNotEmpty) {
      placeholders.add(name);
    }
  }

  final sorted = placeholders.toList()..sort();
  return sorted;
}

List<ArbDifference> compareArbMaps(
  Map<String, dynamic> source,
  Map<String, dynamic> target, {
  required String sourceName,
  required String targetName,
}) {
  final differences = <ArbDifference>[];
  final sourceKeys = source.keys.where((k) => !k.startsWith('@')).toSet();
  final targetKeys = target.keys.where((k) => !k.startsWith('@')).toSet();

  for (final key in sourceKeys) {
    if (!targetKeys.contains(key)) {
      differences.add(
        ArbDifference(
          key,
          'Key exists in $sourceName but is missing from $targetName',
        ),
      );
      continue;
    }

    final sourceVal = source[key];
    final targetVal = target[key];
    if (sourceVal is String && targetVal is String) {
      final sourcePlaceholders = extractPlaceholders(sourceVal);
      final targetPlaceholders = extractPlaceholders(targetVal);

      if (sourcePlaceholders.join(',') != targetPlaceholders.join(',')) {
        differences.add(
          ArbDifference(
            key,
            'Placeholders mismatch between $sourceName ($sourcePlaceholders) and $targetName ($targetPlaceholders)',
          ),
        );
      }
    }
  }

  for (final key in targetKeys) {
    if (!sourceKeys.contains(key)) {
      differences.add(
        ArbDifference(
          key,
          'Key exists in $targetName but is missing from $sourceName',
        ),
      );
    }
  }

  return differences;
}

void main() {
  group('ARB Completeness and Parity Checks (CIM-F3)', () {
    final packageRoot = Directory.current.path;

    test('app_es.arb and app_en.arb have exact key and placeholder parity', () {
      final esFile = File(p.join(packageRoot, 'lib', 'presentation', 'l10n', 'app_es.arb'));
      final enFile = File(p.join(packageRoot, 'lib', 'presentation', 'l10n', 'app_en.arb'));

      expect(esFile.existsSync(), isTrue);
      expect(enFile.existsSync(), isTrue);

      final esMap = jsonDecode(esFile.readAsStringSync()) as Map<String, dynamic>;
      final enMap = jsonDecode(enFile.readAsStringSync()) as Map<String, dynamic>;

      final differences = compareArbMaps(
        esMap,
        enMap,
        sourceName: 'app_es.arb',
        targetName: 'app_en.arb',
      );

      expect(
        differences,
        isEmpty,
        reason: differences.map((d) => d.toString()).join('\n'),
      );
    });

    test('Negative fixture: missing key is detected', () {
      final mapA = <String, dynamic>{'hello': 'Hola', 'onlyA': 'Solo A'};
      final mapB = <String, dynamic>{'hello': 'Hello'};

      final diffs = compareArbMaps(mapA, mapB, sourceName: 'mapA', targetName: 'mapB');
      expect(diffs.any((d) => d.key == 'onlyA'), isTrue);
    });

    test('Negative fixture: placeholder mismatch is detected', () {
      final mapA = <String, dynamic>{'greet': 'Hola {name} en {place}'};
      final mapB = <String, dynamic>{'greet': 'Hello {name}'};

      final diffs = compareArbMaps(mapA, mapB, sourceName: 'mapA', targetName: 'mapB');
      expect(diffs.any((d) => d.key == 'greet'), isTrue);
    });
  });
}
