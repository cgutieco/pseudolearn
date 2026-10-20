import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/settings/ui_language_id.dart';
import 'rust_analysis_api.dart';
import 'rust_profile_name.dart';
import 'rust_program_view.dart';
import 'rust_transport.dart';
import 'source_offset_index.dart';

final class RustProgramViewSource {
  final RustAnalysisApi _analysis;

  RustProgramViewSource(RustTransport transport)
    : _analysis = RustAnalysisApi(transport);

  RustProgramView? load({
    required String sourceCode,
    required SyntaxProfileId profileId,
    UiLanguageId languageId = UiLanguageId.spanish,
  }) {
    return _load(sourceCode, profileId, languageId, rejects: _anyError);
  }

  RustProgramView? loadStructure({
    required String sourceCode,
    required SyntaxProfileId profileId,
    UiLanguageId languageId = UiLanguageId.spanish,
  }) => _load(sourceCode, profileId, languageId, rejects: _syntaxError);

  RustProgramView? _load(
    String sourceCode,
    SyntaxProfileId profileId,
    UiLanguageId languageId, {
    required bool Function(Map<String, Object?>) rejects,
  }) {
    RustAnalysisHandle? handle;
    try {
      handle = _analysis.open(
        source: sourceCode,
        profile: rustProfileName(profileId),
        locale: rustLocaleName(languageId),
      );
      final report = _analysis.report(handle);
      final diagnostics = (report['diagnostics'] as List<Object?>)
          .cast<Map<String, Object?>>();
      if (report['tree'] != true || diagnostics.any(rejects)) {
        return null;
      }
      return RustProgramView.fromJson(
        _analysis.programView(handle),
        SourceOffsetIndex(sourceCode),
      );
    } on RustBridgeFailure {
      return null;
    } finally {
      if (handle != null) _analysis.release(handle);
    }
  }
}

bool _anyError(Map<String, Object?> diagnostic) =>
    diagnostic['severity'] == 'error';

bool _syntaxError(Map<String, Object?> diagnostic) =>
    _anyError(diagnostic) && diagnostic['class'] != 'semantic';
