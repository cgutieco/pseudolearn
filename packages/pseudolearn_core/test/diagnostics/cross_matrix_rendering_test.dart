import 'package:pseudolearn_core/src/diagnostics/diagnostic_catalog.dart';
import 'package:pseudolearn_core/src/diagnostics/diagnostic_locale.dart';
import 'package:pseudolearn_core/src/diagnostics/diagnostic_renderer.dart';
import 'package:pseudolearn_core/src/domain/diagnostic.dart';
import 'package:pseudolearn_core/src/domain/diagnostic_argument.dart';
import 'package:pseudolearn_core/src/domain/diagnostic_code.dart';
import 'package:pseudolearn_core/src/domain/position.dart';
import 'package:pseudolearn_core/src/domain/primitive_type.dart';
import 'package:pseudolearn_core/src/domain/profile/profiles/classic_spanish_profile.dart';
import 'package:pseudolearn_core/src/domain/profile/profiles/english_profile.dart';
import 'package:pseudolearn_core/src/domain/pseudo_integer.dart';
import 'package:pseudolearn_core/src/domain/severity.dart';
import 'package:pseudolearn_core/src/domain/span.dart';
import 'package:pseudolearn_core/src/domain/token_type.dart';
import 'package:test/test.dart';

void main() {
  group('Cross-matrix rendering audit (2 syntax profiles x 2 UI locales)', () {
    final dummySpan = Span(
      start: const Position(line: 1, column: 1, offset: 0),
      end: const Position(line: 1, column: 5, offset: 4),
    );

    const spanishProfile = ClassicSpanishProfile.strict();
    const englishProfile = EnglishProfile.strict();

    final unreplacedPlaceholderPattern = RegExp(r'\{[a-zA-Z0-9_]+\}');

    DiagnosticArgument createSampleArgument(String name, DiagnosticCode code) {
      return switch (name) {
        'lexeme' => const LexemeDiagnosticArgument('miIdentificador'),
        'type' => const TypeDiagnosticArgument(PrimitiveType.integer),
        'token' => const TokenDiagnosticArgument(TokenType.semicolon),
        'term' => const TermDiagnosticArgument(DiagnosticTerm.subroutine),
        'expected' => switch (code) {
            DiagnosticCode.argumentCountMismatch =>
              const NumberDiagnosticArgument(2),
            _ => const TypeDiagnosticArgument(PrimitiveType.integer),
          },
        'found' => switch (code) {
            DiagnosticCode.argumentCountMismatch =>
              const NumberDiagnosticArgument(3),
            DiagnosticCode.readValueTypeMismatch =>
              const LexemeDiagnosticArgument('abc'),
            _ => const TypeDiagnosticArgument(PrimitiveType.real),
          },
        'position' => const NumberDiagnosticArgument(5),
        'length' => const NumberDiagnosticArgument(3),
        'code' =>
          IntegerValueDiagnosticArgument(PseudoInteger.fromInt(65)),
        'index' => const NumberDiagnosticArgument(10),
        'size' => const NumberDiagnosticArgument(5),
        'exponent' =>
          IntegerValueDiagnosticArgument(PseudoInteger.fromInt(-3)),
        'limit' => const NumberDiagnosticArgument(100),
        'className' => const LexemeDiagnosticArgument('MiClase'),
        _ => LexemeDiagnosticArgument(name),
      };
    }

    Diagnostic createDiagnosticWithAllRequiredArgs(
      DiagnosticCode code,
      DiagnosticLocale locale,
    ) {
      final template = DiagnosticCatalog.templateFor(code, locale)!;
      final arguments = <String, DiagnosticArgument>{};
      for (final argName in template.requiredArguments) {
        arguments[argName] = createSampleArgument(argName, code);
      }
      return Diagnostic(
        code: code,
        severity: Severity.error,
        span: dummySpan,
        arguments: arguments,
      );
    }

    final renderers = <String, DiagnosticRenderer>{
      'Spanish Lexicon + Spanish UI': const DiagnosticRenderer(
        locale: DiagnosticLocale.es,
        syntaxLexicon: spanishProfile,
      ),
      'Spanish Lexicon + English UI': const DiagnosticRenderer(
        locale: DiagnosticLocale.en,
        syntaxLexicon: spanishProfile,
      ),
      'English Lexicon + Spanish UI': const DiagnosticRenderer(
        locale: DiagnosticLocale.es,
        syntaxLexicon: englishProfile,
      ),
      'English Lexicon + English UI': const DiagnosticRenderer(
        locale: DiagnosticLocale.en,
        syntaxLexicon: englishProfile,
      ),
    };

    for (final entry in renderers.entries) {
      final configurationName = entry.key;
      final renderer = entry.value;

      test('renders all 158 codes without raw placeholders under $configurationName', () {
        for (final code in DiagnosticCode.values) {
          final diagnostic = createDiagnosticWithAllRequiredArgs(
            code,
            renderer.locale,
          );
          final rendered = renderer.render(diagnostic);

          expect(
            rendered,
            isNotEmpty,
            reason: '${code.name} rendered empty under $configurationName',
          );
          expect(
            rendered,
            isNot(startsWith('[${code.name}]')),
            reason: '${code.name} fell back to missing template',
          );
          expect(
            unreplacedPlaceholderPattern.hasMatch(rendered),
            isFalse,
            reason:
                '${code.name} contains unreplaced placeholder under $configurationName: "$rendered"',
          );
        }
      });
    }

    test('profile keywords and types decouple from UI locale in cross-combinations', () {
      final diagWithPrimitiveType = Diagnostic(
        code: DiagnosticCode.inferredVariableType,
        severity: Severity.info,
        span: dummySpan,
        arguments: const {
          'lexeme': LexemeDiagnosticArgument('resultado'),
          'type': TypeDiagnosticArgument(PrimitiveType.integer),
        },
      );

      final spanishUiEnglishProfile = renderers['English Lexicon + Spanish UI']!;
      final englishUiSpanishProfile = renderers['Spanish Lexicon + English UI']!;

      final renderedEsEn = spanishUiEnglishProfile.render(diagWithPrimitiveType);
      final renderedEnEs = englishUiSpanishProfile.render(diagWithPrimitiveType);

      expect(renderedEsEn, contains('Tipo inferido para resultado: integer'));
      expect(renderedEnEs, contains('Inferred type for resultado: entero'));
    });
  });
}
