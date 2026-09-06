import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/node_id.dart';
import '../../domain/severity.dart';
import '../../domain/span.dart';
import '../../domain/token_type.dart';
import '../ast/ast_node.dart';
import 'parameter_parser.dart';
import 'statement_parser.dart';
import 'token_stream.dart';
import 'type_annotation_parser.dart';

final class SubroutineParser {
  final NodeIdGenerator _nodeIdGenerator;
  final ParameterParser _parameterParser;

  SubroutineParser(this._nodeIdGenerator)
      : _parameterParser = ParameterParser(_nodeIdGenerator);

  NodeId _nextId() => _nodeIdGenerator.next();

  SubroutineDeclarationNode parse(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    StatementParser statementParser,
  ) {
    final subroutineToken = stream.advance();
    final (name, nameSpan) = _parseSubroutineName(stream, diagnostics);
    final parameters = _parseParameters(stream, diagnostics);
    final parsedReturnType = _parseReturnType(stream, diagnostics);

    final body = statementParser.parseStatementList(
      stream,
      diagnostics,
      {TokenType.endSubroutine, TokenType.endOfFile},
      inSubroutine: true,
    );

    _validateSubroutineClosure(stream, diagnostics, subroutineToken.span);

    return SubroutineDeclarationNode(
      id: _nextId(),
      span: stream.spanFrom(subroutineToken.span),
      name: name,
      nameSpan: nameSpan,
      parameters: parameters,
      returnType: parsedReturnType?.primitiveType,
      customReturnType: parsedReturnType?.customTypeName,
      returnTypeSpan: parsedReturnType?.span,
      body: body,
    );
  }

  (String, Span) _parseSubroutineName(
    TokenStream stream,
    List<Diagnostic> diagnostics,
  ) {
    if (!stream.check(TokenType.identifier)) {
      final span = stream.peek().span;
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.expectedSubroutineName,
          severity: Severity.error,
          span: span,
        ),
      );
      return ('', span);
    }
    final token = stream.advance();
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

  void _validateSubroutineClosure(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    Span startSpan,
  ) {
    if (!stream.match(TokenType.endSubroutine)) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.unclosedSubroutine,
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
    if (stream.match(TokenType.rightBracket)) {
      return;
    }
  }
}
