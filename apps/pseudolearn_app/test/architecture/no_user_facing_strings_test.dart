import 'dart:io';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

const List<String> _suspiciousWords = [
  'guardar',
  'cancelar',
  'eliminar',
  'nuevo documento',
  'configuración',
  'ejecutar',
  'detener',
  'error al',
  'sin documentos',
  'bienvenido',
  'ajustes',
  'biblioteca',
  'conocimiento',
  'expandir',
  'contraer',
];

const String _spanishOrthography = 'áéíóúüñÁÉÍÓÚÜÑ¿¡';

final class _UserFacingStringVisitor extends RecursiveAstVisitor<void> {
  final String filePath;
  final List<String> violations;

  _UserFacingStringVisitor({
    required this.filePath,
    required this.violations,
  });

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    if (!node.value.startsWith('/') && _isUserFacing(node.value)) {
      violations.add(
          '$filePath: Found suspicious user-facing string "${node.value}"');
    }
    super.visitSimpleStringLiteral(node);
  }

  bool _isUserFacing(String value) {
    for (final mark in _spanishOrthography.split('')) {
      if (value.contains(mark)) return true;
    }
    final lowered = value.toLowerCase();
    for (final word in _suspiciousWords) {
      if (lowered.contains(word)) return true;
    }
    return false;
  }
}

List<String> exemptPathsOf(String packageRoot) {
  final file = File(p.join(packageRoot, 'architecture.yaml'));
  if (!file.existsSync()) return const [];
  final yaml = loadYaml(file.readAsStringSync()) as YamlMap;
  final declared = yaml['user_facing_strings_exempt'] as YamlList?;
  return declared?.map((entry) => entry.toString()).toList() ?? const [];
}

List<String> validateNoUserFacingStrings({
  required String packageRoot,
  String? customSourceRoot,
  List<String>? exemptPaths,
}) {
  final exempt = exemptPaths ?? exemptPathsOf(packageRoot);
  final violations = <String>[];
  final sourceDir = Directory(customSourceRoot ?? p.join(packageRoot, 'lib'));
  if (!sourceDir.existsSync()) return violations;

  for (final entity in sourceDir.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final relativePath = p.relative(entity.path, from: packageRoot);
    if (_isExempt(relativePath, exempt)) continue;
    final parsed = parseString(
      content: entity.readAsStringSync(),
      throwIfDiagnostics: false,
    );
    parsed.unit.accept(
      _UserFacingStringVisitor(filePath: relativePath, violations: violations),
    );
  }

  return violations;
}

bool _isExempt(String relativePath, List<String> exemptPaths) {
  final normalized = relativePath.replaceAll(r'\', '/');
  for (final exempt in exemptPaths) {
    if (normalized.startsWith(exempt)) return true;
  }
  return false;
}

void main() {
  group('No User-Facing Strings Outside Their Owning Layer', () {
    final packageRoot = Directory.current.path;

    test('Source code contains no user-facing strings outside l10n', () {
      final violations = validateNoUserFacingStrings(packageRoot: packageRoot);
      expect(violations, isEmpty, reason: violations.join('\n'));
    });

    test('The exempt list is declared in architecture.yaml, not in this test',
        () {
      expect(exemptPathsOf(packageRoot), isNotEmpty);
    });

    test('Negative fixture: widget with raw Spanish text fails check', () {
      final fixtureDir = p.join(
        packageRoot,
        'test',
        'architecture',
        'fixtures',
        'presentation_with_raw_string',
      );
      final violations = validateNoUserFacingStrings(
        packageRoot: packageRoot,
        customSourceRoot: fixtureDir,
        exemptPaths: const [],
      );
      expect(violations, isNotEmpty);
    });

    test('Negative fixture: Spanish orthography in a literal fails check', () {
      final fixtureDir = p.join(
        packageRoot,
        'test',
        'architecture',
        'fixtures',
        'engine_with_spanish_orthography',
      );
      final violations = validateNoUserFacingStrings(
        packageRoot: packageRoot,
        customSourceRoot: fixtureDir,
        exemptPaths: const [],
      );
      expect(violations, isNotEmpty);
    });

    test('A file listed as exempt is not reported', () {
      final fixtureDir = p.join(
        packageRoot,
        'test',
        'architecture',
        'fixtures',
        'engine_with_spanish_orthography',
      );
      final violations = validateNoUserFacingStrings(
        packageRoot: packageRoot,
        customSourceRoot: fixtureDir,
        exemptPaths: const ['test/architecture/fixtures/'],
      );
      expect(violations, isEmpty);
    });
  });
}
