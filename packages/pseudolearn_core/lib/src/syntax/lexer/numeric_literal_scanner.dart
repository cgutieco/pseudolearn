import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_argument.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/position.dart';
import '../../domain/pseudo_integer.dart';
import '../../domain/severity.dart';
import '../../domain/token.dart';
import '../../domain/token_type.dart';
import 'character_scanner.dart';

final class NumericLiteralScanner {
  const NumericLiteralScanner();

  void scan(
    CharacterScanner scanner,
    List<Token> tokens,
    List<Diagnostic> diagnostics,
  ) {
    final start = scanner.currentPosition;
    final buffer = StringBuffer();

    while (_isDigit(scanner.peek())) {
      buffer.write(scanner.advance());
    }

    if (scanner.peek() == '.' && _isDigit(scanner.peekAhead(1))) {
      _finishRealLiteral(scanner, start, buffer, tokens);
      return;
    }

    final outcome = _integerOutcome(scanner, start, buffer.toString());
    final token = outcome.token;
    final diagnostic = outcome.diagnostic;
    if (token != null) tokens.add(token);
    if (diagnostic != null) diagnostics.add(diagnostic);
  }

  bool _isDigit(String character) {
    if (character.isEmpty) return false;
    final code = character.codeUnitAt(0);
    return code >= 48 && code <= 57;
  }

  void _finishRealLiteral(
    CharacterScanner scanner,
    Position start,
    StringBuffer buffer,
    List<Token> tokens,
  ) {
    buffer.write(scanner.advance());
    while (_isDigit(scanner.peek())) {
      buffer.write(scanner.advance());
    }
    final lexeme = buffer.toString();
    tokens.add(
      Token(
        type: TokenType.realLiteral,
        span: scanner.spanFrom(start),
        lexeme: lexeme,
        literalValue: double.parse(lexeme),
      ),
    );
  }

  ({Token? token, Diagnostic? diagnostic}) _integerOutcome(
    CharacterScanner scanner,
    Position start,
    String lexeme,
  ) {
    final value = PseudoInteger.tryParse(lexeme);
    final span = scanner.spanFrom(start);
    if (value == null) {
      return (
        token: null,
        diagnostic: Diagnostic(
          code: DiagnosticCode.integerLiteralOutOfRange,
          severity: Severity.error,
          span: span,
          arguments: {'lexeme': LexemeDiagnosticArgument(lexeme)},
        ),
      );
    }
    return (
      token: Token(
        type: TokenType.integerLiteral,
        span: span,
        lexeme: lexeme,
        literalValue: value,
      ),
      diagnostic: null,
    );
  }
}
