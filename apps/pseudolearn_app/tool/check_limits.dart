import 'dart:io';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

final class LimitViolation {
  final String filePath;
  final int line;
  final String rule;
  final String message;

  const LimitViolation({
    required this.filePath,
    required this.line,
    required this.rule,
    required this.message,
  });

  @override
  String toString() => '$filePath:$line [$rule] $message';
}

final class ArchitectureLimits {
  final int maxFileLines;
  final int maxFunctionLines;
  final int maxBuildMethodLines;
  final int maxPositionalParameters;
  final int maxNestingDepth;
  final int maxPublicMethodsPerClass;
  final List<String> exemptPaths;
  final List<String> allowedPublicMembers;
  final bool forbidWidgetReturningMethods;
  final bool nestingCountsControlFlowOnly;
  final bool forbidComments;
  final List<String> commentExemptPaths;

  const ArchitectureLimits({
    required this.maxFileLines,
    required this.maxFunctionLines,
    required this.maxBuildMethodLines,
    required this.maxPositionalParameters,
    required this.maxNestingDepth,
    required this.maxPublicMethodsPerClass,
    required this.exemptPaths,
    required this.allowedPublicMembers,
    required this.forbidWidgetReturningMethods,
    required this.nestingCountsControlFlowOnly,
    required this.forbidComments,
    required this.commentExemptPaths,
  });

  factory ArchitectureLimits.fromYaml(YamlMap yaml) {
    final limits = yaml['limits'] as YamlMap;
    final widgetRules = yaml['widget_rules'] as YamlMap?;
    final codeRules = yaml['code_rules'] as YamlMap?;
    final exemptList = (yaml['limits_exempt'] as YamlList?)
            ?.map((element) => element.toString())
            .toList() ??
        const <String>[];
    final commentExemptList = (codeRules?['comment_exempt'] as YamlList?)
            ?.map((element) => element.toString())
            .toList() ??
        const <String>[];
    final allowedMembers = (widgetRules?['allowed_public_members'] as YamlList?)
            ?.map((element) => element.toString())
            .toList() ??
        const <String>['build', 'createState'];

    return ArchitectureLimits(
      maxFileLines: limits['file_lines'] as int,
      maxFunctionLines: limits['function_lines'] as int,
      maxBuildMethodLines: limits['build_method_lines'] as int? ?? 30,
      maxPositionalParameters: limits['positional_parameters'] as int,
      maxNestingDepth: limits['nesting_depth'] as int,
      maxPublicMethodsPerClass: limits['public_methods_per_class'] as int,
      exemptPaths: exemptList,
      allowedPublicMembers: allowedMembers,
      forbidWidgetReturningMethods:
          widgetRules?['forbid_widget_returning_methods'] as bool? ?? true,
      nestingCountsControlFlowOnly:
          yaml['nesting_counts_control_flow_only'] as bool? ?? true,
      forbidComments: codeRules?['forbid_comments'] as bool? ?? false,
      commentExemptPaths: commentExemptList,
    );
  }

  bool isExempt(String relativePath) {
    for (final exempt in exemptPaths) {
      if (relativePath.startsWith(exempt)) {
        return true;
      }
    }
    return false;
  }

  bool isCommentExempt(String relativePath) {
    for (final exempt in commentExemptPaths) {
      if (relativePath.startsWith(exempt)) {
        return true;
      }
    }
    return false;
  }
}

final class _LimitsAstVisitor extends RecursiveAstVisitor<void> {
  final String filePath;
  final LineInfo lineInfo;
  final ArchitectureLimits limits;
  final List<LimitViolation> violations;
  int _currentNestingDepth = 0;

  _LimitsAstVisitor({
    required this.filePath,
    required this.lineInfo,
    required this.limits,
    required this.violations,
  });

