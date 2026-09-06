import 'dart:io';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_test/flutter_test.dart';

final class StateImmutabilityViolation {
  final String filePath;
  final int line;
  final String message;

  const StateImmutabilityViolation({
    required this.filePath,
    required this.line,
    required this.message,
  });

  @override
  String toString() => '$filePath:$line [state_immutability] $message';
}

final class _StateImmutabilityVisitor extends RecursiveAstVisitor<void> {
  final String filePath;
  final List<StateImmutabilityViolation> violations;

  _StateImmutabilityVisitor({
    required this.filePath,
    required this.violations,
  });

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    if (!node.isStatic && !node.fields.isFinal && !node.fields.isConst) {
      for (final variable in node.fields.variables) {
        violations.add(
          StateImmutabilityViolation(
            filePath: filePath,
            line: node.offset,
            message:
                'Field "${variable.name.lexeme}" in state class is not final',
          ),
        );
      }
    }
    super.visitFieldDeclaration(node);
  }
}

List<StateImmutabilityViolation> validateStateImmutability({
  required String packageRoot,
  String? customApplicationRoot,
}) {
  final targetDir = Directory(
    customApplicationRoot ?? p.join(packageRoot, 'lib', 'application'),
  );

  final violations = <StateImmutabilityViolation>[];
  if (!targetDir.existsSync()) return violations;

  for (final entity in targetDir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('_state.dart')) {
      final content = entity.readAsStringSync();
      final parsed = parseString(content: content, throwIfDiagnostics: false);

      final visitor = _StateImmutabilityVisitor(
        filePath: p.relative(entity.path, from: packageRoot),
        violations: violations,
      );

      parsed.unit.accept(visitor);
    }
  }

  return violations;
}

void main() {
  group('State Immutability Rules', () {
    final packageRoot = Directory.current.path;

    test('All application state fields are final', () {
      final violations = validateStateImmutability(packageRoot: packageRoot);
      expect(
        violations,
        isEmpty,
        reason: violations.map((v) => v.toString()).join('\n'),
      );
    });

    test('Negative fixture: non-final state field fails check', () {
      final fixtureDir = p.join(
        packageRoot,
        'test',
        'architecture',
        'fixtures',
        'mutable_state',
      );
      final violations = validateStateImmutability(
        packageRoot: packageRoot,
        customApplicationRoot: fixtureDir,
      );
      expect(violations, isNotEmpty);
    });
  });
}
