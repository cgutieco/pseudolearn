import 'dart:io';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:test/test.dart';

void main() {
  group('Architectural purity: no user-facing strings outside diagnostics', () {
    final suspiciousPhrases = [
      'no se puede',
      'se esperaba',
      'carácter no reconocido',
      'cadena sin cerrar',
      'tipo incompatible',
      'variable no declarada',
      'no permitido',
      'cannot be',
      'expected a',
      'unexpected token',
      'unclosed',
      'incompatible type',
      'undeclared variable',
    ];

    List<String> findSuspiciousStringsInFile(String filePath, String content) {
      final parseResult = parseString(content: content, throwIfDiagnostics: false);
      final visitor = _StringLiteralVisitor(suspiciousPhrases);
      parseResult.unit.accept(visitor);
      return visitor.violations;
    }

    test('syntax, semantic, and evaluation layers contain no user-facing message strings', () {
      final libDir = Directory('lib/src');
      final checkedDirs = ['syntax', 'semantic', 'evaluation'];
      final allViolations = <String>[];

      for (final dirName in checkedDirs) {
        final dir = Directory('${libDir.path}/$dirName');
        if (!dir.existsSync()) continue;

        for (final file in dir.listSync(recursive: true).whereType<File>()) {
          if (!file.path.endsWith('.dart')) continue;
          final content = file.readAsStringSync();
          final violations = findSuspiciousStringsInFile(file.path, content);
          for (final violation in violations) {
            allViolations.add('${file.path}: $violation');
          }
        }
      }

      expect(
        allViolations,
        isEmpty,
        reason: 'Found user-facing strings outside presentation layer:\n${allViolations.join('\n')}',
      );
    });

    test('detects deliberate user-facing strings in fixture (negative test)', () {
      const badSnippet = '''
        void report() {
          print("tipo incompatible en la operacion");
        }
      ''';
      final violations = findSuspiciousStringsInFile('bad_file.dart', badSnippet);
      expect(violations, isNotEmpty);
    });
  });
}

class _StringLiteralVisitor extends RecursiveAstVisitor<void> {
  final List<String> suspiciousPhrases;
  final List<String> violations = [];

  _StringLiteralVisitor(this.suspiciousPhrases);

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    final text = node.value.toLowerCase();
    for (final phrase in suspiciousPhrases) {
      if (text.contains(phrase.toLowerCase())) {
        violations.add('Found suspicious phrase "$phrase" in string "${node.value}" at line ${node.offset}');
      }
    }
    super.visitSimpleStringLiteral(node);
  }
}
