import 'dart:io';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

final class DesignViolation {
  final String filePath;
  final int line;
  final String rule;
  final String message;

  const DesignViolation({
    required this.filePath,
    required this.line,
    required this.rule,
    required this.message,
  });

  @override
  String toString() => '$filePath:$line [$rule] $message';
}

const String _fontRule = 'bundled_font_missing';
const String _spacingRule = 'spacing_literal';
const String _canvasRule = 'canvas_not_unique';

const Set<String> _spacingConstructors = <String>{'EdgeInsets', 'SizedBox'};

String _constructedTypeName(NamedType type) =>
    type.importPrefix?.name.lexeme ?? type.name.lexeme;

String? _invokedTypeName(MethodInvocation node) {
  final target = node.target;
  if (target == null) return node.methodName.name;
  if (target is SimpleIdentifier) return target.name;
  return null;
}

const Set<String> _spacingArguments = <String>{
  'width',
  'height',
  'left',
  'top',
  'right',
  'bottom',
  'horizontal',
  'vertical',
};

List<DesignViolation> checkBundledFonts(String packageRoot) {
  final tokensPath =
      p.join(packageRoot, 'lib/presentation/theme/tokens/typography.dart');
  final tokensFile = File(tokensPath);
  if (!tokensFile.existsSync()) return const [];

  final declared = _declaredBundledFamilies(tokensFile.readAsStringSync());
  if (declared.isEmpty) return const [];

  final pubspec = File(p.join(packageRoot, 'pubspec.yaml'));
  final yaml = loadYaml(pubspec.readAsStringSync()) as YamlMap;
  final fonts = (yaml['flutter'] as YamlMap?)?['fonts'] as YamlList?;

  final violations = <DesignViolation>[];
  for (final family in declared) {
    final entry = _fontEntryFor(fonts, family);
    if (entry == null) {
      violations.add(DesignViolation(
        filePath: 'pubspec.yaml',
        line: 0,
        rule: _fontRule,
        message:
            'Font family "$family" is declared as bundled but is absent from pubspec fonts',
      ));
      continue;
    }
    violations.addAll(_missingAssets(packageRoot, family, entry));
  }
  return violations;
}

Set<String> _declaredBundledFamilies(String source) {
  final unit = parseString(content: source).unit;
  final collector = _BundledFamilyCollector();
  unit.visitChildren(collector);
  return collector.families;
}

YamlMap? _fontEntryFor(YamlList? fonts, String family) {
  if (fonts == null) return null;
  for (final entry in fonts) {
    if (entry is YamlMap && entry['family'] == family) return entry;
  }
  return null;
}

List<DesignViolation> _missingAssets(
    String packageRoot, String family, YamlMap entry) {
  final assets = entry['fonts'] as YamlList?;
  if (assets == null || assets.isEmpty) {
    return [
      DesignViolation(
        filePath: 'pubspec.yaml',
        line: 0,
        rule: _fontRule,
        message: 'Font family "$family" declares no asset files',
      ),
    ];
  }
  final violations = <DesignViolation>[];
  for (final asset in assets) {
    final assetPath = (asset as YamlMap)['asset'] as String?;
    if (assetPath == null) continue;
    if (!File(p.join(packageRoot, assetPath)).existsSync()) {
      violations.add(DesignViolation(
        filePath: assetPath,
        line: 0,
        rule: _fontRule,
        message: 'Font file for "$family" is declared but missing on disk',
      ));
    }
  }
  return violations;
}

final class _BundledFamilyCollector extends RecursiveAstVisitor<void> {
  final Set<String> families = <String>{};

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    if (node.name.lexeme == 'bundledFamilies') {
      final initializer = node.initializer;
      if (initializer is SetOrMapLiteral) {
        for (final element in initializer.elements) {
          if (element is! MapLiteralEntry) continue;
          final value = element.value;
          if (value is SimpleStringLiteral) families.add(value.value);
        }
      }
    }
    super.visitVariableDeclaration(node);
  }
}

List<DesignViolation> checkSpacingLiterals(String packageRoot) {
  final root = Directory(p.join(packageRoot, 'lib/presentation'));
  if (!root.existsSync()) return const [];

  final violations = <DesignViolation>[];
  for (final entry in root.listSync(recursive: true)) {
    if (entry is! File || !entry.path.endsWith('.dart')) continue;
    if (entry.path.contains('/l10n/')) continue;
    violations.addAll(spacingLiteralsIn(entry, packageRoot));
  }
  return violations;
}

