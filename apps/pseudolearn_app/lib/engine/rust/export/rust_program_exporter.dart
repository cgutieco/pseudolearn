import '../../../domain/model/export/export_result.dart';
import '../../../domain/model/export/target_language_id.dart';
import '../../../domain/model/profiles/syntax_profile_id.dart';
import '../../../domain/ports/program_exporter.dart';
import '../rust_program_view_source.dart';
import '../rust_transport.dart';
import 'python_expression_rules.dart';
import 'python_shape_emitter.dart';
import 'rust_expression_rules.dart';
import 'rust_shape_emitter.dart';
import 'unit_shape_reader.dart';
import 'view_expression_writer.dart';

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
    final program = UnitShapeReader(view).read();
    return ExportSuccess(switch (targetLanguage) {
      TargetLanguageId.python => const PythonShapeEmitter().emit(
        program,
        ViewExpressionWriter(view, const PythonExpressionRules()),
      ),
      TargetLanguageId.rust => const RustShapeEmitter().emit(
        program,
        ViewExpressionWriter(view, const RustExpressionRules()),
      ),
    });
  }
}
