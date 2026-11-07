import 'dart:io';

import 'package:pseudolearn_app/domain/model/export/export_result.dart';
import 'package:pseudolearn_app/domain/model/execution/output_line.dart';
import 'package:pseudolearn_app/domain/model/export/target_language_id.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';

import '../../../fakes/native_test_engine.dart';

String engineOutput(String source, [List<String> inputs = const []]) {
  final execution = nativeTestEngine.createProgramExecution();
  final pending = [...inputs];
  var step = execution.startExecution(
    sourceCode: source,
    profileId: SyntaxProfileId.classicSpanish,
    languageId: UiLanguageId.spanish,
  );
  var guard = 0;
  while (!step.isFinished && guard++ < 10000) {
    final wait = step.inputWait;
    if (wait != null) {
      if (pending.isEmpty) return 'ENGINE-AWAITS-INPUT';
      step = execution.provideInput(wait, pending.removeAt(0));
      continue;
    }
    if (step.isHalted) break;
    step = execution.step();
  }
  if (!step.isFinished) return 'ENGINE-DID-NOT-FINISH';
  return execution.outputLines
      .where((line) => line.kind != OutputLineKind.userInputEcho)
      .map((line) => line.text)
      .join('\n');
}

String? exportedCode(String source, TargetLanguageId target) {
  final result = nativeTestEngine.programExporter.export(
    sourceCode: source,
    targetLanguage: target,
    profileId: SyntaxProfileId.classicSpanish,
  );
  return result is ExportSuccess ? result.program.sourceCode : null;
}

String runTarget(
  String code,
  TargetLanguageId target, [
  List<String> inputs = const [],
]) {
  final directory = Directory.systemTemp.createTempSync('pseudolearn_export_');
  try {
    final stdin = File('${directory.path}/stdin.txt')
      ..writeAsStringSync(inputs.map((line) => '$line\n').join());
    return switch (target) {
      TargetLanguageId.python => _python(directory, code, stdin),
      TargetLanguageId.rust => _rust(directory, code, stdin),
    };
  } finally {
    directory.deleteSync(recursive: true);
  }
}

ProcessResult _withStdin(
  String executable,
  List<String> arguments,
  File stdin,
) => Process.runSync('/bin/sh', [
  '-c',
  r'f="$1"; shift; exec "$@" < "$f"',
  'sh',
  stdin.path,
  executable,
  ...arguments,
]);

String _python(Directory directory, String code, File stdin) {
  final file = File('${directory.path}/main.py')..writeAsStringSync(code);
  final run = _withStdin('python3', ['-I', file.path], stdin);
  return run.exitCode == 0
      ? _normalise(run.stdout as String)
      : 'PYTHON-FAILED: ${run.stderr}';
}

String _rust(Directory directory, String code, File stdin) {
  final file = File('${directory.path}/main.rs')..writeAsStringSync(code);
  final build = Process.runSync('rustc', [
    '--edition=2021',
    '-A',
    'warnings',
    '-o',
    '${directory.path}/main',
    file.path,
  ]);
  if (build.exitCode != 0) return 'RUSTC-FAILED: ${build.stderr}';
  final run = _withStdin('${directory.path}/main', const [], stdin);
  return run.exitCode == 0
      ? _normalise(run.stdout as String)
      : 'RUST-RUN-FAILED: ${run.stderr}';
}

String _normalise(String output) =>
    output.endsWith('\n') ? output.substring(0, output.length - 1) : output;

String? pythonVersionProblem() {
  final run = Process.runSync('python3', ['--version']);
  return run.exitCode == 0 ? null : 'python3 unavailable';
}
