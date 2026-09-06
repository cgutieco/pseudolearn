import '../../domain/token_type.dart';
import 'token_stream.dart';

final class StatementSynchronizer {
  const StatementSynchronizer._();

  static void synchronize(
    TokenStream stream,
    Set<TokenType> stopTokens,
  ) {
    while (!stream.isAtEnd) {
      final type = stream.peek().type;
      if (type == TokenType.endOfLine || type == TokenType.semicolon) {
        stream.advance();
        break;
      }
      if (stopTokens.contains(type) || isBlockOpenerOrCloser(type)) {
        break;
      }
      stream.advance();
    }
  }

  static bool isBlockOpenerOrCloser(TokenType type) => switch (type) {
        TokenType.ifKeyword ||
        TokenType.whileKeyword ||
        TokenType.forKeyword ||
        TokenType.switchKeyword ||
        TokenType.repeat ||
        TokenType.elseKeyword ||
        TokenType.endIf ||
        TokenType.endWhile ||
        TokenType.endFor ||
        TokenType.endSwitch ||
        TokenType.until ||
        TokenType.defaultCase ||
        TokenType.endAlgorithm =>
          true,
        _ => false,
      };

  static bool isKnownUnsupportedKeyword(String lexeme) {
    final lower = lexeme.toLowerCase();
    return lower == 'romper' ||
        lower == 'interrumpir' ||
        lower == 'break' ||
        lower == 'continuar' ||
        lower == 'continue' ||
        lower == 'goto' ||
        lower == 'const' ||
        lower == 'constante';
  }

  static void skipIgnoredDelimiters(TokenStream stream) {
    while (!stream.isAtEnd) {
      final type = stream.peek().type;
      if (type == TokenType.endOfLine || type == TokenType.semicolon) {
        stream.advance();
      } else {
        break;
      }
    }
  }
}
