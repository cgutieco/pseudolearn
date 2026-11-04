import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/settings/ui_language_id.dart';
import 'rust_analysis_api.dart';
import 'rust_execution_readers.dart';
import 'rust_profile_name.dart';
import 'rust_program_view.dart';
import 'rust_program_view_read_result.dart';
import 'source_offset_index.dart';

final class RustOpenedProgram {
  final RustAnalysisHandle handle;
  final SourceOffsetIndex offsets;
  final RustProgramView view;

  const RustOpenedProgram({
    required this.handle,
    required this.offsets,
    required this.view,
  });
}

final class RustExecutionOpening {
  final RustAnalysisApi _analysis;

  const RustExecutionOpening(this._analysis);

  RustOpenedProgram? open({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  }) {
    final handle = _analysis.open(
      source: sourceCode,
      profile: rustProfileName(profileId),
      locale: rustLocaleName(languageId),
    );
    if (!isExecutableReport(_analysis.report(handle))) {
      _analysis.release(handle);
      return null;
    }
    final offsets = SourceOffsetIndex(sourceCode);
    final viewResult = RustProgramView.decode(
      _analysis.programView(handle),
      offsets,
    );
    if (viewResult is! RustProgramViewReadSuccess) {
      _analysis.release(handle);
      return null;
    }
    return RustOpenedProgram(
      handle: handle,
      offsets: offsets,
      view: viewResult.view,
    );
  }
}
