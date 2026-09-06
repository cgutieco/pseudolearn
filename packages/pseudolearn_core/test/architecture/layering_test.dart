import 'dart:io';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

final class LayerRule {
  final int id;
  final String name;
  final String path;
  final Set<String> mayImport;

  const LayerRule({
    required this.id,
    required this.name,
    required this.path,
    required this.mayImport,
  });
}

final class ArchitectureConfig {
  final String packageName;
  final String sourceRoot;
  final String publicEntrypoint;
  final List<LayerRule> layers;
  final List<String> forbiddenImports;
  final bool forbidSelfPackageImports;

  const ArchitectureConfig({
    required this.packageName,
    required this.sourceRoot,
    required this.publicEntrypoint,
    required this.layers,
    required this.forbiddenImports,
    required this.forbidSelfPackageImports,
  });

  factory ArchitectureConfig.fromYaml(YamlMap yaml) {
    final layerList = <LayerRule>[];
    for (final layerMap in yaml['layers'] as YamlList) {
      final map = layerMap as YamlMap;
      final mayImportList = (map['may_import'] as YamlList?)
              ?.map((entry) => entry.toString())
              .toSet() ??
          <String>{};

      layerList.add(
        LayerRule(
          id: map['id'] as int,
          name: map['name'] as String,
          path: map['path'] as String,
          mayImport: mayImportList,
        ),
      );
    }

    final forbidden = (yaml['forbidden_imports'] as YamlList?)
            ?.map((entry) => entry.toString())
            .toList() ??
        const <String>[];

    return ArchitectureConfig(
      packageName: yaml['package'] as String,
      sourceRoot: yaml['source_root'] as String,
      publicEntrypoint: yaml['public_entrypoint'] as String,
      layers: layerList,
      forbiddenImports: forbidden,
      forbidSelfPackageImports:
          yaml['forbid_self_package_imports'] as bool? ?? false,
    );
  }

