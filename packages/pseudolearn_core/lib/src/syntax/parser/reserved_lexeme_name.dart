import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_argument.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/lexeme_shape.dart';
import '../../domain/severity.dart';
import '../../domain/token.dart';
import '../../domain/token_type.dart';

final class ReservedLexemeName {
  const ReservedLexemeName._();

  static bool standsWhereNameIsRequired(
    Token token, {
    Set<TokenType> continuesWith = const {},
  }) =>
      token.type.isReserved &&
      !continuesWith.contains(token.type) &&
      LexemeShape.isWord(token.lexeme);

  static Diagnostic diagnosticFor(Token token) => Diagnostic(
        code: DiagnosticCode.reservedLexemeUsedAsName,
        severity: Severity.error,
        span: token.span,
        arguments: {
          'lexeme': LexemeDiagnosticArgument(token.lexeme),
          'token': TokenDiagnosticArgument(token.type),
        },
      );
}
