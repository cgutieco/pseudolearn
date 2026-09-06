import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('Compilation Targets (JS & WASM)', () {
    late final String packageRoot;
    late final String targetScript;
    late final Directory tempDir;

    setUpAll(() {
      packageRoot = Directory.current.path;
      targetScript =
          p.join(packageRoot, 'example', 'pipeline_compilation_target.dart');
      tempDir =
          Directory.systemTemp.createTempSync('pseudolearn_compilation_test_');
    });

    tearDownAll(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('compilation target script exists in example/', () {
      expect(File(targetScript).existsSync(), isTrue);
    });

    test('executes pipeline compilation target natively with dart run', () {
      final result = Process.runSync(
        Platform.executable,
        ['run', targetScript],
        workingDirectory: packageRoot,
      );

      expect(result.exitCode, equals(0),
          reason: 'Native execution failed: ${result.stderr}\n${result.stdout}');
    });

    test('compiles pipeline compilation target to JavaScript (dart compile js)',
        () {
      final jsOutput = p.join(tempDir.path, 'target.js');
      final result = Process.runSync(
        Platform.executable,
        [
          'compile',
          'js',
          '-O1',
          '-o',
          jsOutput,
          targetScript,
        ],
        workingDirectory: packageRoot,
      );

      expect(result.exitCode, equals(0),
          reason:
              'JS compilation failed with exitCode ${result.exitCode}:\n${result.stderr}\n${result.stdout}');
      final file = File(jsOutput);
      expect(file.existsSync(), isTrue);
      expect(file.lengthSync(), greaterThan(1000));
    });

    test('compiles pipeline compilation target to WebAssembly (dart compile wasm)',
        () {
      final wasmOutput = p.join(tempDir.path, 'target.wasm');
      final result = Process.runSync(
        Platform.executable,
        [
          'compile',
          'wasm',
          '-o',
          wasmOutput,
          targetScript,
        ],
        workingDirectory: packageRoot,
      );

      expect(result.exitCode, equals(0),
          reason:
              'WASM compilation failed with exitCode ${result.exitCode}:\n${result.stderr}\n${result.stdout}');
      final wasmFile = File(wasmOutput);
      expect(wasmFile.existsSync(), isTrue);
      expect(wasmFile.lengthSync(), greaterThan(1000));
    });

    test('Negative fixture: invalid target fails compilation', () {
      final invalidScript = p.join(tempDir.path, 'invalid_target.dart');
      File(invalidScript).writeAsStringSync('''
void main() {
  invalidSyntax;;;
}
''');

      final jsOutput = p.join(tempDir.path, 'invalid.js');
      final result = Process.runSync(
        Platform.executable,
        ['compile', 'js', '-o', jsOutput, invalidScript],
        workingDirectory: packageRoot,
      );

      expect(result.exitCode, isNot(equals(0)));
    });
  });
}
