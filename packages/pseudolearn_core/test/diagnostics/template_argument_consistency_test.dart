import 'package:pseudolearn_core/src/diagnostics/diagnostic_catalog.dart';
import 'package:pseudolearn_core/src/diagnostics/diagnostic_locale.dart';
import 'package:pseudolearn_core/src/domain/diagnostic_code.dart';
import 'package:test/test.dart';

void main() {
  group('Diagnostic template consistency audit', () {
    final placeholderRegex = RegExp(r'\{([a-zA-Z0-9_]+)\}');

    test('every DiagnosticCode has templates in all locales with exact argument parity', () {
      for (final code in DiagnosticCode.values) {
        final esTemplate = DiagnosticCatalog.templateFor(code, DiagnosticLocale.es);
        final enTemplate = DiagnosticCatalog.templateFor(code, DiagnosticLocale.en);

        expect(
          esTemplate,
          isNotNull,
          reason: 'DiagnosticCode.${code.name} must have a Spanish template',
        );
        expect(
          enTemplate,
          isNotNull,
          reason: 'DiagnosticCode.${code.name} must have an English template',
        );

        final esPlaceholders = placeholderRegex
            .allMatches(esTemplate!.pattern)
            .map((m) => m.group(1)!)
            .toSet();
        final enPlaceholders = placeholderRegex
            .allMatches(enTemplate!.pattern)
            .map((m) => m.group(1)!)
            .toSet();

        expect(
          esTemplate.requiredArguments,
          equals(esPlaceholders),
          reason:
              'DiagnosticCode.${code.name} (ES) requiredArguments must match placeholders in pattern "${esTemplate.pattern}"',
        );

        expect(
          enTemplate.requiredArguments,
          equals(enPlaceholders),
          reason:
              'DiagnosticCode.${code.name} (EN) requiredArguments must match placeholders in pattern "${enTemplate.pattern}"',
        );

        expect(
          esPlaceholders,
          equals(enPlaceholders),
          reason:
              'DiagnosticCode.${code.name} must have identical placeholders in ES and EN (got ES: $esPlaceholders, EN: $enPlaceholders)',
        );
      }
    });
  });
}
