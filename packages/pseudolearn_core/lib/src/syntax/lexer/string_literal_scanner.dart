import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_argument.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/position.dart';
import '../../domain/severity.dart';
import '../../domain/token.dart';
import '../../domain/token_type.dart';
import 'character_scanner.dart';

final class StringLiteralScanner {
  const StringLiteralScanner();

  void scan(
    CharacterScanner scanner,
    List<Token> tokens,
    List<Diagnostic> diagnostics,
  ) {
    final start = scanner.currentPosition;
    final quoteChar = scanner.advance();
    final buffer = StringBuffer();
    final isTerminated = _collectContent(
      scanner,
      quoteChar,
      buffer,
      diagnostics,
    );

    if (!isTerminated) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.unterminatedString,
          severity: Severity.error,
          span: scanner.spanFrom(start),
          arguments: const {},
        ),
      );
      return;
    }

    _emitToken(scanner, start, buffer.toString(), tokens);
  }

  bool _collectContent(
    CharacterScanner scanner,
    String quoteChar,
    StringBuffer buffer,
    List<Diagnostic> diagnostics,
  ) {
    while (!scanner.isAtEnd) {
      final character = scanner.peek();
      if (character == quoteChar) {
        scanner.advance();
        return true;
      }
      if (character == '\n' || character == '\r') {
        return false;
      }
      if (character == '\\') {
        _handleEscape(scanner, buffer, diagnostics);
      } else {
        buffer.write(scanner.advance());
      }
    }
    return false;
  }

  void _emitToken(
    CharacterScanner scanner,
    Position start,
    String content,
    List<Token> tokens,
  ) {
    final span = scanner.spanFrom(start);
    final rawLexeme = scanner.source.substring(start.offset, span.end.offset);
    final tokenType = content.length == 1
        ? TokenType.characterLiteral
        : TokenType.stringLiteral;

    tokens.add(
      Token(
        type: tokenType,
        span: span,
        lexeme: rawLexeme,
        literalValue: content,
      ),
    );
  }

  void _handleEscape(
    CharacterScanner scanner,
    StringBuffer buffer,
    List<Diagnostic> diagnostics,
  ) {
    final escapeStart = scanner.currentPosition;
    scanner.advance();
    final escaped = scanner.advance();
    final unescapedChar = switch (escaped) {
      'n' => '\n',
      't' => '\t',
      'r' => '\r',
      '\\' => '\\',
      '"' => '"',
      "'" => "'",
      _ => null,
    };

    if (unescapedChar != null) {
      buffer.write(unescapedChar);
    } else {
      buffer.write(escaped);
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.invalidEscapeSequence,
          severity: Severity.error,
          span: scanner.spanFrom(escapeStart),
          arguments: {'lexeme': LexemeDiagnosticArgument('\\$escaped')},
        ),
      );
    }
  }
}
