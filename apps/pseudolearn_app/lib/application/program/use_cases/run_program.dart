import '../../../domain/model/program/program_run_report.dart';
import '../../../domain/model/program/program_run_request.dart';
import '../../../domain/ports/program_analyzer.dart';
import '../../../domain/ports/program_batch_runner.dart';

final class RunProgram {
  final ProgramAnalyzer _analyzer;
  final ProgramBatchRunner _runner;

  const RunProgram({
    required this._analyzer,
    required this._runner,
  });

  ProgramRunReport call(ProgramRunRequest request) {
    final report = _analyzer.analyze(
      sourceCode: request.sourceCode,
      profileId: request.profileId,
      languageId: request.languageId,
    );
    if (report.hasErrors || !report.isExecutable) {
      return ProgramRunReport(
        outcome: ProgramRunOutcome.notExecutable,
        outputs: const [],
        errors: [for (final diagnostic in report.diagnostics) diagnostic.message],
      );
    }
    try {
      return _runner.run(request);
    } catch (_) {
      return const ProgramRunReport(
        outcome: ProgramRunOutcome.halted,
        outputs: [],
      );
    }
  }
}
