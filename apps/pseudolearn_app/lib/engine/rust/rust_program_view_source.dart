import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/settings/ui_language_id.dart';
import 'rust_analysis_api.dart';
import 'rust_profile_name.dart';
import 'rust_program_view.dart';
import 'rust_program_view_read_result.dart';
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
  }) => loadResult(
    sourceCode: sourceCode,
    profileId: profileId,
    languageId: languageId,
    rejects: _anyError,
  ).view;

  RustProgramViewReadResult loadResult({
    required String sourceCode,
    required SyntaxProfileId profileId,
    UiLanguageId languageId = UiLanguageId.spanish,
    bool Function(Map<String, Object?>) rejects = _anyError,
  }) => _load(sourceCode, profileId, languageId, rejects: rejects);

  RustProgramView? loadStructure({
    required String sourceCode,
    required SyntaxProfileId profileId,
    UiLanguageId languageId = UiLanguageId.spanish,
  }) => loadResult(
    sourceCode: sourceCode,
    profileId: profileId,
    languageId: languageId,
    rejects: _syntaxError,
  ).view;

  RustProgramViewReadResult _load(
    String sourceCode,
    SyntaxProfileId profileId,
    UiLanguageId languageId, {
    required bool Function(Map<String, Object?>) rejects,
  }) {
    final analysis = _analyze(
      sourceCode,
      profileId,
      languageId,
      rejects: rejects,
    );
    return _release(analysis.$1, analysis.$2);
  }

  (RustAnalysisHandle?, RustProgramViewReadResult) _analyze(
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
      return (handle, _readView(handle, sourceCode, rejects: rejects));
    } on RustBridgeFailure {
      return (
        handle,
        _transportFailure(RustProgramViewReadFailureKind.bridgeFailure),
      );
    } on TypeError {
      return (
        handle,
        _transportFailure(RustProgramViewReadFailureKind.malformedField),
      );
    } on FormatException {
      return (
        handle,
        _transportFailure(RustProgramViewReadFailureKind.malformedField),
      );
    }
  }

  RustProgramViewReadResult _readView(
    RustAnalysisHandle handle,
    String sourceCode, {
    required bool Function(Map<String, Object?>) rejects,
  }) {
    final report = _analysis.report(handle);
    final failure = _analysisReportFailure(report);
    if (failure != null) return failure;
    if (report['tree'] != true || _hasRejectedDiagnostic(report, rejects)) {
      return const RustProgramViewReadFailure(
        kind: RustProgramViewReadFailureKind.analysisRejected,
        path: 'analysis',
      );
    }
    return RustProgramView.decode(
      _analysis.programView(handle),
      SourceOffsetIndex(sourceCode),
    );
  }

  RustProgramViewReadResult _release(
    RustAnalysisHandle? handle,
    RustProgramViewReadResult result,
  ) {
    if (handle == null) return result;
    try {
      _analysis.release(handle);
      return result;
    } on RustBridgeFailure {
      return const RustProgramViewReadFailure(
        kind: RustProgramViewReadFailureKind.bridgeFailure,
        path: 'release',
      );
    } on TypeError {
      return const RustProgramViewReadFailure(
        kind: RustProgramViewReadFailureKind.malformedField,
        path: 'release',
      );
    }
  }
}

RustProgramViewReadFailure _transportFailure(
  RustProgramViewReadFailureKind kind,
) => RustProgramViewReadFailure(kind: kind, path: 'transport');

RustProgramViewReadFailure? _analysisReportFailure(
  Map<String, Object?> report,
) {
  if (!report.containsKey('tree')) {
    return const RustProgramViewReadFailure(
      kind: RustProgramViewReadFailureKind.missingField,
      path: 'analysis.tree',
    );
  }
  if (report['tree'] is! bool) {
    return const RustProgramViewReadFailure(
      kind: RustProgramViewReadFailureKind.malformedField,
      path: 'analysis.tree',
    );
  }
  if (!report.containsKey('diagnostics')) {
    return const RustProgramViewReadFailure(
      kind: RustProgramViewReadFailureKind.missingField,
      path: 'analysis.diagnostics',
    );
  }
  final diagnostics = report['diagnostics'];
  if (diagnostics is! List<Object?>) {
    return const RustProgramViewReadFailure(
      kind: RustProgramViewReadFailureKind.malformedField,
      path: 'analysis.diagnostics',
    );
  }
  for (var index = 0; index < diagnostics.length; index++) {
    if (diagnostics[index] is! Map<String, Object?>) {
      return RustProgramViewReadFailure(
        kind: RustProgramViewReadFailureKind.malformedField,
        path: 'analysis.diagnostics[$index]',
      );
    }
  }
  return null;
}

bool _hasRejectedDiagnostic(
  Map<String, Object?> report,
  bool Function(Map<String, Object?>) rejects,
) => (report['diagnostics'] as List<Object?>).cast<Map<String, Object?>>().any(
  rejects,
);

bool _anyError(Map<String, Object?> diagnostic) =>
    diagnostic['severity'] == 'error';

bool _syntaxError(Map<String, Object?> diagnostic) =>
    _anyError(diagnostic) && diagnostic['class'] != 'semantic';
