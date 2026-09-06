import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';
import '../../tool/check_limits.dart';

void main() {
  group('check_limits tool tests', () {
    late ArchitectureLimits limits;
    late String packageRoot;

    setUpAll(() {
      packageRoot = Directory.current.path;
      final yamlFile = File(p.join(packageRoot, 'architecture.yaml'));
      final yaml = loadYaml(yamlFile.readAsStringSync()) as YamlMap;
      limits = ArchitectureLimits.fromYaml(yaml);
    });

    test('real package passes all limits with zero violations', () {
      final violations = checkPackageLimits(packageRoot);
      expect(
        violations,
        isEmpty,
        reason: 'Real codebase must respect all limits from architecture.yaml',
      );
    });

    group('Negative verification fixtures', () {
      late Directory tempDir;

      setUp(() {
        tempDir = Directory.systemTemp.createTempSync('limits_fixture_');
      });

      tearDown(() {
        tempDir.deleteSync(recursive: true);
      });

      test('detects file exceeding file_lines limit', () {
        final file = File(p.join(tempDir.path, 'long_file.dart'));
        final buffer = StringBuffer();
        for (var i = 0; i <= limits.maxFileLines + 10; i++) {
          buffer.writeln('final x$i = $i;');
        }
        file.writeAsStringSync(buffer.toString());

        final violations = checkFileLimits(file, limits, tempDir.path);
        expect(
          violations.any((v) => v.rule == 'file_lines'),
          isTrue,
          reason:
              'Must flag file exceeding maxFileLines (${limits.maxFileLines})',
        );
      });

      test('detects single-line comment violation', () {
        final file = File(p.join(tempDir.path, 'commented_file.dart'));
        file.writeAsStringSync('void f() {}\n// a comment\n');
        final violations = checkFileLimits(file, limits, tempDir.path);
        expect(
          violations.any((v) => v.rule == 'forbid_comments'),
          isTrue,
          reason: 'Must flag single-line comment',
        );
      });

      test('detects block comment violation', () {
        final file = File(p.join(tempDir.path, 'block_comment_file.dart'));
        file.writeAsStringSync('void f() {}\n/* a block comment */\n');
        final violations = checkFileLimits(file, limits, tempDir.path);
        expect(
          violations.any((v) => v.rule == 'forbid_comments'),
          isTrue,
          reason: 'Must flag block comment',
        );
      });

      test('detects doc comment violation', () {
        final file = File(p.join(tempDir.path, 'doc_comment_file.dart'));
        file.writeAsStringSync('/// doc comment\nvoid f() {}\n');
        final violations = checkFileLimits(file, limits, tempDir.path);
        expect(
          violations.any((v) => v.rule == 'forbid_comments'),
          isTrue,
          reason: 'Must flag doc comment',
        );
      });

      test('detects function exceeding function_lines limit', () {
        final file = File(p.join(tempDir.path, 'long_function.dart'));
        final buffer = StringBuffer();
        buffer.writeln('void longFunction() {');
        for (var i = 0; i <= limits.maxFunctionLines + 5; i++) {
          buffer.writeln('  final a$i = $i;');
        }
        buffer.writeln('}');
        file.writeAsStringSync(buffer.toString());

        final violations = checkFileLimits(file, limits, tempDir.path);
        expect(
          violations.any((v) => v.rule == 'function_lines'),
          isTrue,
          reason:
              'Must flag function exceeding maxFunctionLines (${limits.maxFunctionLines})',
        );
      });

      test('detects parameter list exceeding positional_parameters limit', () {
        final file = File(p.join(tempDir.path, 'many_parameters.dart'));
        file.writeAsStringSync(
          'void functionWithManyParams(int a, int b, int c, int d, int e) {}\n',
        );

        final violations = checkFileLimits(file, limits, tempDir.path);
        expect(
          violations.any((v) => v.rule == 'positional_parameters'),
          isTrue,
          reason:
              'Must flag positional parameters exceeding limit (${limits.maxPositionalParameters})',
        );
      });

      test('detects nesting depth exceeding nesting_depth limit', () {
        final file = File(p.join(tempDir.path, 'deep_nesting.dart'));
        file.writeAsStringSync('''
void deeplyNested() {
  if (true) {
    if (true) {
      if (true) {
        if (true) {
          final x = 1;
        }
      }
    }
  }
}
''');

        final violations = checkFileLimits(file, limits, tempDir.path);
        expect(
          violations.any((v) => v.rule == 'nesting_depth'),
          isTrue,
          reason:
              'Must flag nesting depth exceeding limit (${limits.maxNestingDepth})',
        );
      });

      test('detects class exceeding public_methods_per_class limit', () {
        final file = File(p.join(tempDir.path, 'many_methods.dart'));
        final buffer = StringBuffer();
        buffer.writeln('class TooManyPublicMethods {');
        for (var i = 0; i <= limits.maxPublicMethodsPerClass + 1; i++) {
          buffer.writeln('  void method$i() {}');
        }
        buffer.writeln('}');
        file.writeAsStringSync(buffer.toString());

        final violations = checkFileLimits(file, limits, tempDir.path);
        expect(
          violations.any((v) => v.rule == 'public_methods_per_class'),
          isTrue,
          reason:
              'Must flag class exceeding maxPublicMethodsPerClass (${limits.maxPublicMethodsPerClass})',
        );
      });
    });
  });
}
