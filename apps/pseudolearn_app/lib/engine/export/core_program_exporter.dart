import '../../domain/model/export/export_result.dart';
import '../../domain/model/export/target_language_id.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/ports/program_exporter.dart';
import '../analysis/analysis_cache.dart';
import 'python_code_emitter.dart';
import 'rust_code_emitter.dart';

final class CoreProgramExporter implements ProgramExporter {
  final AnalysisCache _analyses;

  CoreProgramExporter({AnalysisCache? analyses})
      : _analyses = analyses ?? AnalysisCache();

  @override
  ExportResult export({
    required String sourceCode,
    required TargetLanguageId targetLanguage,
    required SyntaxProfileId profileId,
  }) {
    final analysis = _analyses.of(sourceCode, profileId);
    final unit = analysis.sourceUnit;
    if (unit == null || !analysis.isExecutable) {
      return const ExportAnalysisError();
    }

    return ExportSuccess(switch (targetLanguage) {
      TargetLanguageId.python => const PythonCodeEmitter()
          .emit(unit, targetLanguage, resolution: analysis.resolution),
      TargetLanguageId.rust => const RustCodeEmitter()
          .emit(unit, targetLanguage, resolution: analysis.resolution),
    });
  }
}
