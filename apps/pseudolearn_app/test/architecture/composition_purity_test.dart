import 'dart:io';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_test/flutter_test.dart';

final class CompositionPurityViolation {
  final String filePath;
  final int line;
  final String rule;
  final String message;

  const CompositionPurityViolation({
    required this.filePath,
    required this.line,
    required this.rule,
    required this.message,
  });

  @override
  String toString() => '$filePath:$line [$rule] $message';
}

final class _CompositionPurityVisitor extends RecursiveAstVisitor<void> {
  final String filePath;
  final List<CompositionPurityViolation> violations;

  _CompositionPurityVisitor({
    required this.filePath,
    required this.violations,
  });

  @override
  void visitIfStatement(IfStatement node) {
    violations.add(
      CompositionPurityViolation(
        filePath: filePath,
        line: node.offset,
        rule: 'forbid_conditionals',
        message: 'If statement in composition layer is forbidden',
      ),
    );
    super.visitIfStatement(node);
  }

  @override
  void visitIfElement(IfElement node) {
    violations.add(
      CompositionPurityViolation(
        filePath: filePath,
        line: node.offset,
        rule: 'forbid_conditionals',
        message: 'If element in composition layer is forbidden',
      ),
    );
    super.visitIfElement(node);
  }

  @override
  void visitConditionalExpression(ConditionalExpression node) {
    violations.add(
      CompositionPurityViolation(
        filePath: filePath,
        line: node.offset,
        rule: 'forbid_conditionals',
        message: 'Ternary conditional expression in composition layer is forbidden',
      ),
    );
    super.visitConditionalExpression(node);
  }

  @override
  void visitSwitchStatement(SwitchStatement node) {
    violations.add(
      CompositionPurityViolation(
        filePath: filePath,
        line: node.offset,
        rule: 'forbid_conditionals',
        message: 'Switch statement in composition layer is forbidden',
      ),
    );
    super.visitSwitchStatement(node);
  }

  @override
  void visitSwitchExpression(SwitchExpression node) {
    violations.add(
      CompositionPurityViolation(
        filePath: filePath,
        line: node.offset,
        rule: 'forbid_conditionals',
        message: 'Switch expression in composition layer is forbidden',
      ),
    );
    super.visitSwitchExpression(node);
  }
}

List<CompositionPurityViolation> validateCompositionPurity({
  required String packageRoot,
  String? customCompositionRoot,
}) {
  final targetDir = Directory(
    customCompositionRoot ?? p.join(packageRoot, 'lib', 'composition'),
  );

  final violations = <CompositionPurityViolation>[];
  if (!targetDir.existsSync()) return violations;

  for (final entity in targetDir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final content = entity.readAsStringSync();
      final parsed = parseString(content: content, throwIfDiagnostics: false);

      final visitor = _CompositionPurityVisitor(
        filePath: p.relative(entity.path, from: packageRoot),
        violations: violations,
      );

      parsed.unit.accept(visitor);
    }
  }

  return violations;
}

void main() {
  group('Composition Purity Rules', () {
    final packageRoot = Directory.current.path;

    test('Composition layer contains zero conditional branches', () {
      final violations = validateCompositionPurity(packageRoot: packageRoot);
      expect(
        violations,
        isEmpty,
        reason: violations.map((v) => v.toString()).join('\n'),
      );
    });

    test('Negative fixture: if in composition fails check', () {
      final fixtureDir = p.join(
        packageRoot,
        'test',
        'architecture',
        'fixtures',
        'composition_with_if',
      );
      final violations = validateCompositionPurity(
        packageRoot: packageRoot,
        customCompositionRoot: fixtureDir,
      );
      expect(
        violations.any((v) => v.rule == 'forbid_conditionals'),
        isTrue,
      );
    });
  });
}
