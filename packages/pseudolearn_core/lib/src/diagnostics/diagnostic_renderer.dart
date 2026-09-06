import '../domain/diagnostic.dart';
import '../domain/diagnostic_argument.dart';
import '../domain/profile/syntax_lexicon.dart';
import 'diagnostic_catalog.dart';
import 'diagnostic_locale.dart';
import 'diagnostic_term_catalog.dart';

final class DiagnosticRenderer {
  final DiagnosticLocale locale;
  final SyntaxLexicon syntaxLexicon;

  const DiagnosticRenderer({
    required this.locale,
    required this.syntaxLexicon,
  });

  String render(Diagnostic diagnostic) {
    final template = DiagnosticCatalog.templateFor(diagnostic.code, locale);
    if (template == null) {
      return '[${diagnostic.code.name}]';
    }

    final formattedArguments = <String, String>{};
    for (final entry in diagnostic.arguments.entries) {
      formattedArguments[entry.key] = _formatArgument(entry.value);
    }

    return template.render(formattedArguments);
  }

  String renderFormatted(Diagnostic diagnostic) {
    final message = render(diagnostic);
    if (diagnostic.relatedSpans.isEmpty) {
      return message;
    }

    final buffer = StringBuffer(message);
    for (final relatedSpan in diagnostic.relatedSpans) {
      buffer.write('\n');
      if (locale == DiagnosticLocale.es) {
        buffer.write(
          '  nota: ubicación relacionada en línea ${relatedSpan.start.line}, columna ${relatedSpan.start.column}',
        );
      } else {
        buffer.write(
          '  note: related location at line ${relatedSpan.start.line}, column ${relatedSpan.start.column}',
        );
      }
    }
    return buffer.toString();
  }

  String _formatArgument(DiagnosticArgument argument) => switch (argument) {
        TokenDiagnosticArgument(:final tokenType) =>
          syntaxLexicon.formatTokenType(tokenType),
        TypeDiagnosticArgument(:final type) =>
          syntaxLexicon.formatPrimitiveType(type),
        TermDiagnosticArgument(:final term) =>
          DiagnosticTermCatalog.termFor(term, locale),
        LexemeDiagnosticArgument(:final lexeme) => lexeme,
        NumberDiagnosticArgument(:final value) => value.toString(),
        IntegerValueDiagnosticArgument(:final value) => value.toString(),
      };
}