List<DesignViolation> spacingLiteralsIn(File file, String packageRoot) {
  final parsed =
      parseString(content: file.readAsStringSync(), throwIfDiagnostics: false);
  final visitor = _SpacingLiteralVisitor(
    relativePath: p.relative(file.path, from: packageRoot),
    lineInfo: parsed.lineInfo,
  );
  parsed.unit.visitChildren(visitor);
  return visitor.violations;
}

final class _SpacingLiteralVisitor extends RecursiveAstVisitor<void> {
  final String relativePath;
  final LineInfo lineInfo;
  final List<DesignViolation> violations = <DesignViolation>[];

  _SpacingLiteralVisitor({required this.relativePath, required this.lineInfo});

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final typeName = _constructedTypeName(node.constructorName.type);
    if (_spacingConstructors.contains(typeName)) {
      _inspectArguments(node.argumentList, typeName);
    }
    super.visitInstanceCreationExpression(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final typeName = _invokedTypeName(node);
    if (typeName != null && _spacingConstructors.contains(typeName)) {
      _inspectArguments(node.argumentList, typeName);
    }
    super.visitMethodInvocation(node);
  }

  void _inspectArguments(ArgumentList arguments, String typeName) {
    for (final argument in arguments.arguments) {
      final expression = argument.argumentExpression;
      if (argument is NamedArgument &&
          !_spacingArguments.contains(argument.name.lexeme)) {
        continue;
      }
      if (expression is! DoubleLiteral && expression is! IntegerLiteral) {
        continue;
      }
      violations.add(DesignViolation(
        filePath: relativePath,
        line: lineInfo.getLocation(expression.offset).lineNumber,
        rule: _spacingRule,
        message:
            '$typeName uses the raw value ${expression.toSource()} instead of a spacing token',
      ));
    }
  }
}

List<DesignViolation> checkSingleCanvas(String packageRoot) {
  final root = Directory(p.join(packageRoot, 'lib'));
  final sites = <DesignViolation>[];

  for (final entry in root.listSync(recursive: true)) {
    if (entry is! File || !entry.path.endsWith('.dart')) continue;
    if (entry.path.endsWith('shell/design_canvas.dart')) continue;
    final parsed = parseString(
        content: entry.readAsStringSync(), throwIfDiagnostics: false);
    final visitor = _CanvasSiteVisitor(
      relativePath: p.relative(entry.path, from: packageRoot),
      lineInfo: parsed.lineInfo,
    );
    parsed.unit.visitChildren(visitor);
    sites.addAll(visitor.sites);
  }

  if (sites.length <= 1) return const [];
  return sites
      .map((site) => DesignViolation(
            filePath: site.filePath,
            line: site.line,
            rule: _canvasRule,
            message:
                'DesignCanvas is instantiated ${sites.length} times; exactly one is allowed',
          ))
      .toList();
}

final class _CanvasSiteVisitor extends RecursiveAstVisitor<void> {
  final String relativePath;
  final LineInfo lineInfo;
  final List<DesignViolation> sites = <DesignViolation>[];

  _CanvasSiteVisitor({required this.relativePath, required this.lineInfo});

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (_constructedTypeName(node.constructorName.type) == 'DesignCanvas') {
      _record(node.offset);
    }
    super.visitInstanceCreationExpression(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (_invokedTypeName(node) == 'DesignCanvas') {
      _record(node.offset);
    }
    super.visitMethodInvocation(node);
  }

  void _record(int offset) {
    sites.add(DesignViolation(
      filePath: relativePath,
      line: lineInfo.getLocation(offset).lineNumber,
      rule: _canvasRule,
      message: 'DesignCanvas instantiation',
    ));
  }
}

List<DesignViolation> checkDesignSystem(String packageRoot) {
  return <DesignViolation>[
    ...checkBundledFonts(packageRoot),
    ...checkSpacingLiterals(packageRoot),
    ...checkSingleCanvas(packageRoot),
  ];
}

void main(List<String> args) {
  final packageRoot = args.isEmpty ? Directory.current.path : args.first;
  final violations = checkDesignSystem(packageRoot);

  if (violations.isEmpty) {
    stdout.writeln('Design system checks passed successfully.');
    return;
  }

  stderr.writeln('Design system violations found (${violations.length}):');
  for (final violation in violations) {
    stderr.writeln('  $violation');
  }
  exitCode = 1;
}
