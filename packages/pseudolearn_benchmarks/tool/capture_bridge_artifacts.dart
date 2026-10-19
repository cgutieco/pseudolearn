import 'dart:convert';
import 'dart:io';

const int iosLimitBytes = 3 * 1024 * 1024;
const int wasmLimitBytes = 600 * 1024;

Future<void> main(List<String> arguments) async {
  final root = Directory.current.parent.parent;
  final output = outputFile(root, arguments);
  final report = await capture(root);
  await output.parent.create(recursive: true);
  await output.writeAsString(
    const JsonEncoder.withIndent('  ').convert(report),
  );
  stdout.writeln('Artifact report saved to ${output.path}');
  if (report['verdict'] != 'passed') exitCode = 1;
}

File outputFile(Directory root, List<String> arguments) {
  if (arguments.isEmpty) {
    return File(
      '${root.path}/packages/pseudolearn_spec/results/r8-artifact-size.json',
    );
  }
  if (arguments.length == 2 && arguments.first == '--output') {
    final path = arguments.last;
    return File(path.startsWith('/') ? path : '${root.path}/$path');
  }
  throw const FormatException(
    'Usage: dart run tool/capture_bridge_artifacts.dart [--output path]',
  );
}

Future<Map<String, Object?>> capture(Directory root) async {
  final iosPath =
      '${root.path}/apps/pseudolearn_app/build/ios/'
      'Release-iphoneos/native_assets/pseudolearn_bridge.framework/'
      'pseudolearn_bridge';
  final iosDsymPath =
      '${root.path}/apps/pseudolearn_app/build/ios/'
      'Release-iphoneos/native_assets/pseudolearn_bridge.framework.dSYM/'
      'Contents/Resources/DWARF/pseudolearn_bridge';
  final wasmPath =
      '${root.path}/packages/pseudolearn_engine/target/'
      'wasm-browser/pkg/pseudolearn_wasm_bg.wasm';
  final ios = await measureIos(root, iosPath, iosDsymPath);
  final wasm = await measureWasm(root, wasmPath);
  final dirty = await gitWorkingTreeIsDirty(root);
  final passed = ios['withinLimit'] == true && wasm['withinLimit'] == true;
  return {
    'format': 'r8-artifact-size/1',
    'capturedAt': DateTime.now().toUtc().toIso8601String(),
    'gitHead': await commandText('git', ['-C', root.path, 'rev-parse', 'HEAD']),
    'workingTreeDirty': dirty,
    'toolchain': await toolchainVersions(),
    'artifacts': {'ios-arm64': ios, 'wasm32': wasm},
    'commands': [
      'flutter build ios --release --no-codesign',
      'bash tool/wasm.sh build',
      'dart run tool/capture_bridge_artifacts.dart',
    ],
    'verdict': passed ? 'passed' : 'failed',
  };
}

Future<Map<String, Object?>> measureIos(
  Directory root,
  String binaryPath,
  String symbolsPath,
) async {
  final binary = File(binaryPath);
  final symbols = File(symbolsPath);
  requireFile(binary);
  final details = await commandText('xcrun', ['lipo', '-info', binaryPath]);
  final binaryUuid = await commandText('xcrun', [
    'dwarfdump',
    '--uuid',
    binaryPath,
  ]);
  final symbolsUuid = symbols.existsSync()
      ? await commandText('xcrun', ['dwarfdump', '--uuid', symbolsPath])
      : '';
  final byteCount = await binary.length();
  final architectureMatches =
      details.contains('arm64') && !details.contains('x86_64');
  final symbolsMatch =
      symbolsUuid.isNotEmpty && uuidFrom(binaryUuid) == uuidFrom(symbolsUuid);
  return {
    'path': relativePath(root, binaryPath),
    'bytes': byteCount,
    'sha256': await sha256(binaryPath),
    'architecture': architectureMatches ? 'arm64' : details,
    'limitBytes': iosLimitBytes,
    'withinLimit':
        isWithinBudget(byteCount, iosLimitBytes) &&
        architectureMatches &&
        symbolsMatch,
    'detachedDebugSymbols': symbolsMatch,
    'uuid': uuidFrom(binaryUuid),
  };
}

Future<Map<String, Object?>> measureWasm(
  Directory root,
  String binaryPath,
) async {
  final binary = File(binaryPath);
  requireFile(binary);
  final byteCount = await binary.length();
  final compressed = await brotliArtifact(binaryPath);
  return {
    'path': relativePath(root, binaryPath),
    'bytes': byteCount,
    'sha256': await sha256(binaryPath),
    'compression': {
      'format': 'brotli',
      'quality': 11,
      'window': 22,
      'bytes': compressed['bytes'],
      'sha256': compressed['sha256'],
    },
    'limitBytes': wasmLimitBytes,
    'withinLimit': isWithinBudget(compressed['bytes'] as int, wasmLimitBytes),
  };
}

Future<Map<String, Object>> brotliArtifact(String binaryPath) async {
  final directory = await Directory.systemTemp.createTemp('r8-artifacts-');
  final compressed = File('${directory.path}/module.br');
  try {
    await requireSuccess('brotli', [
      '-q',
      '11',
      '-w',
      '22',
      '-o',
      compressed.path,
      binaryPath,
    ]);
    return {
      'bytes': await compressed.length(),
      'sha256': await sha256(compressed.path),
    };
  } finally {
    await directory.delete(recursive: true);
  }
}

Future<Map<String, String>> toolchainVersions() async {
  final flutter = jsonDecode(
    await commandText('flutter', ['--version', '--machine']),
  ) as Map<String, dynamic>;
  return {
    'flutter': '${flutter['frameworkVersion']}',
    'dart': '${flutter['dartSdkVersion']}',
    'rustc': await commandText('rustc', ['--version']),
    'wasmBindgen': await commandText('wasm-bindgen', ['--version']),
    'brotli': await commandText('brotli', ['--version']),
  };
}

Future<bool> gitWorkingTreeIsDirty(Directory root) async {
  final status = await commandText('git', [
    '-C',
    root.path,
    'status',
    '--porcelain',
  ]);
  return status.isNotEmpty;
}

Future<String> sha256(String path) async {
  final result = await requireSuccess('shasum', ['-a', '256', path]);
  return (result.stdout as String).trim().split(RegExp(r'\s+')).first;
}

Future<String> commandText(String executable, List<String> arguments) async {
  final result = await requireSuccess(executable, arguments);
  return (result.stdout as String).trim();
}

Future<ProcessResult> requireSuccess(
  String executable,
  List<String> arguments,
) async {
  final result = await Process.run(executable, arguments);
  if (result.exitCode != 0) {
    throw ProcessException(
      executable,
      arguments,
      '${result.stderr}',
      result.exitCode,
    );
  }
  return result;
}

void requireFile(File file) {
  if (!file.existsSync()) {
    throw FileSystemException('Missing build artifact', file.path);
  }
}

String relativePath(Directory root, String path) =>
    path.replaceFirst('${root.path}/', '');

String uuidFrom(String output) =>
    RegExp(r'[0-9A-F-]{36}').firstMatch(output)?.group(0) ?? '';

bool isWithinBudget(int bytes, int limitBytes) => bytes <= limitBytes;
