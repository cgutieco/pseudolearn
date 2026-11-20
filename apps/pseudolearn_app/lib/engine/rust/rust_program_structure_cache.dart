import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/settings/ui_language_id.dart';
import 'rust_program_view.dart';
import 'rust_program_view_read_result.dart';
import 'rust_program_view_source.dart';
import 'rust_transport.dart';

typedef _StructureKey = ({
  String sourceCode,
  SyntaxProfileId profileId,
  UiLanguageId languageId,
});

final class RustProgramStructureCache {
  final RustProgramViewSource _views;
  _StructureKey? _lastKey;
  RustProgramView? _lastView;

  RustProgramStructureCache(RustTransport transport)
    : _views = RustProgramViewSource(transport);

  RustProgramView? loadStructure({
    required String sourceCode,
    required SyntaxProfileId profileId,
    UiLanguageId languageId = UiLanguageId.spanish,
  }) {
    final key = (
      sourceCode: sourceCode,
      profileId: profileId,
      languageId: languageId,
    );
    if (key == _lastKey) return _lastView;
    final result = _views.loadStructureResult(
      sourceCode: sourceCode,
      profileId: profileId,
      languageId: languageId,
    );
    _remember(key, result);
    return result.view;
  }

  void _remember(_StructureKey key, RustProgramViewReadResult result) {
    final isSettled = switch (result) {
      RustProgramViewReadSuccess() => true,
      RustProgramViewReadFailure(:final kind) =>
        kind == RustProgramViewReadFailureKind.analysisRejected,
    };
    _lastKey = isSettled ? key : null;
    _lastView = result.view;
  }
}
