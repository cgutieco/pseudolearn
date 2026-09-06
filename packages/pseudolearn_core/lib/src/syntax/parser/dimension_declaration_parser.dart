import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/node_id.dart';
import '../../domain/severity.dart';
import '../../domain/span.dart';
import '../../domain/token.dart';
import '../../domain/token_type.dart';
import '../ast/ast_node.dart';
import 'expression_parser.dart';
import 'token_stream.dart';
import 'type_annotation_parser.dart';

final class DimensionDeclarationParser {
  final NodeIdGenerator _nodeIdGenerator;

  DimensionDeclarationParser(this._nodeIdGenerator);

  NodeId _nextId() => _nodeIdGenerator.next();

  DimensionStatementNode? parse(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    ExpressionParser expressionParser,
  ) {
    final dimensionToken = stream.advance();
    final arrays = _parseArrayDeclaratorList(
      stream,
      diagnostics,
      expressionParser,
    );
    final parsedType = _parseTypeClause(stream, diagnostics);

    if (arrays.isEmpty || parsedType == null) {
      return null;
    }

    return DimensionStatementNode(
      id: _nextId(),
      span: stream.spanFrom(dimensionToken.span, parsedType.span),
      arrays: arrays,
      elementType: parsedType.primitiveType,
      customElementTypeName: parsedType.customTypeName,
      typeSpan: parsedType.span,
    );
  }

  List<ArrayDeclaratorNode> _parseArrayDeclaratorList(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    ExpressionParser expressionParser,
  ) {
    final arrays = <ArrayDeclaratorNode>[];
    final first = _parseSingleDeclarator(
      stream,
      diagnostics,
      expressionParser,
    );
    if (first != null) arrays.add(first);

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
      final next = _parseSingleDeclarator(
        stream,
        diagnostics,
        expressionParser,
      );
      if (next != null) {
        arrays.add(next);
      } else {
        break;
      }
    }
    return arrays;
  }

  ArrayDeclaratorNode? _parseSingleDeclarator(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    ExpressionParser expressionParser,
  ) {
    final nameToken = _validateDeclaratorName(stream, diagnostics);
    if (nameToken == null) return null;

    if (!stream.match(TokenType.leftBracket)) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.unclosedBracket,
          severity: Severity.error,
          span: nameToken.span,
        ),
      );
      return null;
    }

    final dimensions = _parseDimensions(
      stream,
      diagnostics,
      expressionParser,
      stream.previousToken.span,
    );

    return ArrayDeclaratorNode(
      id: _nextId(),
      span: stream.spanFrom(nameToken.span),
      name: nameToken.lexeme,
      nameSpan: nameToken.span,
      dimensions: dimensions,
    );
  }

  Token? _validateDeclaratorName(
    TokenStream stream,
    List<Diagnostic> diagnostics,
  ) {
    if (!stream.check(TokenType.identifier)) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.expectedIdentifierInDimension,
          severity: Severity.error,
          span: stream.peek().span,
        ),
      );
      return null;
    }
    return stream.advance();
  }

  List<ExpressionNode> _parseDimensions(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    ExpressionParser expressionParser,
    Span leftBracketSpan,
  ) {
    final dimensions = <ExpressionNode>[];
    if (stream.match(TokenType.rightBracket)) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.emptyDimensionList,
          severity: Severity.error,
          span: stream.spanFrom(leftBracketSpan),
        ),
      );
      return dimensions;
    }

    final first = expressionParser.parseExpression(stream, diagnostics);
    if (first != null) dimensions.add(first);

    while (stream.match(TokenType.comma)) {
      final next = expressionParser.parseExpression(stream, diagnostics);
      if (next != null) dimensions.add(next);
    }

    if (!stream.match(TokenType.rightBracket)) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.unclosedBracket,
          severity: Severity.error,
          span: leftBracketSpan,
        ),
      );
    }
    return dimensions;
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
}
