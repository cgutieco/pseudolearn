import 'dart:io';

import 'package:pseudolearn_app/domain/model/export/export_result.dart';
import 'package:pseudolearn_app/domain/model/export/target_language_id.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';

import '../../../fakes/native_test_engine.dart';

String engineOutput(String source) {
  final execution = nativeTestEngine.createProgramExecution();
  var step = execution.startExecution(
    sourceCode: source,
    profileId: SyntaxProfileId.classicSpanish,
    languageId: UiLanguageId.spanish,
  );
  var guard = 0;
  while (!step.isFinished && !step.isHalted && guard++ < 10000) {
    step = execution.step();
  }
  if (!step.isFinished) return 'ENGINE-DID-NOT-FINISH';
  return execution.outputLines.map((line) => line.text).join('\n');
}

String? exportedCode(String source, TargetLanguageId target) {
  final result = nativeTestEngine.programExporter.export(
    sourceCode: source,
    targetLanguage: target,
    profileId: SyntaxProfileId.classicSpanish,
  );
  return result is ExportSuccess ? result.program.sourceCode : null;
}

String runTarget(String code, TargetLanguageId target) {
  final directory = Directory.systemTemp.createTempSync('pseudolearn_export_');
  try {
    return switch (target) {
      TargetLanguageId.python => _python(directory, code),
      TargetLanguageId.rust => _rust(directory, code),
    };
  } finally {
    directory.deleteSync(recursive: true);
  }
}

String _python(Directory directory, String code) {
  final file = File('${directory.path}/main.py')..writeAsStringSync(code);
  final run = Process.runSync('python3', ['-I', file.path]);
  return run.exitCode == 0
      ? _normalise(run.stdout as String)
      : 'PYTHON-FAILED: ${run.stderr}';
}

String _rust(Directory directory, String code) {
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
  final run = Process.runSync('${directory.path}/main', const []);
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
