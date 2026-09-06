import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_argument.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/profile/lexer_profile.dart';
import '../../domain/severity.dart';
import '../../domain/span.dart';
import '../../domain/token.dart';
import '../../domain/token_type.dart';
import 'character_scanner.dart';
import 'lexical_matcher.dart';
import 'lexer_result.dart';
import 'numeric_literal_scanner.dart';
import 'string_literal_scanner.dart';

final class Lexer {
  final LexerProfile profile;
  final LexicalMatcher _matcher;
  final StringLiteralScanner _stringScanner = const StringLiteralScanner();
  final NumericLiteralScanner _numberScanner = const NumericLiteralScanner();

  Lexer(this.profile) : _matcher = LexicalMatcher(profile);

  LexerResult tokenize(String source) {
    final scanner = CharacterScanner(source);
    final tokens = <Token>[];
    final diagnostics = <Diagnostic>[];
    var hasEmittedTokenOnLine = false;

    while (!scanner.isAtEnd) {
      hasEmittedTokenOnLine = _scanNext(
        scanner,
        tokens,
        diagnostics,
        hasEmittedTokenOnLine,
      );
    }

    _appendEndOfFile(scanner, tokens);
    return LexerResult(tokens: tokens, diagnostics: diagnostics);
  }

  bool _scanNext(
    CharacterScanner scanner,
    List<Token> tokens,
    List<Diagnostic> diagnostics,
    bool hasEmittedTokenOnLine,
  ) {
    final character = scanner.peek();
    if (_isWhitespace(character)) {
      scanner.advance();
      return hasEmittedTokenOnLine;
    }
    if (character == '\n' || character == '\r') {
      return _handleNewline(scanner, tokens, hasEmittedTokenOnLine);
    }
    if (_isCommentStart(scanner)) {
      _skipComment(scanner);
      return hasEmittedTokenOnLine;
    }
    if (_isDigit(character)) {
      _numberScanner.scan(scanner, tokens, diagnostics);
      return true;
    }
    if (character == '"' || character == "'") {
      _stringScanner.scan(scanner, tokens, diagnostics);
      return true;
    }
    if (_isValidIdentifierStart(character)) {
      _scanWordOrIdentifier(scanner, tokens);
      return true;
    }
    final handled = _tryScanSymbol(scanner, tokens);
    if (handled) return true;

    _handleUnrecognizedCharacter(scanner, diagnostics);
    return hasEmittedTokenOnLine;
  }

  bool _isWhitespace(String character) => character == ' ' || character == '\t';

  bool _isCommentStart(CharacterScanner scanner) {
    final marker = profile.commentMarker;
    for (var i = 0; i < marker.length; i++) {
      if (scanner.peekAhead(i) != marker[i]) return false;
    }
    return true;
  }

  void _skipComment(CharacterScanner scanner) {
    while (!scanner.isAtEnd) {
      final character = scanner.peek();
      if (character == '\n' || character == '\r') break;
      scanner.advance();
    }
  }

  bool _handleNewline(
    CharacterScanner scanner,
    List<Token> tokens,
    bool hasEmittedTokenOnLine,
  ) {
    final start = scanner.currentPosition;
    scanner.advance();
    if (hasEmittedTokenOnLine) {
      tokens.add(
        Token(
          type: TokenType.endOfLine,
          span: scanner.spanFrom(start),
          lexeme: '\n',
        ),
      );
    }
    return false;
  }

  bool _isDigit(String character) {
    if (character.isEmpty) return false;
    final code = character.codeUnitAt(0);
    return code >= 48 && code <= 57;
  }

  bool _isValidIdentifierStart(String character) =>
      profile.identifierAlphabet.isValidStartCharacter(character);

  void _scanWordOrIdentifier(
    CharacterScanner scanner,
    List<Token> tokens,
  ) {
    final start = scanner.currentPosition;
    final firstWord = _readSingleWord(scanner);
    final phraseMatch = _matcher.matchWordPhrase(scanner, firstWord);

    if (phraseMatch != null) {
      for (var i = 0; i < phraseMatch.additionalCharactersToAdvance; i++) {
        scanner.advance();
      }
      tokens.add(
        Token(
          type: phraseMatch.tokenType,
          span: scanner.spanFrom(start),
          lexeme: phraseMatch.fullLexeme,
        ),
      );
      return;
    }

    tokens.add(
      Token(
        type: TokenType.identifier,
        span: scanner.spanFrom(start),
        lexeme: firstWord,
      ),
    );
  }

  String _readSingleWord(CharacterScanner scanner) {
    final buffer = StringBuffer();
    while (!scanner.isAtEnd) {
      final character = scanner.peek();
      if (!profile.identifierAlphabet.isValidContinuationCharacter(character)) {
        break;
      }
      buffer.write(scanner.advance());
    }
    return buffer.toString();
  }

  bool _tryScanSymbol(CharacterScanner scanner, List<Token> tokens) {
    final match = _matcher.matchSymbol(scanner);
    if (match == null) return false;

    final start = scanner.currentPosition;
    for (var i = 0; i < match.key.length; i++) {
      scanner.advance();
    }
    tokens.add(
      Token(
        type: match.value,
        span: scanner.spanFrom(start),
        lexeme: match.key,
      ),
    );
    return true;
  }

  void _handleUnrecognizedCharacter(
    CharacterScanner scanner,
    List<Diagnostic> diagnostics,
  ) {
    final start = scanner.currentPosition;
    final character = scanner.advance();
    diagnostics.add(
      Diagnostic(
        code: DiagnosticCode.unrecognizedCharacter,
        severity: Severity.error,
        span: scanner.spanFrom(start),
        arguments: {'lexeme': LexemeDiagnosticArgument(character)},
      ),
    );
  }

  void _appendEndOfFile(CharacterScanner scanner, List<Token> tokens) {
    tokens.add(
      Token(
        type: TokenType.endOfFile,
        span: Span(
          start: scanner.currentPosition,
          end: scanner.currentPosition,
        ),
        lexeme: '',
      ),
    );
  }
}
