import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/node_id.dart';
import '../../domain/severity.dart';
import '../../domain/span.dart';
import '../../domain/token.dart';
import '../../domain/token_type.dart';
import '../../domain/visibility.dart';
import '../ast/ast_node.dart';
import 'parameter_parser.dart';
import 'statement_parser.dart';
import 'token_stream.dart';
import 'type_annotation_parser.dart';

final class MethodAndConstructorParser {
  final NodeIdGenerator _nodeIdGenerator;
  final ParameterParser _parameterParser;

  MethodAndConstructorParser(this._nodeIdGenerator)
      : _parameterParser = ParameterParser(_nodeIdGenerator);

  NodeId _nextId() => _nodeIdGenerator.next();

  ConstructorDeclarationNode parseConstructor(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    StatementParser statementParser, {
    required Span startSpan,
    required Span? visibilitySpan,
    required bool hasExistingConstructor,
  }) {
    final constructorToken = stream.advance();
    _validateConstructorHeader(
      diagnostics,
      constructorToken,
      visibilitySpan,
      hasExistingConstructor,
    );

    final parameters = _parseParameters(stream, diagnostics);
    _validateNoReturnType(stream, diagnostics);

    final body = statementParser.parseStatementList(
      stream,
      diagnostics,
      {TokenType.endMethod, TokenType.endClass, TokenType.endOfFile},
      inSubroutine: true,
    );
    _validateClosure(stream, diagnostics, startSpan);

    return ConstructorDeclarationNode(
      id: _nextId(),
      span: stream.spanFrom(startSpan),
      parameters: parameters,
      body: body,
    );
  }

  void _validateConstructorHeader(
    List<Diagnostic> diagnostics,
    Token constructorToken,
    Span? visibilitySpan,
    bool hasExistingConstructor,
  ) {
    if (visibilitySpan != null) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.constructorVisibilityNotAllowed,
          severity: Severity.error,
          span: visibilitySpan,
        ),
      );
    }
    if (hasExistingConstructor) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.duplicateConstructor,
          severity: Severity.error,
          span: constructorToken.span,
        ),
      );
    }
  }

  MethodDeclarationNode parseMethod(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    StatementParser statementParser, {
    required Span startSpan,
    required Visibility visibility,
    required String className,
  }) {
    final (name, nameSpan) = _parseMethodName(stream, diagnostics, className);
    final parameters = _parseParameters(stream, diagnostics);
    final parsedReturnType = _parseReturnType(stream, diagnostics);

    final body = statementParser.parseStatementList(
      stream,
      diagnostics,
      {TokenType.endMethod, TokenType.endClass, TokenType.endOfFile},
      inSubroutine: true,
    );
    _validateClosure(stream, diagnostics, startSpan);

    return MethodDeclarationNode(
      id: _nextId(),
      span: stream.spanFrom(startSpan),
      visibility: visibility,
      name: name,
      nameSpan: nameSpan,
      parameters: parameters,
      returnType: parsedReturnType?.primitiveType,
      customReturnType: parsedReturnType?.customTypeName,
      returnTypeSpan: parsedReturnType?.span,
      body: body,
    );
  }

  (String, Span) _parseMethodName(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    String className,
  ) {
    if (!stream.check(TokenType.identifier)) {
      final span = stream.peek().span;
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.expectedParameterName,
          severity: Severity.error,
          span: span,
        ),
      );
      return ('', span);
    }
    final token = stream.advance();
    if (token.lexeme.toLowerCase() == className.toLowerCase()) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.methodNamedAsClass,
          severity: Severity.error,
          span: token.span,
        ),
      );
    }
    return (token.lexeme, token.span);
  }

  List<ParameterNode> _parseParameters(
    TokenStream stream,
    List<Diagnostic> diagnostics,
  ) {
    if (!stream.match(TokenType.leftParenthesis)) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.expectedSubroutineLeftParenthesis,
          severity: Severity.error,
          span: stream.peek().span,
        ),
      );
      return const [];
    }

    final parameters = _parameterParser.parseParameterList(stream, diagnostics);
    if (!stream.match(TokenType.rightParenthesis)) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.unclosedParenthesis,
          severity: Severity.error,
          span: stream.peek().span,
        ),
      );
    }
    return parameters;
  }

  void _validateNoReturnType(
    TokenStream stream,
    List<Diagnostic> diagnostics,
  ) {
    if (stream.match(TokenType.typeConnector)) {
      final typeToken = stream.advance();
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.constructorReturnTypeNotAllowed,
          severity: Severity.error,
          span: stream.spanFrom(stream.previousToken.span, typeToken.span),
        ),
      );
    }
  }

  ParsedType? _parseReturnType(
    TokenStream stream,
    List<Diagnostic> diagnostics,
  ) {
    if (!stream.match(TokenType.typeConnector)) {
      return null;
    }

    final parsedType = TypeAnnotationParser.parseType(stream, diagnostics);
    if (parsedType == null) return null;

    if (stream.match(TokenType.leftBracket)) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.invalidArrayReturnType,
          severity: Severity.error,
          span: stream.previousToken.span,
        ),
      );
      _skipBracketContent(stream);
    }
    return parsedType;
  }

  void _validateClosure(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    Span startSpan,
  ) {
    if (!stream.match(TokenType.endMethod)) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.unclosedMethod,
          severity: Severity.error,
          span: stream.peek().span,
          relatedSpans: [startSpan],
        ),
      );
    }
  }

  void _skipBracketContent(TokenStream stream) {
    while (!stream.isAtEnd && !stream.check(TokenType.rightBracket)) {
      stream.advance();
    }
    if (stream.match(TokenType.rightBracket)) return;
  }
}
