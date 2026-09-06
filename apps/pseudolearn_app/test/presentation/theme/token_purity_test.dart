import 'dart:io';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

final class TokenPurityViolation {
  final String filePath;
  final int offset;
  final String rule;
  final String message;

  const TokenPurityViolation({
    required this.filePath,
    required this.offset,
    required this.rule,
    required this.message,
  });

  @override
  String toString() => '$filePath:$offset [$rule] $message';
}

final class _TokenPurityVisitor extends RecursiveAstVisitor<void> {
  final String filePath;
  final String relativeToLib;
  final List<String> colorOwnerPaths;
  final List<String> durationOwnerPaths;
  final List<TokenPurityViolation> violations;

  _TokenPurityVisitor({
    required this.filePath,
    required this.relativeToLib,
    required this.colorOwnerPaths,
    required this.durationOwnerPaths,
    required this.violations,
  });

  bool _isOwnedBy(List<String> owners) {
    final normalized = relativeToLib.replaceAll(r'\\', '/');
    for (final owner in owners) {
      if (normalized == owner || normalized.startsWith(owner)) return true;
    }
    return false;
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final typeName = node.constructorName.type.name.lexeme;

    if (typeName == 'Color') {
      if (!_isOwnedBy(colorOwnerPaths)) {
        violations.add(
          TokenPurityViolation(
            filePath: filePath,
            offset: node.offset,
            rule: 'color_literal_outside_primitives',
            message: 'Color(...) literal outside its declared owner is forbidden',
          ),
        );
      }
    }

    if (typeName == 'Duration') {
      if (!_isOwnedBy(durationOwnerPaths)) {
        violations.add(
          TokenPurityViolation(
            filePath: filePath,
            offset: node.offset,
            rule: 'duration_outside_motion',
            message: 'Duration(...) literal outside its declared owner is forbidden',
          ),
        );
      }
    }

    super.visitInstanceCreationExpression(node);
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (node.name == 'Colors') {
      violations.add(
        TokenPurityViolation(
          filePath: filePath,
          offset: node.offset,
          rule: 'material_colors_identifier',
          message: 'Usage of Flutter Material "Colors" identifier is forbidden',
        ),
      );
    }
    super.visitSimpleIdentifier(node);
  }
}

List<String> _ownerPaths(YamlMap yaml, String key) {
  return (yaml[key] as YamlList?)?.map((entry) => entry.toString()).toList() ?? const <String>[];
}

List<TokenPurityViolation> validateTokenPurity({
  required String packageRoot,
  String? customLibRoot,
}) {
  final yaml = loadYaml(File(p.join(packageRoot, 'architecture.yaml')).readAsStringSync()) as YamlMap;
  final colorOwnerPaths = _ownerPaths(yaml, 'color_literal_owner_paths');
  final durationOwnerPaths = _ownerPaths(yaml, 'duration_literal_owner_paths');

  final targetDir = Directory(
    customLibRoot ?? p.join(packageRoot, 'lib'),
  );

  final violations = <TokenPurityViolation>[];
  if (!targetDir.existsSync()) return violations;

  for (final entity in targetDir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final relativeToLib = customLibRoot != null
          ? p.relative(entity.path, from: customLibRoot)
          : p.relative(entity.path, from: p.join(packageRoot, 'lib'));

      final content = entity.readAsStringSync();
      final parsed = parseString(content: content, throwIfDiagnostics: false);

      final visitor = _TokenPurityVisitor(
        filePath: p.relative(entity.path, from: packageRoot),
        relativeToLib: relativeToLib,
        colorOwnerPaths: colorOwnerPaths,
        durationOwnerPaths: durationOwnerPaths,
        violations: violations,
      );

      parsed.unit.accept(visitor);
    }
  }

  return violations;
}

void main() {
  group('Token Purity Verifications (RFC 001 §13.3)', () {
    final packageRoot = Directory.current.path;

    test('Source code in lib/ satisfies all token purity invariants', () {
      final violations = validateTokenPurity(packageRoot: packageRoot);
      expect(
        violations,
        isEmpty,
        reason: violations.map((v) => v.toString()).join('\n'),
      );
    });

    test('Negative fixture: Color literal in widget fails check', () {
      final fixtureDir = p.join(
        packageRoot,
        'test',
        'architecture',
        'fixtures',
        'presentation_with_color_literal',
      );
      final violations = validateTokenPurity(
        packageRoot: packageRoot,
        customLibRoot: fixtureDir,
      );
      expect(
        violations.any((v) => v.rule == 'color_literal_outside_primitives'),
        isTrue,
      );
    });

    test('Negative fixture: Duration literal outside tokens fails check', () {
      final fixtureDir = p.join(
        packageRoot,
        'test',
        'architecture',
        'fixtures',
        'presentation_with_duration_literal',
      );
      final violations = validateTokenPurity(
        packageRoot: packageRoot,
        customLibRoot: fixtureDir,
      );
      expect(
        violations.any((v) => v.rule == 'duration_outside_motion'),
        isTrue,
      );
    });

    test('Negative fixture: Material Colors identifier in lib fails check', () {
      final fixtureDir = p.join(
        packageRoot,
        'test',
        'architecture',
        'fixtures',
        'presentation_with_material_colors',
      );
      final violations = validateTokenPurity(
        packageRoot: packageRoot,
        customLibRoot: fixtureDir,
      );
      expect(
        violations.any((v) => v.rule == 'material_colors_identifier'),
        isTrue,
      );
    });
  });
}
