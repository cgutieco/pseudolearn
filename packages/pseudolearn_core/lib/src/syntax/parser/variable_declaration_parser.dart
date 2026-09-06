import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/node_id.dart';
import '../../domain/severity.dart';
import '../../domain/token_type.dart';
import '../ast/ast_node.dart';
import 'reserved_lexeme_name.dart';
import 'token_stream.dart';
import 'type_annotation_parser.dart';

const Set<TokenType> _declarationContinuation = {
  TokenType.typeConnector,
  TokenType.comma,
  TokenType.semicolon,
};

final class VariableDeclarationParser {
  final NodeIdGenerator _nodeIdGenerator;

  VariableDeclarationParser(this._nodeIdGenerator);

  NodeId _nextId() => _nodeIdGenerator.next();

  VariableDeclarationNode? parse(
    TokenStream stream,
    List<Diagnostic> diagnostics,
  ) {
    final declareToken = stream.advance();
    final variables = _parseVariableList(stream, diagnostics);
    final parsedType = _parseTypeClause(stream, diagnostics);

    _checkProhibitedInitializer(stream, diagnostics);

    if (variables.isEmpty || parsedType == null) {
      return null;
    }

    return VariableDeclarationNode(
      id: _nextId(),
      span: stream.spanFrom(declareToken.span, parsedType.span),
      variables: variables,
      type: parsedType.primitiveType,
      customTypeName: parsedType.customTypeName,
      typeSpan: parsedType.span,
    );
  }

  List<VariableDeclaratorNode> _parseVariableList(
    TokenStream stream,
    List<Diagnostic> diagnostics,
  ) {
    final variables = <VariableDeclaratorNode>[];
    if (!stream.check(TokenType.identifier)) {
      _reportMissingName(stream, diagnostics);
      _skipToTypeClause(stream);
      return variables;
    }

    variables.add(_parseDeclarator(stream));
    _parseTrailingVariables(stream, diagnostics, variables);
    return variables;
  }

  void _parseTrailingVariables(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    List<VariableDeclaratorNode> variables,
  ) {
    while (stream.match(TokenType.comma)) {
      if (stream.check(TokenType.typeConnector)) {
        diagnostics.add(
          Diagnostic(
            code: DiagnosticCode.trailingComma,
            severity: Severity.error,
            span: stream.previousToken.span,
          ),
        );
        break;
      }
      if (stream.check(TokenType.identifier)) {
        variables.add(_parseDeclarator(stream));
      } else {
        _reportMissingName(stream, diagnostics);
        _skipToTypeClause(stream);
        break;
      }
    }
  }

  void _reportMissingName(
    TokenStream stream,
    List<Diagnostic> diagnostics,
  ) {
    final token = stream.peek();
    if (ReservedLexemeName.standsWhereNameIsRequired(
      token,
      continuesWith: _declarationContinuation,
    )) {
      stream.advance();
      diagnostics.add(ReservedLexemeName.diagnosticFor(token));
      return;
    }
    diagnostics.add(
      Diagnostic(
        code: DiagnosticCode.expectedIdentifierInDeclaration,
        severity: Severity.error,
        span: token.span,
      ),
    );
  }

  void _skipToTypeClause(TokenStream stream) {
    while (!stream.isAtEnd &&
        !stream.check(TokenType.typeConnector) &&
        !stream.check(TokenType.semicolon) &&
        !stream.check(TokenType.endOfLine)) {
      stream.advance();
    }
  }

  VariableDeclaratorNode _parseDeclarator(TokenStream stream) {
    final identifierToken = stream.advance();
    return VariableDeclaratorNode(
      id: _nextId(),
      span: identifierToken.span,
      name: identifierToken.lexeme,
    );
  }

  ParsedType? _parseTypeClause(
    TokenStream stream,
    List<Diagnostic> diagnostics,
  ) {
    if (!stream.match(TokenType.typeConnector)) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.expectedTypeConnector,
          severity: Severity.error,
          span: stream.peek().span,
        ),
      );
      return null;
    }

    return TypeAnnotationParser.parseType(stream, diagnostics);
  }

  void _checkProhibitedInitializer(
    TokenStream stream,
    List<Diagnostic> diagnostics,
  ) {
    if (stream.check(TokenType.assignment)) {
      final assignToken = stream.advance();
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.initializationInDeclarationNotAllowed,
          severity: Severity.error,
          span: assignToken.span,
        ),
      );
    }
  }
}
