import 'dart:io';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

final class LayerRule {
  final int id;
  final String name;
  final String path;
  final Set<String> mayImport;
  final List<String> forbiddenImports;

  const LayerRule({
    required this.id,
    required this.name,
    required this.path,
    required this.mayImport,
    required this.forbiddenImports,
  });
}

final class ArchitectureConfig {
  final String packageName;
  final String sourceRoot;
  final List<String> entrypoints;
  final List<LayerRule> layers;
  final List<String> forbiddenImports;
  final bool forbidSelfPackageImports;
  final Map<String, List<String>> forbiddenIdentifiers;

  const ArchitectureConfig({
    required this.packageName,
    required this.sourceRoot,
    required this.entrypoints,
    required this.layers,
    required this.forbiddenImports,
    required this.forbidSelfPackageImports,
    required this.forbiddenIdentifiers,
  });

  factory ArchitectureConfig.fromYaml(YamlMap yaml) {
    final layerList = <LayerRule>[];
    for (final layerMap in yaml['layers'] as YamlList) {
      final map = layerMap as YamlMap;
      final mayImportList = (map['may_import'] as YamlList?)
              ?.map((entry) => entry.toString())
              .toSet() ??
          <String>{};
      final layerForbidden = (map['forbidden_imports'] as YamlList?)
              ?.map((entry) => entry.toString())
              .toList() ??
          const <String>[];

      layerList.add(
        LayerRule(
          id: map['id'] as int,
          name: map['name'] as String,
          path: map['path'] as String,
          mayImport: mayImportList,
          forbiddenImports: layerForbidden,
        ),
      );
    }

    final globalForbidden = (yaml['forbidden_imports'] as YamlList?)
            ?.map((entry) => entry.toString())
            .toList() ??
        const <String>[];

    final entrypointList = (yaml['entrypoints'] as YamlList?)
            ?.map((entry) => entry.toString())
            .toList() ??
        const <String>[];

    final identifiersMap = <String, List<String>>{};
    final rawIdentifiers = yaml['forbidden_identifiers'] as YamlMap?;
    if (rawIdentifiers != null) {
      for (final key in rawIdentifiers.keys) {
        final list = (rawIdentifiers[key] as YamlList)
            .map((item) => item.toString())
            .toList();
        identifiersMap[key.toString()] = list;
      }
    }

    return ArchitectureConfig(
      packageName: yaml['package'] as String,
      sourceRoot: yaml['source_root'] as String,
      entrypoints: entrypointList,
      layers: layerList,
      forbiddenImports: globalForbidden,
      forbidSelfPackageImports:
          yaml['forbid_self_package_imports'] as bool? ?? false,
      forbiddenIdentifiers: identifiersMap,
    );
  }

  LayerRule? layerForPath(String relativePath) {
    final normalized = p.normalize(relativePath).replaceAll(r'\', '/');
    for (final layer in layers) {
      if (normalized == layer.path ||
          normalized.startsWith('${layer.path}/')) {
        return layer;
      }
    }
    return null;
  }
}

final class ArchitectureViolation {
  final String filePath;
  final String violationType;
  final String message;

  const ArchitectureViolation({
    required this.filePath,
    required this.violationType,
    required this.message,
  });

  @override
  String toString() => '$filePath [$violationType] $message';
}

final class _IdentifierCheckerVisitor extends RecursiveAstVisitor<void> {
  final String filePath;
  final List<String> forbidden;
  final List<ArchitectureViolation> violations;

  _IdentifierCheckerVisitor({
    required this.filePath,
    required this.forbidden,
    required this.violations,
  });

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    final name = node.name;
    if (forbidden.contains(name)) {
      violations.add(
        ArchitectureViolation(
          filePath: filePath,
          violationType: 'forbidden_identifier',
          message: 'Uses forbidden identifier "$name"',
        ),
      );
    }
    super.visitSimpleIdentifier(node);
  }
}

