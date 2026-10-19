import '../../domain/model/analysis/app_diagnostic.dart';
import '../../domain/model/knowledge/content_marker.dart';
import '../../domain/model/knowledge/content_marker_kind.dart';
import '../../domain/model/knowledge/marker_resolution.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/settings/ui_language_id.dart';
import '../knowledge/marker_vocabulary.dart';
import 'rust_profile_name.dart';
import 'rust_reference_signatures.dart';
import 'rust_reference_vocabulary.dart';
import 'rust_transport.dart';

final class RustMarkerResolver {
  final RustTransport _transport;
  final RustReferenceVocabulary _vocabulary;

  RustMarkerResolver(RustTransport transport)
    : _transport = transport,
      _vocabulary = RustReferenceVocabulary(transport);

  MarkerResolution? resolve({
    required ContentMarker marker,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  }) {
    try {
      final data = _vocabulary.forProfile(profileId);
      return switch (marker.kind) {
        ContentMarkerKind.lexeme => _lexeme(data, marker.argument),
        ContentMarkerKind.signature => _signature(data, marker.argument),
        ContentMarkerKind.table => _table(data, marker.argument, languageId),
        ContentMarkerKind.diagnostic => _diagnostic(marker.argument, languageId),
        _ => null,
      };
    } on RustBridgeFailure {
      return null;
    }
  }

  MarkerResolution? _lexeme(RustReferenceData data, String identity) {
    final lexeme = data.keywords[identity];
    return lexeme == null ? null : ResolvedMarkerText(lexeme);
  }

  MarkerResolution? _signature(RustReferenceData data, String identity) {
    for (final entry in data.builtins) {
      if (entry.identity == identity) {
        return ResolvedMarkerText(signatureText(data, entry));
      }
    }
    return null;
  }

  MarkerResolution? _table(
    RustReferenceData data,
    String identifier,
    UiLanguageId languageId,
  ) {
    final vocabulary = MarkerVocabulary.of(languageId);
    return switch (identifier) {
      'primitiveTypes' => ResolvedMarkerTable(
        headers: [vocabulary.type],
        rows: [
          for (final type in primitiveTypeLexemes(data)) [type],
        ],
      ),
      'precedence' => ResolvedMarkerTable(
        headers: [
          vocabulary.level,
          vocabulary.operators,
          vocabulary.associativity,
        ],
        rows: precedenceRows(data, vocabulary),
      ),
      'builtinFunctions' => ResolvedMarkerTable(
        headers: [vocabulary.function, vocabulary.returns],
        rows: [
          for (final entry in data.builtins)
            [signatureText(data, entry), returnText(data, entry.returns)],
        ],
      ),
      _ => null,
    };
  }

  MarkerResolution? _diagnostic(String code, UiLanguageId languageId) {
    final response =
        _transport.call('diagnostic_template', {
              'code': code,
              'locale': languageId == UiLanguageId.english ? 'en' : 'es',
              'strictness': rustStrictness,
            })
            as Map<String, Object?>;
    final template = response['template'] as String;
    return ResolvedMarkerDiagnostic(
      code: response['code'] as String,
      message: _filled(template),
      severity: switch (response['severity']) {
        'error' => AppSeverity.error,
        'warning' => AppSeverity.warning,
        _ => AppSeverity.info,
      },
    );
  }

  String _filled(String template) {
    final buffer = StringBuffer();
    var inside = false;
    for (final character in template.split('')) {
      if (character == '{') buffer.write('...');
      if (!inside && character != '{') buffer.write(character);
      inside = _insideAfter(inside, character);
    }
    return buffer.toString();
  }

  bool _insideAfter(bool inside, String character) => switch (character) {
    '{' => true,
    '}' => false,
    _ => inside,
  };
}
