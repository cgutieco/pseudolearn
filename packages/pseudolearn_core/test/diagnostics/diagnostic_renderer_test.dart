import 'package:pseudolearn_core/src/diagnostics/diagnostic_catalog.dart';
import 'package:pseudolearn_core/src/diagnostics/diagnostic_locale.dart';
import 'package:pseudolearn_core/src/diagnostics/diagnostic_renderer.dart';
import 'package:pseudolearn_core/src/diagnostics/diagnostic_template.dart';
import 'package:pseudolearn_core/src/diagnostics/diagnostic_term_catalog.dart';
import 'package:pseudolearn_core/src/domain/diagnostic.dart';
import 'package:pseudolearn_core/src/domain/diagnostic_argument.dart';
import 'package:pseudolearn_core/src/domain/diagnostic_code.dart';
import 'package:pseudolearn_core/src/domain/position.dart';
import 'package:pseudolearn_core/src/domain/primitive_type.dart';
import 'package:pseudolearn_core/src/domain/profile/profiles/classic_spanish_profile.dart';
import 'package:pseudolearn_core/src/domain/profile/syntax_lexicon.dart';
import 'package:pseudolearn_core/src/domain/severity.dart';
import 'package:pseudolearn_core/src/domain/span.dart';
import 'package:pseudolearn_core/src/domain/token_type.dart';
import 'package:test/test.dart';

void main() {
  group('DiagnosticCatalog completeness', () {
    test('every declared DiagnosticCode has templates in all locales', () {
      for (final code in DiagnosticCode.values) {
        for (final locale in DiagnosticLocale.values) {
          final hasTemplate = DiagnosticCatalog.hasTemplateFor(code, locale);
          expect(
            hasTemplate,
            isTrue,
            reason:
                'DiagnosticCode.${code.name} must have a template for locale ${locale.name}',
          );
        }
      }
    });
  });

  group('DiagnosticTermCatalog', () {
    test('translates all DiagnosticTerm values in all locales', () {
      for (final term in DiagnosticTerm.values) {
        for (final locale in DiagnosticLocale.values) {
          final rendered = DiagnosticTermCatalog.termFor(term, locale);
          expect(rendered, isNotEmpty);
        }
      }
      expect(
        DiagnosticTermCatalog.termFor(DiagnosticTerm.subroutine, DiagnosticLocale.es),
        equals('subprograma'),
      );
      expect(
        DiagnosticTermCatalog.termFor(DiagnosticTerm.subroutine, DiagnosticLocale.en),
        equals('subroutine'),
      );
    });
  });

  group('DiagnosticRenderer', () {
    late SyntaxLexicon lexicon;
    late DiagnosticRenderer spanishRenderer;
    late DiagnosticRenderer englishRenderer;

    final dummySpan = Span(
      start: const Position(line: 1, column: 1, offset: 0),
      end: const Position(line: 1, column: 2, offset: 1),
    );

    setUp(() {
      lexicon = const ClassicSpanishProfile.strict();
      spanishRenderer = DiagnosticRenderer(
        locale: DiagnosticLocale.es,
        syntaxLexicon: lexicon,
      );
      englishRenderer = DiagnosticRenderer(
        locale: DiagnosticLocale.en,
        syntaxLexicon: lexicon,
      );
    });

    test('renders unrecognizedCharacter in Spanish and English', () {
      final diagnostic = Diagnostic(
        code: DiagnosticCode.unrecognizedCharacter,
        severity: Severity.error,
        span: dummySpan,
        arguments: const {
          'lexeme': LexemeDiagnosticArgument('@'),
        },
      );

      expect(
        spanishRenderer.render(diagnostic),
        equals('Carácter no reconocido: @'),
      );
      expect(
        englishRenderer.render(diagnostic),
        equals('Unrecognized character: @'),
      );
    });

    test('renders custom template with all argument types correctly', () {
      final originalTemplates = {
        DiagnosticLocale.es: DiagnosticCatalog.templateFor(
          DiagnosticCode.unrecognizedCharacter,
          DiagnosticLocale.es,
        )!,
        DiagnosticLocale.en: DiagnosticCatalog.templateFor(
          DiagnosticCode.unrecognizedCharacter,
          DiagnosticLocale.en,
        )!,
      };
      addTearDown(() {
        DiagnosticCatalog.register(
          DiagnosticCode.unrecognizedCharacter,
          originalTemplates,
        );
      });

      DiagnosticCatalog.register(
        DiagnosticCode.unrecognizedCharacter,
        {
          DiagnosticLocale.es: const DiagnosticTemplate(
            'El {term} {lexeme} de tipo {type} requiere {token} en pos {number}',
          ),
          DiagnosticLocale.en: const DiagnosticTemplate(
            'The {term} {lexeme} of type {type} requires {token} at pos {number}',
          ),
        },
      );

      final diagnostic = Diagnostic(
        code: DiagnosticCode.unrecognizedCharacter,
        severity: Severity.error,
        span: dummySpan,
        arguments: const {
          'term': TermDiagnosticArgument(DiagnosticTerm.function),
          'lexeme': LexemeDiagnosticArgument('suma'),
          'type': TypeDiagnosticArgument(PrimitiveType.integer),
          'token': TokenDiagnosticArgument(TokenType.semicolon),
          'number': NumberDiagnosticArgument(42),
        },
      );

      expect(
        spanishRenderer.render(diagnostic),
        equals('El función suma de tipo entero requiere ; en pos 42'),
      );
      expect(
        englishRenderer.render(diagnostic),
        equals('The function suma of type entero requires ; at pos 42'),
      );
    });

    test('renders formatted diagnostic with related spans in Spanish and English', () {
      final relatedSpan = Span(
        start: const Position(line: 5, column: 3, offset: 40),
        end: const Position(line: 5, column: 10, offset: 47),
      );

      final diagnostic = Diagnostic(
        code: DiagnosticCode.unrecognizedCharacter,
        severity: Severity.error,
        span: dummySpan,
        relatedSpans: [relatedSpan],
        arguments: const {
          'lexeme': LexemeDiagnosticArgument('@'),
        },
      );

      final renderedEs = spanishRenderer.renderFormatted(diagnostic);
      expect(renderedEs, contains('Carácter no reconocido: @'));
      expect(renderedEs, contains('nota: ubicación relacionada en línea 5, columna 3'));

      final renderedEn = englishRenderer.renderFormatted(diagnostic);
      expect(renderedEn, contains('Unrecognized character: @'));
      expect(renderedEn, contains('note: related location at line 5, column 3'));
    });

    test('renders formatted diagnostic without related spans returns main message', () {
      final diagnostic = Diagnostic(
        code: DiagnosticCode.unrecognizedCharacter,
        severity: Severity.error,
        span: dummySpan,
        arguments: const {
          'lexeme': LexemeDiagnosticArgument('@'),
        },
      );

      expect(
        spanishRenderer.renderFormatted(diagnostic),
        equals(spanishRenderer.render(diagnostic)),
      );
    });
  });
}
