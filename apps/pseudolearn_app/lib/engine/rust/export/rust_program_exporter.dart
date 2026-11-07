import '../../../domain/model/export/export_result.dart';
import '../../../domain/model/export/target_language_id.dart';
import '../../../domain/model/profiles/syntax_profile_id.dart';
import '../../../domain/ports/program_exporter.dart';
import '../rust_program_view_source.dart';
import '../rust_transport.dart';
import 'export_coverage.dart';
import 'export_support.dart';
import 'python_expression_writer.dart';
import 'python_shape_emitter.dart';
import 'expression_types.dart';
import 'rust_expression_writer.dart';
import 'rust_helpers.dart';
import 'rust_shape_emitter.dart';
import 'unit_shape_reader.dart';

final class RustProgramExporter implements ProgramExporter {
  final RustProgramViewSource _views;

  RustProgramExporter(RustTransport transport)
    : _views = RustProgramViewSource(transport);

  @override
  ExportResult export({
    required String sourceCode,
    required TargetLanguageId targetLanguage,
    required SyntaxProfileId profileId,
  }) {
    final view = _views.load(sourceCode: sourceCode, profileId: profileId);
    if (view == null) return const ExportAnalysisError();
    final blockers = ExportCoverage(
      view,
      _supportOf(targetLanguage),
    ).blockers();
    if (blockers.isNotEmpty) return ExportUnavailable('', blockers: blockers);
    final program = UnitShapeReader(view).read();
    return ExportSuccess(switch (targetLanguage) {
      TargetLanguageId.python => const PythonShapeEmitter().emit(
        program,
        PythonExpressionWriter(view, ExpressionTypes.of(view)),
      ),
      TargetLanguageId.rust => const RustShapeEmitter().emit(
        program,
        RustExpressionWriter(view, ExpressionTypes.of(view), RustHelpers()),
      ),
    });
  }

  ExportSupport _supportOf(TargetLanguageId targetLanguage) =>
      switch (targetLanguage) {
        TargetLanguageId.python => pythonExportSupport,
        TargetLanguageId.rust => rustExportSupport,
      };
}
