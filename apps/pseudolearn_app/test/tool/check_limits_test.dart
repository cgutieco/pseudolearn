import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';
import '../../tool/check_limits.dart';

void main() {
  group('Architecture Limits Checker', () {
    late ArchitectureLimits limits;
    final packageRoot = Directory.current.path;

    setUpAll(() {
      final yamlFile = File(p.join(packageRoot, 'architecture.yaml'));
      final yaml = loadYaml(yamlFile.readAsStringSync()) as YamlMap;
      limits = ArchitectureLimits.fromYaml(yaml);
    });

    test('Package code passes all limits checks cleanly', () {
      final violations = checkPackageLimits(packageRoot);
      expect(
        violations,
        isEmpty,
        reason: violations.map((v) => v.toString()).join('\n'),
      );
    });

    test('Negative fixture: file exceeding line count limit', () {
      final tempDir = Directory.systemTemp.createTempSync('limits_test_');
      final testFile = File(p.join(tempDir.path, 'long_file.dart'));
      testFile.writeAsStringSync(
          List.generate(260, (i) => 'final x$i = $i;').join('\n'));

      final violations = checkFileLimits(testFile, limits, tempDir.path);
      expect(violations.any((v) => v.rule == 'file_lines'), isTrue);
      tempDir.deleteSync(recursive: true);
    });

    test('Negative fixture: single-line comment violation', () {
      final tempDir = Directory.systemTemp.createTempSync('limits_test_');
      final testFile = File(p.join(tempDir.path, 'commented.dart'));
      testFile.writeAsStringSync('void f() {}\n// a comment\n');

      final violations = checkFileLimits(testFile, limits, tempDir.path);
      expect(violations.any((v) => v.rule == 'forbid_comments'), isTrue);
      tempDir.deleteSync(recursive: true);
    });

    test('Negative fixture: block comment violation', () {
      final tempDir = Directory.systemTemp.createTempSync('limits_test_');
      final testFile = File(p.join(tempDir.path, 'block_comment.dart'));
      testFile.writeAsStringSync('void f() {}\n/* a block comment */\n');

      final violations = checkFileLimits(testFile, limits, tempDir.path);
      expect(violations.any((v) => v.rule == 'forbid_comments'), isTrue);
      tempDir.deleteSync(recursive: true);
    });

    test('Negative fixture: doc comment violation', () {
      final tempDir = Directory.systemTemp.createTempSync('limits_test_');
      final testFile = File(p.join(tempDir.path, 'doc_comment.dart'));
      testFile.writeAsStringSync('/// doc comment\nvoid f() {}\n');

      final violations = checkFileLimits(testFile, limits, tempDir.path);
      expect(violations.any((v) => v.rule == 'forbid_comments'), isTrue);
      tempDir.deleteSync(recursive: true);
    });

    test('Negative fixture: function exceeding line count limit', () {
      final tempDir = Directory.systemTemp.createTempSync('limits_test_');
      final testFile = File(p.join(tempDir.path, 'long_func.dart'));
      final lines = ['void longFunction() {'];
      for (var i = 0; i < 45; i++) {
        lines.add('  final v$i = $i;');
      }
      lines.add('}');
      testFile.writeAsStringSync(lines.join('\n'));

      final violations = checkFileLimits(testFile, limits, tempDir.path);
      expect(violations.any((v) => v.rule == 'function_lines'), isTrue);
      tempDir.deleteSync(recursive: true);
    });

    test('Negative fixture: build method exceeding 30 lines limit', () {
      final tempDir = Directory.systemTemp.createTempSync('limits_test_');
      final testFile = File(p.join(tempDir.path, 'long_build.dart'));
      final lines = ['class MyWidget {', '  Widget build() {'];
      for (var i = 0; i < 32; i++) {
        lines.add('    final v$i = $i;');
      }
      lines.add('    return Container();');
      lines.add('  }');
      lines.add('}');
      testFile.writeAsStringSync(lines.join('\n'));

      final violations = checkFileLimits(testFile, limits, tempDir.path);
      expect(violations.any((v) => v.rule == 'build_method_lines'), isTrue);
      tempDir.deleteSync(recursive: true);
    });

    test('Negative fixture: parameter list with >3 positional parameters', () {
      final tempDir = Directory.systemTemp.createTempSync('limits_test_');
      final testFile = File(p.join(tempDir.path, 'too_many_params.dart'));
      testFile.writeAsStringSync('void foo(int a, int b, int c, int d) {}');

      final violations = checkFileLimits(testFile, limits, tempDir.path);
      expect(violations.any((v) => v.rule == 'positional_parameters'), isTrue);
      tempDir.deleteSync(recursive: true);
    });

    test('Negative fixture: control flow nesting exceeding depth 3', () {
      final tempDir = Directory.systemTemp.createTempSync('limits_test_');
      final testFile = File(p.join(tempDir.path, 'deep_nesting.dart'));
      testFile.writeAsStringSync('''
void nested(bool a, bool b, bool c, bool d) {
  if (a) {
    if (b) {
      if (c) {
        if (d) {
        }
      }
    }
  }
}
''');

      final violations = checkFileLimits(testFile, limits, tempDir.path);
      expect(violations.any((v) => v.rule == 'nesting_depth'), isTrue);
      tempDir.deleteSync(recursive: true);
    });

    test(
        'Widget tree nesting of 8 levels is NOT counted as control flow nesting',
        () {
      final tempDir = Directory.systemTemp.createTempSync('limits_test_');
      final testFile = File(p.join(tempDir.path, 'deep_widgets.dart'));
      testFile.writeAsStringSync('''
class Container {
  final Object? child;
  const Container({this.child});
}

class DeepWidget {
  Container build() {
    return const Container(
      child: Container(
        child: Container(
          child: Container(
            child: Container(
              child: Container(
                child: Container(
                  child: Container(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
''');

      final violations = checkFileLimits(testFile, limits, tempDir.path);
      expect(violations.where((v) => v.rule == 'nesting_depth'), isEmpty);
      tempDir.deleteSync(recursive: true);
    });

    test('Negative fixture: class with >5 public methods', () {
      final tempDir = Directory.systemTemp.createTempSync('limits_test_');
      final testFile = File(p.join(tempDir.path, 'too_many_methods.dart'));
      testFile.writeAsStringSync('''
class BusyClass {
  void m1() {}
  void m2() {}
  void m3() {}
  void m4() {}
  void m5() {}
  void m6() {}
}
''');

      final violations = checkFileLimits(testFile, limits, tempDir.path);
      expect(
          violations.any((v) => v.rule == 'public_methods_per_class'), isTrue);
      tempDir.deleteSync(recursive: true);
    });

    test('Negative fixture: method returning Widget helper', () {
      final tempDir = Directory.systemTemp.createTempSync('limits_test_');
      final testFile =
          File(p.join(tempDir.path, 'widget_returning_helper.dart'));
      testFile.writeAsStringSync('''
class SomeWidget {
  Widget _buildRow() => Container();
}
''');

      final violations = checkFileLimits(testFile, limits, tempDir.path);
      expect(violations.any((v) => v.rule == 'forbid_widget_returning_methods'),
          isTrue);
      tempDir.deleteSync(recursive: true);
    });

    test('Negative fixture: widget class declaring forbidden public method',
        () {
      final tempDir = Directory.systemTemp.createTempSync('limits_test_');
      final testFile = File(p.join(tempDir.path, 'widget_extra_public.dart'));
      testFile.writeAsStringSync('''
class StatelessWidget {}
class CustomWidget extends StatelessWidget {
  void doSomethingCustom() {}
}
''');

      final violations = checkFileLimits(testFile, limits, tempDir.path);
      expect(violations.any((v) => v.rule == 'widget_allowed_public_members'),
          isTrue);
      tempDir.deleteSync(recursive: true);
    });
  });
}