  LayerRule? layerForPath(String relativePath) {
    final normalized = p.normalize(relativePath);
    for (final layer in layers) {
      if (normalized == layer.path ||
          normalized.startsWith('${layer.path}/') ||
          normalized.startsWith('${layer.path}\\')) {
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

  for (final entity in sourceRootDir.listSync(recursive: false)) {
    if (entity is Directory) {
      final dirName = p.basename(entity.path);
      final isDeclared = config.layers.any((layer) => layer.path == dirName);
      if (!isDeclared) {
        violations.add(
          ArchitectureViolation(
            filePath: p.relative(entity.path, from: packageRoot),
            violationType: 'undeclared_layer_folder',
            message:
                'Directory $dirName in source root is not a declared layer',
          ),
        );
      }
    }
  }

  for (final entity in sourceRootDir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final relativeToSource =
          p.relative(entity.path, from: sourceRootDir.path);
      final currentLayer = config.layerForPath(relativeToSource);

      if (currentLayer == null) {
        violations.add(
          ArchitectureViolation(
            filePath: p.relative(entity.path, from: packageRoot),
            violationType: 'file_in_undeclared_layer',
            message: 'File does not belong to any declared layer',
          ),
        );
        continue;
      }

      final content = entity.readAsStringSync();
      final parsed = parseString(content: content, throwIfDiagnostics: false);

      for (final directive in parsed.unit.directives) {
        final uri = switch (directive) {
          NamespaceDirective(:final uri) => uri.stringValue,
          PartDirective(:final uri) => uri.stringValue,
          _ => null,
        };

        if (uri == null) continue;

        _checkDirective(
          directive: directive,
          uri: uri,
          filePath: p.relative(entity.path, from: packageRoot),
          fileDir: entity.parent.path,
          sourceRootDir: sourceRootDir.path,
          currentLayer: currentLayer,
          config: config,
          violations: violations,
        );
      }
    }
  }

  return violations;
}

void _checkDirective({
  required Directive directive,
  required String uri,
  required String filePath,
  required String fileDir,
  required String sourceRootDir,
  required LayerRule currentLayer,
  required ArchitectureConfig config,
  required List<ArchitectureViolation> violations,
}) {
  for (final forbidden in config.forbiddenImports) {
    if (uri.startsWith(forbidden)) {
      violations.add(
        ArchitectureViolation(
          filePath: filePath,
          violationType: 'forbidden_platform_import',
          message: 'Directive imports forbidden uri "$uri"',
        ),
      );
    }
  }

  if (config.forbidSelfPackageImports &&
      uri.startsWith('package:${config.packageName}/')) {
    violations.add(
      ArchitectureViolation(
        filePath: filePath,
        violationType: 'forbidden_self_package_import',
        message: 'Internal files must use relative imports instead of "$uri"',
      ),
    );
  }

  if (uri.startsWith('.')) {
    final resolvedTarget = p.normalize(p.join(fileDir, uri));
    final relativeToSource = p.relative(resolvedTarget, from: sourceRootDir);

    if (relativeToSource.startsWith('..')) {
      violations.add(
        ArchitectureViolation(
          filePath: filePath,
          violationType: 'relative_escape',
          message: 'Relative import "$uri" escapes source root',
        ),
      );
      return;
    }

    final targetLayer = config.layerForPath(relativeToSource);
    if (targetLayer != null && targetLayer.id != currentLayer.id) {
      if (!currentLayer.mayImport.contains(targetLayer.name)) {
        final directiveKind =
            directive is ExportDirective ? 'export' : 'import';
        violations.add(
          ArchitectureViolation(
            filePath: filePath,
            violationType: 'illegal_layer_$directiveKind',
            message:
                'Layer "${currentLayer.name}" is forbidden to $directiveKind from layer "${targetLayer.name}"',
          ),
        );
      }
    }
  }
}

void main() {
  group('Architecture layering tests', () {
    late ArchitectureConfig config;
    late String packageRoot;

    setUpAll(() {
      packageRoot = Directory.current.path;
      final yamlFile = File(p.join(packageRoot, 'architecture.yaml'));
      final yaml = loadYaml(yamlFile.readAsStringSync()) as YamlMap;
      config = ArchitectureConfig.fromYaml(yaml);
    });

    test('real codebase adheres to layering rules with zero violations', () {
      final violations = validateArchitecture(
        config: config,
        packageRoot: packageRoot,
      );

      expect(
        violations,
        isEmpty,
        reason: 'Real codebase must have 0 architecture violations',
      );
    });

    test('all declared layers exist in lib/src/', () {
      for (final layer in config.layers) {
        final layerDir =
            Directory(p.join(packageRoot, config.sourceRoot, layer.path));
        expect(
          layerDir.existsSync(),
          isTrue,
          reason: 'Layer directory ${layer.path} must exist in lib/src/',
        );
      }
    });

    group('Negative verification fixtures', () {
      late Directory tempDir;
      late Directory tempSourceRoot;

      setUp(() {
        tempDir = Directory.systemTemp.createTempSync('layering_fixture_');
        tempSourceRoot = Directory(p.join(tempDir.path, 'lib', 'src'))
          ..createSync(recursive: true);

        for (final layer in config.layers) {
          Directory(p.join(tempSourceRoot.path, layer.path))
              .createSync(recursive: true);
        }
      });

      tearDown(() {
        tempDir.deleteSync(recursive: true);
      });

      test('detects illegal import of higher layer', () {
        final file =
            File(p.join(tempSourceRoot.path, 'domain', 'bad_import.dart'));
        file.writeAsStringSync("import '../syntax/token.dart';\n");

        final violations = validateArchitecture(
          config: config,
          packageRoot: tempDir.path,
          customSourceRoot: tempSourceRoot.path,
        );

        expect(
          violations.any((v) => v.violationType == 'illegal_layer_import'),
          isTrue,
          reason: 'Must flag domain importing syntax as illegal layer import',
        );
      });

      test('detects illegal export of higher layer', () {
        final file =
            File(p.join(tempSourceRoot.path, 'domain', 'bad_export.dart'));
        file.writeAsStringSync("export '../syntax/token.dart';\n");

        final violations = validateArchitecture(
          config: config,
          packageRoot: tempDir.path,
          customSourceRoot: tempSourceRoot.path,
        );

        expect(
          violations.any((v) => v.violationType == 'illegal_layer_export'),
          isTrue,
          reason: 'Must flag domain exporting syntax as illegal layer export',
        );
      });

      test('detects forbidden platform import (dart:io)', () {
        final file =
            File(p.join(tempSourceRoot.path, 'domain', 'io_import.dart'));
        file.writeAsStringSync("import 'dart:io';\n");

        final violations = validateArchitecture(
          config: config,
          packageRoot: tempDir.path,
          customSourceRoot: tempSourceRoot.path,
        );

        expect(
          violations.any((v) => v.violationType == 'forbidden_platform_import'),
          isTrue,
          reason: 'Must flag dart:io as forbidden platform import',
        );
      });

      test('detects forbidden self-package import', () {
        final file =
            File(p.join(tempSourceRoot.path, 'syntax', 'package_import.dart'));
        file.writeAsStringSync(
            "import 'package:pseudolearn_core/src/domain/span.dart';\n");

        final violations = validateArchitecture(
          config: config,
          packageRoot: tempDir.path,
          customSourceRoot: tempSourceRoot.path,
        );

        expect(
          violations
              .any((v) => v.violationType == 'forbidden_self_package_import'),
          isTrue,
          reason: 'Must flag package: self import inside src',
        );
      });

      test('detects relative escape escaping source root', () {
        final file =
            File(p.join(tempSourceRoot.path, 'domain', 'escape_import.dart'));
        file.writeAsStringSync("import '../../tool/check_limits.dart';\n");

        final violations = validateArchitecture(
          config: config,
          packageRoot: tempDir.path,
          customSourceRoot: tempSourceRoot.path,
        );

        expect(
          violations.any((v) => v.violationType == 'relative_escape'),
          isTrue,
          reason: 'Must flag relative imports that escape lib/src',
        );
      });

      test('detects undeclared layer directory in source root', () {
        Directory(p.join(tempSourceRoot.path, 'unknown_layer'))
            .createSync(recursive: true);

        final violations = validateArchitecture(
          config: config,
          packageRoot: tempDir.path,
          customSourceRoot: tempSourceRoot.path,
        );

        expect(
          violations.any((v) => v.violationType == 'undeclared_layer_folder'),
          isTrue,
          reason: 'Must flag unknown_layer folder as undeclared layer',
        );
      });
    });
  });
}
