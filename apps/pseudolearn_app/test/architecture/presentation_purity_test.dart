import 'dart:io';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

final class PresentationPurityViolation {
  final String filePath;
  final int line;
  final String rule;
  final String message;

  const PresentationPurityViolation({
    required this.filePath,
    required this.line,
    required this.rule,
    required this.message,
  });

  @override
  String toString() => '$filePath:$line [$rule] $message';
}

final class _PresentationPurityVisitor extends RecursiveAstVisitor<void> {
  final String filePath;
  final String relativeToSource;
  final List<String> windowQueryAllowedPaths;
  final List<String> forbiddenAdaptiveConstructors;
  final List<String> forbiddenCollectionMethods;
  final bool forbidAwait;
  final List<PresentationPurityViolation> violations;

  _PresentationPurityVisitor({
    required this.filePath,
    required this.relativeToSource,
    required this.windowQueryAllowedPaths,
    required this.forbiddenAdaptiveConstructors,
    required this.forbiddenCollectionMethods,
    required this.forbidAwait,
    required this.violations,
  });

  bool get _isWindowQueryAllowed {
    for (final allowed in windowQueryAllowedPaths) {
      if (relativeToSource.startsWith(allowed)) return true;
    }
    return false;
  }

  @override
  void visitAwaitExpression(AwaitExpression node) {
    if (forbidAwait) {
      violations.add(
        PresentationPurityViolation(
          filePath: filePath,
          line: node.offset,
          rule: 'forbid_await',
          message: 'Await expression is forbidden in presentation layer',
        ),
      );
    }
    super.visitAwaitExpression(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final methodName = node.methodName.name;

    if (forbiddenCollectionMethods.contains(methodName)) {
      violations.add(
        PresentationPurityViolation(
          filePath: filePath,
          line: node.offset,
          rule: 'forbidden_collection_method',
          message:
              'Forbidden collection derivation method "$methodName" called in presentation layer',
        ),
      );
    }

    if (node.target != null) {
      final targetSource = node.target!.toSource();
      final fullCall = '$targetSource.$methodName';
      if (forbiddenAdaptiveConstructors.contains(fullCall)) {
        violations.add(
          PresentationPurityViolation(
            filePath: filePath,
            line: node.offset,
            rule: 'forbidden_adaptive_constructor',
            message: 'Adaptive constructor "$fullCall" is forbidden',
          ),
        );
      }

      if (targetSource == 'MediaQuery' && !_isWindowQueryAllowed) {
        violations.add(
          PresentationPurityViolation(
            filePath: filePath,
            line: node.offset,
            rule: 'media_query_outside_shell',
            message: 'MediaQuery query outside presentation/shell/ is forbidden',
          ),
        );
      }
    } else {
      if (forbiddenAdaptiveConstructors.contains(methodName)) {
        violations.add(
          PresentationPurityViolation(
            filePath: filePath,
            line: node.offset,
            rule: 'forbidden_adaptive_constructor',
            message: 'Adaptive constructor/function "$methodName" is forbidden',
          ),
        );
      }
    }

    super.visitMethodInvocation(node);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final typeName = node.constructorName.type.name.lexeme;
    final constructorName = node.constructorName.name?.name;
    final fullName = constructorName == null ? typeName : '$typeName.$constructorName';

    if (forbiddenAdaptiveConstructors.contains(fullName)) {
      violations.add(
        PresentationPurityViolation(
          filePath: filePath,
          line: node.offset,
          rule: 'forbidden_adaptive_constructor',
          message: 'Adaptive constructor "$fullName" is forbidden',
        ),
      );
    }

    if (typeName == 'MediaQuery' && !_isWindowQueryAllowed) {
      violations.add(
        PresentationPurityViolation(
          filePath: filePath,
          line: node.offset,
          rule: 'media_query_outside_shell',
          message: 'MediaQuery usage outside presentation/shell/ is forbidden',
        ),
      );
    }

    super.visitInstanceCreationExpression(node);
  }
}

List<PresentationPurityViolation> validatePresentationPurity({
  required String packageRoot,
  String? customPresentationRoot,
}) {
  final yamlFile = File(p.join(packageRoot, 'architecture.yaml'));
  final yaml = loadYaml(yamlFile.readAsStringSync()) as YamlMap;

  final windowAllowed = (yaml['window_query_allowed_paths'] as YamlList?)
          ?.map((e) => e.toString())
          .toList() ??
      <String>['presentation/shell/'];

  final adaptiveConstructors = (yaml['forbidden_adaptive_constructors'] as YamlList?)
          ?.map((e) => e.toString())
          .toList() ??
      <String>[];

  final presRules = yaml['presentation_rules'] as YamlMap?;
  final forbiddenMethods = (presRules?['forbidden_collection_methods'] as YamlList?)
          ?.map((e) => e.toString())
          .toList() ??
      <String>[];
  final forbidAwait = presRules?['forbid_await'] as bool? ?? true;

  final targetDir = Directory(
    customPresentationRoot ?? p.join(packageRoot, 'lib', 'presentation'),
  );

  final violations = <PresentationPurityViolation>[];
  if (!targetDir.existsSync()) return violations;

  for (final entity in targetDir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final relativeToSource = customPresentationRoot != null
          ? p.relative(entity.path, from: customPresentationRoot)
          : p.relative(entity.path, from: p.join(packageRoot, 'lib'));

      final content = entity.readAsStringSync();
      final parsed = parseString(content: content, throwIfDiagnostics: false);

      final visitor = _PresentationPurityVisitor(
        filePath: p.relative(entity.path, from: packageRoot),
        relativeToSource: relativeToSource,
        windowQueryAllowedPaths: windowAllowed,
        forbiddenAdaptiveConstructors: adaptiveConstructors,
        forbiddenCollectionMethods: forbiddenMethods,
        forbidAwait: forbidAwait,
        violations: violations,
      );

      parsed.unit.accept(visitor);
    }
  }

