import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:yaml/yaml.dart';

void main() {
  try {
    final rules =
        loadYaml(File('architecture.yaml').readAsStringSync()) as YamlMap;
    final findings = <String>[];
    for (final root in ['lib', 'bin', 'tool', 'test']) {
      for (final entry in Directory(
        root,
      ).listSync(recursive: true).whereType<File>()) {
        if (entry.path.endsWith('.dart')) {
          findings.addAll(
            inspect(
              entry.readAsStringSync(),
              entry.path.replaceAll('\\', '/'),
              rules,
            ),
          );
        }
      }
    }
    for (final layer in rules['layers'] as YamlList) {
      if (!Directory('lib/src/${layer['path']}').existsSync()) {
        findings.add('LAYER-DECLARED');
      }
    }
    if (findings.isNotEmpty) {
      stderr.writeln(findings.join('\n'));
      exitCode = 1;
    } else {
      stdout.writeln('Benchmark architecture and limits passed');
    }
  } on Object catch (error) {
    stderr.writeln('Invalid verification configuration: $error');
    exitCode = 2;
  }
}

List<String> inspect(String source, String path, YamlMap rules) {
  final parsed = parseString(content: source, throwIfDiagnostics: false);
  final findings = <String>[];
  if (parsed.errors.isNotEmpty) findings.add('$path SYNTAX-INVALID');
  var token = parsed.unit.beginToken;
  while (!token.isEof) {
    if (token.precedingComments != null) {
      findings.add('$path QUALITY-NO-COMMENTS');
    }
    token = token.next!;
  }
  if (token.precedingComments != null) {
    findings.add('$path QUALITY-NO-COMMENTS');
  }
  findings.addAll(checkImports(parsed.unit, path, rules));
  if (path.startsWith('lib/') || path.startsWith('bin/')) {
    final limits = rules['limits'] as YamlMap;
    if (source.split('\n').length > (limits['file_lines'] as int)) {
      findings.add('$path SIZE-FILE');
    }
    final visitor = SizeVisitor(limits, parsed.lineInfo);
    parsed.unit.accept(visitor);
    findings.addAll(visitor.findings.map((finding) => '$path $finding'));
  }
  return findings;
}

List<String> checkImports(CompilationUnit unit, String path, YamlMap rules) {
  final findings = <String>[];
  final layers = rules['layers'] as YamlList;
  final sourceLayer = path.startsWith('lib/src/') ? path.split('/')[2] : null;
  final rule = layers
      .where((layer) => layer['name'] == sourceLayer)
      .firstOrNull;
  if (sourceLayer != null && rule == null) findings.add('$path LAYER-DECLARED');
  for (final directive in unit.directives.whereType<UriBasedDirective>()) {
    final uri = directive.uri.stringValue ?? '';
    if (uri.startsWith('package:pseudolearn_core/') &&
        uri != 'package:pseudolearn_core/pseudolearn_core.dart') {
      findings.add('$path LAYER-DIRECTION');
    }
    if (rule == null || uri.startsWith('dart:')) continue;
    if (uri.startsWith('package:')) {
      if (uri == 'package:pseudolearn_core/pseudolearn_core.dart' &&
          sourceLayer == 'execution') {
        continue;
      }
      findings.add('$path LAYER-DIRECTION');
      continue;
    }
    final target = Uri.file(path).resolve(uri).path.split('/');
    if (target.length < 4 || target[0] != 'lib' || target[1] != 'src') {
      findings.add('$path LAYER-DIRECTION');
      continue;
    }
    final permitted = rule['may_import'] as YamlList;
    if (target[2] != sourceLayer && !permitted.contains(target[2])) {
      findings.add('$path LAYER-DIRECTION');
    }
  }
  return findings;
}

final class SizeVisitor extends RecursiveAstVisitor<void> {
  final YamlMap limits;
  final LineInfo lines;
  final List<String> findings = [];
  int depth = 0;

  SizeVisitor(this.limits, this.lines);

  void checkFunction(AstNode node, FormalParameterList? parameters) {
    final length =
        lines.getLocation(node.end).lineNumber -
        lines.getLocation(node.offset).lineNumber +
        1;
    if (length > (limits['function_lines'] as int)) {
      findings.add('SIZE-FUNCTION');
    }
    final positional =
        parameters?.parameters
            .where((parameter) => parameter.isPositional)
            .length ??
        0;
    if (positional > (limits['positional_parameters'] as int)) {
      findings.add('SIZE-PARAMETERS');
    }
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    checkFunction(node, node.functionExpression.parameters);
    super.visitFunctionDeclaration(node);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    checkFunction(node, node.parameters);
    super.visitMethodDeclaration(node);
  }

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final public = node.body.members
        .whereType<MethodDeclaration>()
        .where((method) => !method.name.lexeme.startsWith('_'))
        .length;
    if (public > (limits['public_methods_per_class'] as int)) {
      findings.add('SIZE-METHODS');
    }
    super.visitClassDeclaration(node);
  }

  void descend(void Function() visit) {
    depth++;
    if (depth > (limits['nesting_depth'] as int)) findings.add('SIZE-NESTING');
    visit();
    depth--;
  }

  @override
  void visitIfStatement(IfStatement node) =>
      descend(() => super.visitIfStatement(node));
  @override
  void visitForStatement(ForStatement node) =>
      descend(() => super.visitForStatement(node));
  @override
  void visitWhileStatement(WhileStatement node) =>
      descend(() => super.visitWhileStatement(node));
  @override
  void visitSwitchStatement(SwitchStatement node) =>
      descend(() => super.visitSwitchStatement(node));
}