List<ArchitectureViolation> validateArchitecture({
  required ArchitectureConfig config,
  required String packageRoot,
  String? customSourceRoot,
}) {
  final violations = <ArchitectureViolation>[];
  final sourceRootDir = Directory(
    customSourceRoot ?? p.join(packageRoot, config.sourceRoot),
  );

  if (!sourceRootDir.existsSync()) {
    return violations;
  }

  void checkLayerDeclared(Directory dir, String parentRelative) {
    for (final entity in dir.listSync(recursive: false)) {
      if (entity is Directory) {
        final relPath = parentRelative.isEmpty
            ? p.basename(entity.path)
            : '$parentRelative/${p.basename(entity.path)}';

        final isDeclared = config.layers.any((layer) =>
            layer.path == relPath || layer.path.startsWith('$relPath/'));

        if (!isDeclared) {
          violations.add(
            ArchitectureViolation(
              filePath: relPath,
              violationType: 'undeclared_layer',
              message: 'Directory "$relPath" is not declared in architecture.yaml',
            ),
          );
        } else if (config.layers.any((layer) => layer.path.startsWith('$relPath/') && layer.path != relPath)) {
          checkLayerDeclared(entity, relPath);
        }
      }
    }
  }

  checkLayerDeclared(sourceRootDir, '');

  for (final entity in sourceRootDir.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;

    final relativeToSource = p.relative(entity.path, from: sourceRootDir.path);
    final relativeToRoot = p.relative(entity.path, from: packageRoot);
    final isEntrypoint = config.entrypoints.any((ep) =>
        ep == relativeToRoot || p.basename(ep) == p.basename(entity.path));

    final sourceLayer = config.layerForPath(relativeToSource);
    if (sourceLayer == null && !isEntrypoint) {
      violations.add(
        ArchitectureViolation(
          filePath: relativeToRoot,
          violationType: 'file_without_layer',
          message: 'File "$relativeToSource" does not belong to any layer',
        ),
      );
      continue;
    }

    final content = entity.readAsStringSync();
    final parsed = parseString(content: content, throwIfDiagnostics: false);

    for (final directive in parsed.unit.directives) {
      String? uriString;
      if (directive is ImportDirective) {
        uriString = directive.uri.stringValue;
      } else if (directive is ExportDirective) {
        uriString = directive.uri.stringValue;
      }

      if (uriString == null) continue;

      for (final globalForbidden in config.forbiddenImports) {
        if (uriString.startsWith(globalForbidden)) {
          violations.add(
            ArchitectureViolation(
              filePath: relativeToRoot,
              violationType: 'global_forbidden_import',
              message: 'Imports forbidden dependency "$uriString"',
            ),
          );
        }
      }

      if (config.forbidSelfPackageImports &&
          uriString.startsWith('package:${config.packageName}/')) {
        violations.add(
          ArchitectureViolation(
            filePath: relativeToRoot,
            violationType: 'self_package_import',
            message: 'Self package import is forbidden: "$uriString"',
          ),
        );
      }

      if (sourceLayer != null) {
        for (final layerForbidden in sourceLayer.forbiddenImports) {
          if (uriString.startsWith(layerForbidden)) {
            violations.add(
              ArchitectureViolation(
                filePath: relativeToRoot,
                violationType: 'layer_forbidden_import',
                message:
                    'Layer "${sourceLayer.name}" forbids import "$uriString"',
              ),
            );
          }
        }

        if (uriString.startsWith('.')) {
          final importedAbsolutePath = p.normalize(
            p.join(p.dirname(entity.path), uriString),
          );
          final importedRelative = p.relative(
            importedAbsolutePath,
            from: sourceRootDir.path,
          );
          final targetLayer = config.layerForPath(importedRelative);

          if (targetLayer != null && targetLayer.name != sourceLayer.name) {
            if (!sourceLayer.mayImport.contains(targetLayer.name)) {
              violations.add(
                ArchitectureViolation(
                  filePath: relativeToRoot,
                  violationType: 'layer_direction',
                  message:
                      'Layer "${sourceLayer.name}" may not import layer "${targetLayer.name}" ($uriString)',
                ),
              );
            }
          }
        }
      }
    }

    if (sourceLayer != null) {
      final forbiddenIds = config.forbiddenIdentifiers[sourceLayer.name];
      if (forbiddenIds != null && forbiddenIds.isNotEmpty) {
        final visitor = _IdentifierCheckerVisitor(
          filePath: relativeToRoot,
          forbidden: forbiddenIds,
          violations: violations,
        );
        parsed.unit.accept(visitor);
      }
    }
  }

  return violations;
}

void main() {
  group('Layering & Architecture Rules', () {
    late ArchitectureConfig config;
    final packageRoot = Directory.current.path;

    setUpAll(() {
      final yamlFile = File(p.join(packageRoot, 'architecture.yaml'));
      final yaml = loadYaml(yamlFile.readAsStringSync()) as YamlMap;
      config = ArchitectureConfig.fromYaml(yaml);
    });

    test('All source code respects architecture and layering matrix', () {
      final violations = validateArchitecture(
        config: config,
        packageRoot: packageRoot,
      );
      expect(
        violations,
        isEmpty,
        reason: violations.map((v) => v.toString()).join('\n'),
      );
    });

    test('Negative fixture: widget importing core fails layer check', () {
      final fixturePath = p.join(
        packageRoot,
        'test',
        'architecture',
        'fixtures',
        'widget_importing_core',
      );
      final violations = validateArchitecture(
        config: config,
        packageRoot: packageRoot,
        customSourceRoot: fixturePath,
      );
      expect(
        violations.any((v) =>
            v.violationType == 'layer_forbidden_import' ||
            v.violationType == 'layer_direction'),
        isTrue,
      );
    });

    test('Negative fixture: cubit importing flutter fails layer check', () {
      final fixturePath = p.join(
        packageRoot,
        'test',
        'architecture',
        'fixtures',
        'cubit_importing_flutter',
      );
      final violations = validateArchitecture(
        config: config,
        packageRoot: packageRoot,
        customSourceRoot: fixturePath,
      );
      expect(
        violations.any((v) => v.violationType == 'layer_forbidden_import'),
        isTrue,
      );
    });

    test('Negative fixture: presentation using Platform fails identifier check', () {
      final fixturePath = p.join(
        packageRoot,
        'test',
        'architecture',
        'fixtures',
        'presentation_using_platform',
      );
      final violations = validateArchitecture(
        config: config,
        packageRoot: packageRoot,
        customSourceRoot: fixturePath,
      );
      expect(
        violations.any((v) => v.violationType == 'forbidden_identifier'),
        isTrue,
      );
    });

    test('Negative fixture: undeclared layer folder fails check', () {
      final fixturePath = p.join(
        packageRoot,
        'test',
        'architecture',
        'fixtures',
        'undeclared_layer',
      );
      final violations = validateArchitecture(
        config: config,
        packageRoot: packageRoot,
        customSourceRoot: fixturePath,
      );
      expect(
        violations.any((v) => v.violationType == 'undeclared_layer'),
        isTrue,
      );
    });
  });
}
