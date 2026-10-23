import '../../domain/model/help/help_query_result.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/settings/ui_language_id.dart';
import '../../domain/ports/syntax_help_source.dart';
import 'rust_help_projection.dart';
import 'rust_profile_name.dart';
import 'rust_transport.dart';
import 'utf16_line_index.dart';

final class RustSyntaxHelpSource implements SyntaxHelpSource {
  final RustTransport _transport;

  const RustSyntaxHelpSource(this._transport);

  @override
  HelpQueryResult query({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
    required int cursorUtf16,
    required int revision,
  }) {
    final lines = Utf16LineIndex(sourceCode);
    final position = lines.positionAt(cursorUtf16);
    if (position == null) {
      return HelpQueryResult.invalidPosition(revision: revision);
    }
    int? resource;
    try {
      final opened = _open(sourceCode, profileId);
      resource = opened['resource'] as int;
      final response = _ask(opened, position, languageId);
      return projectHelpResponse(response, lines, revision);
    } on RustBridgeFailure catch (failure) {
      return failure.isUsage
          ? HelpQueryResult.invalidPosition(revision: revision)
          : HelpQueryResult.failure(revision: revision);
    } on Object {
      return HelpQueryResult.failure(revision: revision);
    } finally {
      _release(resource);
    }
  }

  Map<String, Object?> _open(String sourceCode, SyntaxProfileId profileId) =>
      _transport.call('open_edit_session', {
            'program': sourceCode,
            'profile': rustProfileName(profileId),
            'strictness': rustStrictness,
          })
          as Map<String, Object?>;

  Map<String, Object?> _ask(
    Map<String, Object?> opened,
    Utf16LinePosition position,
    UiLanguageId languageId,
  ) =>
      _transport.call('help_query', {
            'resource': opened['resource'],
            'revision': '${opened['revision']}',
            'position': {
              'line': position.line,
              'column': position.column,
              'unit': 'utf16',
            },
            'language': rustLocaleName(languageId) ?? 'es',
            'detail': 'full',
          })
          as Map<String, Object?>;

  void _release(int? resource) {
    if (resource == null) return;
    try {
      _transport.call('release', {'resource': resource});
    } on Object {
      return;
    }
  }
}
