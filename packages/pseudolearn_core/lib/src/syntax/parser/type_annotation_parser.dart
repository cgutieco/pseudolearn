import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/primitive_type.dart';
import '../../domain/severity.dart';
import '../../domain/span.dart';
import '../../domain/token_type.dart';
import 'token_stream.dart';

final class ParsedType {
  final PrimitiveType? primitiveType;
  final String? customTypeName;
  final Span span;

  const ParsedType.primitive(this.primitiveType, this.span)
      : customTypeName = null;

  const ParsedType.custom(this.customTypeName, this.span)
      : primitiveType = null;
}

final class TypeAnnotationParser {
  const TypeAnnotationParser._();

  static ParsedType? parseType(
    TokenStream stream,
    List<Diagnostic> diagnostics,
  ) {
    final token = stream.peek();
    final primitiveType = mapTokenTypeToPrimitive(token.type);
    if (primitiveType != null) {
      stream.advance();
      _checkGenerics(stream, diagnostics);
      return ParsedType.primitive(primitiveType, token.span);
    }
    if (token.type == TokenType.identifier) {
      stream.advance();
      _checkGenerics(stream, diagnostics);
      return ParsedType.custom(token.lexeme, token.span);
    }
    diagnostics.add(
      Diagnostic(
        code: DiagnosticCode.expectedType,
        severity: Severity.error,
        span: token.span,
      ),
    );
    return null;
  }

  static void _checkGenerics(TokenStream stream, List<Diagnostic> diagnostics) {
    if (stream.match(TokenType.lessThan)) {
      final startSpan = stream.previousToken.span;
      var endSpan = startSpan;
      while (!stream.isAtEnd &&
          !stream.check(TokenType.greaterThan) &&
          !stream.check(TokenType.endOfLine) &&
          !stream.check(TokenType.semicolon)) {
        endSpan = stream.advance().span;
      }
      if (stream.match(TokenType.greaterThan)) {
        endSpan = stream.previousToken.span;
      }
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.unsupportedGenericsConstruct,
          severity: Severity.error,
          span: stream.spanFrom(startSpan, endSpan),
        ),
      );
    }
  }

  static PrimitiveType? mapTokenTypeToPrimitive(TokenType type) =>
      switch (type) {
        TokenType.integerType => PrimitiveType.integer,
        TokenType.realType => PrimitiveType.real,
        TokenType.booleanType => PrimitiveType.boolean,
        TokenType.characterType => PrimitiveType.character,
        TokenType.stringType => PrimitiveType.string,
        _ => null,
      };
}