  int _getLine(int offset) => lineInfo.getLocation(offset).lineNumber;

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    _checkFunctionLength(
      _getLine(node.offset),
      _getLine(node.end),
      'Function ${node.name.lexeme}',
      limits.maxFunctionLines,
    );
    if (limits.forbidWidgetReturningMethods) {
      _checkWidgetReturningFunction(node);
    }
    super.visitFunctionDeclaration(node);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    final methodName = node.name.lexeme;
    final maxLines = methodName == 'build'
        ? limits.maxBuildMethodLines
        : limits.maxFunctionLines;
    _checkFunctionLength(
      _getLine(node.offset),
      _getLine(node.end),
      'Method $methodName',
      maxLines,
    );
    if (limits.forbidWidgetReturningMethods && methodName != 'build') {
      _checkWidgetReturningMethod(node);
    }
    super.visitMethodDeclaration(node);
  }

  @override
  void visitConstructorDeclaration(ConstructorDeclaration node) {
    _checkFunctionLength(
      _getLine(node.offset),
      _getLine(node.end),
      'Constructor ${node.name?.lexeme ?? 'default'}',
      limits.maxFunctionLines,
    );
    super.visitConstructorDeclaration(node);
  }

  void _checkFunctionLength(
    int startLine,
    int endLine,
    String label,
    int limit,
  ) {
    final length = endLine - startLine + 1;
    if (length > limit) {
      final rule = limit == limits.maxBuildMethodLines
          ? 'build_method_lines'
          : 'function_lines';
      violations.add(
        LimitViolation(
          filePath: filePath,
          line: startLine,
          rule: rule,
          message: '$label has $length lines (max $limit)',
        ),
      );
    }
  }

  void _checkWidgetReturningFunction(FunctionDeclaration node) {
    final returnType = node.returnType?.toSource();
    if (returnType != null && _isWidgetType(returnType)) {
      violations.add(
        LimitViolation(
          filePath: filePath,
          line: _getLine(node.offset),
          rule: 'forbid_widget_returning_methods',
          message:
              'Top-level function ${node.name.lexeme} returns Widget ($returnType)',
        ),
      );
    }
  }

  void _checkWidgetReturningMethod(MethodDeclaration node) {
    final hasOverride = node.metadata.any((m) => m.name.name == 'override');
    if (hasOverride) return;

    final returnType = node.returnType?.toSource();
    if (returnType != null && _isWidgetType(returnType)) {
      violations.add(
        LimitViolation(
          filePath: filePath,
          line: _getLine(node.offset),
          rule: 'forbid_widget_returning_methods',
          message: 'Method ${node.name.lexeme} returns Widget ($returnType)',
        ),
      );
    }
  }

  bool _isWidgetType(String typeName) {
    final trimmed = typeName.trim();
    return trimmed == 'Widget' ||
        trimmed == 'Widget?' ||
        trimmed.endsWith('Widget') ||
        trimmed.endsWith('Widget?');
  }

  @override
  void visitFormalParameterList(FormalParameterList node) {
    final parent = node.parent;
    if (parent is MethodDeclaration &&
        parent.metadata.any((m) => m.name.name == 'override')) {
      super.visitFormalParameterList(node);
      return;
    }

    var positionalCount = 0;
    for (final parameter in node.parameters) {
      if (parameter.isPositional) {
        positionalCount++;
      }
    }

    if (positionalCount > limits.maxPositionalParameters) {
      violations.add(
        LimitViolation(
          filePath: filePath,
          line: _getLine(node.offset),
          rule: 'positional_parameters',
          message:
              'Parameter list has $positionalCount positional parameters (max ${limits.maxPositionalParameters})',
        ),
      );
    }
    super.visitFormalParameterList(node);
  }

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    var publicMethodCount = 0;
    final isWidgetClass = _isSubclassOfWidget(node);

    for (final member in node.body.members) {
      if (member is MethodDeclaration &&
          !member.isGetter &&
          !member.isSetter &&
          !member.name.lexeme.startsWith('_')) {
        publicMethodCount++;

        if (isWidgetClass &&
            !limits.allowedPublicMembers.contains(member.name.lexeme)) {
          violations.add(
            LimitViolation(
              filePath: filePath,
              line: _getLine(member.offset),
              rule: 'widget_allowed_public_members',
              message:
                  'Widget class ${node.namePart.typeName.lexeme} declares forbidden public method ${member.name.lexeme}',
            ),
          );
        }
      }
    }

    if (publicMethodCount > limits.maxPublicMethodsPerClass) {
      violations.add(
        LimitViolation(
          filePath: filePath,
          line: _getLine(node.offset),
          rule: 'public_methods_per_class',
          message:
              'Class ${node.namePart.typeName.lexeme} has $publicMethodCount public methods (max ${limits.maxPublicMethodsPerClass})',
        ),
      );
    }
    super.visitClassDeclaration(node);
  }

  bool _isSubclassOfWidget(ClassDeclaration node) {
    final superclass = node.extendsClause?.superclass.name.lexeme;
    if (superclass == null) return false;
    return superclass == 'StatelessWidget' ||
        superclass == 'StatefulWidget' ||
        superclass == 'Widget';
  }

  @override
  void visitIfStatement(IfStatement node) =>
      _visitNested(node, super.visitIfStatement);

  @override
  void visitForStatement(ForStatement node) =>
      _visitNested(node, super.visitForStatement);

  @override
  void visitWhileStatement(WhileStatement node) =>
      _visitNested(node, super.visitWhileStatement);

  @override
  void visitDoStatement(DoStatement node) =>
      _visitNested(node, super.visitDoStatement);

  @override
  void visitSwitchStatement(SwitchStatement node) =>
      _visitNested(node, super.visitSwitchStatement);

  @override
  void visitTryStatement(TryStatement node) =>
      _visitNested(node, super.visitTryStatement);

  void _visitNested<T extends AstNode>(T node, void Function(T) superVisit) {
    _currentNestingDepth++;
    if (_currentNestingDepth > limits.maxNestingDepth) {
      violations.add(
        LimitViolation(
          filePath: filePath,
          line: _getLine(node.offset),
          rule: 'nesting_depth',
          message:
              'Nesting depth is $_currentNestingDepth (max ${limits.maxNestingDepth})',
        ),
      );
    }
    superVisit(node);
    _currentNestingDepth--;
  }
}

