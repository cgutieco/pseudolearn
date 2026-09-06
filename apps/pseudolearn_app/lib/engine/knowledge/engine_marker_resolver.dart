import 'package:pseudolearn_core/pseudolearn_core.dart';
import '../../domain/model/knowledge/content_marker.dart';
import '../../domain/model/knowledge/content_marker_kind.dart';
import '../../domain/model/knowledge/marker_resolution.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/settings/ui_language_id.dart';
import '../mapping/diagnostic_projection.dart';
import '../mapping/profile_catalog.dart';
import 'builtin_signature_text.dart';
import 'marker_vocabulary.dart';
import 'reference_tables.dart';

final class EngineMarkerResolver {
  const EngineMarkerResolver();

  MarkerResolution? resolve({
    required ContentMarker marker,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  }) {
    final profile = ProfileCatalog.toLanguageProfile(profileId);
    final vocabulary = MarkerVocabulary.of(languageId);
    return switch (marker.kind) {
      ContentMarkerKind.lexeme => _lexeme(profile, marker.argument),
      ContentMarkerKind.signature => _signature(profile, marker.argument),
      ContentMarkerKind.diagnostic =>
        _diagnostic(profile, languageId, marker.argument),
      ContentMarkerKind.table => referenceTable(
          identifier: marker.argument,
          profile: profile,
          vocabulary: vocabulary,
        ),
      ContentMarkerKind.example ||
      ContentMarkerKind.figure ||
      ContentMarkerKind.diagram =>
        null,
    };
  }

  MarkerResolution? _lexeme(LanguageProfile profile, String argument) {
    final tokenType = _tokenTypeNamed(argument);
    if (tokenType == null) return null;
    final entry = profile.reservedLexemes[tokenType];
    if (entry == null) return null;
    return ResolvedMarkerText(entry.canonicalLexeme);
  }

  MarkerResolution? _signature(LanguageProfile profile, String argument) {
    final function = _builtinNamed(argument);
    if (function == null) return null;
    return ResolvedMarkerText(builtinSignatureText(profile, function));
  }

  MarkerResolution? _diagnostic(
    LanguageProfile profile,
    UiLanguageId languageId,
    String argument,
  ) {
    final code = _diagnosticCodeNamed(argument);
    if (code == null) return null;
    final locale = ProfileCatalog.toDiagnosticLocale(languageId);
    final template = DiagnosticCatalog.templateFor(code, locale);
    final coreSeverity = profile.severityPolicy[code] ?? Severity.error;
    final appSeverity = DiagnosticProjection.toAppSeverity(coreSeverity);
    final message = _renderDiagnosticMessage(template, code);
    return ResolvedMarkerDiagnostic(
      code: code.name,
      message: message,
      severity: appSeverity,
    );
  }

  DiagnosticCode? _diagnosticCodeNamed(String argument) {
    for (final code in DiagnosticCode.values) {
      if (code.name == argument) return code;
    }
    return null;
  }

  String _renderDiagnosticMessage(
    DiagnosticTemplate? template,
    DiagnosticCode code,
  ) {
    if (template == null) return code.name;
    if (template.requiredArguments.isEmpty) {
      return template.render(const {});
    }
    final placeholderValues = <String, String>{};
    for (final arg in template.requiredArguments) {
      placeholderValues[arg] = '...';
    }
    return template.render(placeholderValues);
  }

  TokenType? _tokenTypeNamed(String argument) {
    for (final tokenType in TokenType.values) {
      if (tokenType.name == argument) return tokenType;
    }
    return null;
  }

  BuiltinFunction? _builtinNamed(String argument) {
    for (final function in BuiltinFunction.values) {
      if (function.name == argument) return function;
    }
    return null;
  }
}