  return violations;
}

void main() {
  group('Presentation Purity Rules', () {
    final packageRoot = Directory.current.path;

    test('All presentation code conforms to presentation purity rules', () {
      final violations = validatePresentationPurity(packageRoot: packageRoot);
      expect(
        violations,
        isEmpty,
        reason: violations.map((v) => v.toString()).join('\n'),
      );
    });

    test('Negative fixture: where in build method fails check', () {
      final fixtureDir = p.join(
        packageRoot,
        'test',
        'architecture',
        'fixtures',
        'presentation_with_where',
      );
      final violations = validatePresentationPurity(
        packageRoot: packageRoot,
        customPresentationRoot: fixtureDir,
      );
      expect(
        violations.any((v) => v.rule == 'forbidden_collection_method'),
        isTrue,
      );
    });

    test('Negative fixture: await in onPressed fails check', () {
      final fixtureDir = p.join(
        packageRoot,
        'test',
        'architecture',
        'fixtures',
        'presentation_with_await',
      );
      final violations = validatePresentationPurity(
        packageRoot: packageRoot,
        customPresentationRoot: fixtureDir,
      );
      expect(
        violations.any((v) => v.rule == 'forbid_await'),
        isTrue,
      );
    });

    test('Negative fixture: MediaQuery outside shell fails check', () {
      final fixtureDir = p.join(
        packageRoot,
        'test',
        'architecture',
        'fixtures',
        'presentation_with_media_query',
      );
      final violations = validatePresentationPurity(
        packageRoot: packageRoot,
        customPresentationRoot: fixtureDir,
      );
      expect(
        violations.any((v) => v.rule == 'media_query_outside_shell'),
        isTrue,
      );
    });

    test('Negative fixture: adaptive constructor fails check', () {
      final fixtureDir = p.join(
        packageRoot,
        'test',
        'architecture',
        'fixtures',
        'presentation_with_adaptive',
      );
      final violations = validatePresentationPurity(
        packageRoot: packageRoot,
        customPresentationRoot: fixtureDir,
      );
      expect(
        violations.any((v) => v.rule == 'forbidden_adaptive_constructor'),
        isTrue,
      );
    });
  });
}