List<LimitViolation> checkFileLimits(
  File file,
  ArchitectureLimits limits,
  String packageRoot,
) {
  final violations = <LimitViolation>[];
  final relativePath = p.relative(file.path, from: packageRoot);
  final isExemptFromSize = limits.isExempt(relativePath);
  final content = file.readAsStringSync();

  if (!isExemptFromSize) {
    final lines = content.split('\n');
    if (lines.length > limits.maxFileLines) {
      violations.add(
        LimitViolation(
          filePath: relativePath,
          line: 1,
          rule: 'file_lines',
          message:
              'File has ${lines.length} lines (max ${limits.maxFileLines})',
        ),
      );
    }
  }

  final parsed = parseString(content: content, throwIfDiagnostics: false);

  if (!isExemptFromSize) {
    final visitor = _LimitsAstVisitor(
      filePath: relativePath,
      lineInfo: parsed.lineInfo,
      limits: limits,
      violations: violations,
    );
    parsed.unit.accept(visitor);
  }

  if (limits.forbidComments && !limits.isCommentExempt(relativePath)) {
    _checkForbiddenComments(parsed, relativePath, violations);
  }

  return violations;
}

void _checkForbiddenComments(
  ParseStringResult parsed,
  String relativePath,
  List<LimitViolation> violations,
) {
  var token = parsed.unit.beginToken;
  while (!token.isEof) {
    Token? comment = token.precedingComments;
    while (comment != null) {
      violations.add(
        LimitViolation(
          filePath: relativePath,
          line: parsed.lineInfo.getLocation(comment.offset).lineNumber,
          rule: 'forbid_comments',
          message:
              'Forbidden comment: "${comment.lexeme.trim()}". The name and body explain what; the why lives in the package README.',
        ),
      );
      comment = comment.next;
    }
    token = token.next!;
  }
  Token? comment = token.precedingComments;
  while (comment != null) {
    violations.add(
      LimitViolation(
        filePath: relativePath,
        line: parsed.lineInfo.getLocation(comment.offset).lineNumber,
        rule: 'forbid_comments',
        message:
            'Forbidden comment: "${comment.lexeme.trim()}". The name and body explain what; the why lives in the package README.',
      ),
    );
    comment = comment.next;
  }
}

List<LimitViolation> checkPackageLimits(String packageRoot) {
  final yamlFile = File(p.join(packageRoot, 'architecture.yaml'));
  if (!yamlFile.existsSync()) {
    throw StateError('architecture.yaml not found at $packageRoot');
  }

  final yaml = loadYaml(yamlFile.readAsStringSync()) as YamlMap;
  final limits = ArchitectureLimits.fromYaml(yaml);

  final violations = <LimitViolation>[];
  final rootDir = Directory(packageRoot);

  for (final entity in rootDir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final relative = p.relative(entity.path, from: packageRoot);
      if (relative.startsWith('.dart_tool/') ||
          relative.startsWith('build/') ||
          relative.startsWith('macos/') ||
          relative.startsWith('ios/') ||
          relative.startsWith('android/') ||
          relative.startsWith('web/') ||
          relative.startsWith('linux/') ||
          relative.startsWith('windows/')) {
        continue;
      }
      violations.addAll(checkFileLimits(entity, limits, packageRoot));
    }
  }

  return violations;
}

void main() {
  final currentDir = Directory.current.path;
  final violations = checkPackageLimits(currentDir);

  if (violations.isEmpty) {
    stdout.writeln('All limits checks passed successfully.');
    exit(0);
  }

  stderr
      .writeln('Architecture limits violations found (${violations.length}):');
  for (final violation in violations) {
    stderr.writeln('  $violation');
  }
  exit(1);
}
