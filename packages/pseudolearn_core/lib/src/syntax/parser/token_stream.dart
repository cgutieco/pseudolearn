import '../../domain/position.dart';
import '../../domain/span.dart';
import '../../domain/token.dart';
import '../../domain/token_type.dart';

final class TokenStream {
  final List<Token> _tokens;
  int _currentIndex = 0;

  TokenStream(this._tokens);

  bool get isAtEnd =>
      _currentIndex >= _tokens.length ||
      _tokens[_currentIndex].type == TokenType.endOfFile;

  Token peek() {
    if (_currentIndex >= _tokens.length) {
      return _tokens.last;
    }
    return _tokens[_currentIndex];
  }

  Token peekAhead(int offset) {
    final index = _currentIndex + offset;
    if (index >= _tokens.length) {
      return _tokens.last;
    }
    return _tokens[index];
  }

  Token advance() {
    if (!isAtEnd) {
      _currentIndex++;
    }
    return previousToken;
  }

  Token get previousToken {
    if (_currentIndex == 0) {
      return _tokens.first;
    }
    return _tokens[_currentIndex - 1];
  }

  bool check(TokenType type) {
    if (isAtEnd) return false;
    return peek().type == type;
  }

  bool match(TokenType type) {
    if (check(type)) {
      advance();
      return true;
    }
    return false;
  }

  Position get currentPosition => peek().span.start;

  Span spanFrom(Span startSpan, [Span? endSpan]) {
    final resolvedEnd = endSpan ?? previousToken.span;
    return Span(start: startSpan.start, end: resolvedEnd.end);
  }
}
