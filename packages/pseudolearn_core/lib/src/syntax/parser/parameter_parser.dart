import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/node_id.dart';
import '../../domain/severity.dart';
import '../../domain/span.dart';
import '../../domain/token_type.dart';
import '../ast/ast_node.dart';
import 'token_stream.dart';
import 'type_annotation_parser.dart';

final class ParameterParser {
  final NodeIdGenerator _nodeIdGenerator;

  ParameterParser(this._nodeIdGenerator);

  NodeId _nextId() => _nodeIdGenerator.next();

  List<ParameterNode> parseParameterList(
    TokenStream stream,
    List<Diagnostic> diagnostics,
  ) {
    if (stream.check(TokenType.rightParenthesis) || stream.isAtEnd) {
      return const [];
    }

    final parameters = <ParameterNode>[];
    while (!stream.isAtEnd && !stream.check(TokenType.rightParenthesis)) {
      final param = parseParameter(stream, diagnostics);
      if (param != null) {
        parameters.add(param);
      }

      if (stream.match(TokenType.comma)) {
        if (stream.check(TokenType.rightParenthesis)) {
          diagnostics.add(
            Diagnostic(
              code: DiagnosticCode.trailingComma,
              severity: Severity.error,
              span: stream.previousToken.span,
            ),
          );
          break;
        }
      } else {
        break;
      }
    }
    return parameters;
  }

  ParameterNode? parseParameter(
    TokenStream stream,
    List<Diagnostic> diagnostics,
  ) {
    _checkModifierBeforeName(stream, diagnostics);

    if (!stream.check(TokenType.identifier)) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.expectedParameterName,
          severity: Severity.error,
          span: stream.peek().span,
        ),
      );
      return null;
    }

    final nameToken = stream.advance();
    final startSpan = nameToken.span;
    final dimensionCount = _parseDimension(stream, diagnostics);
    final parsedType = _parseTypeClause(stream, diagnostics);
    final (passingMode, passingSpan) = _parsePassingMode(stream, diagnostics);

    return ParameterNode(
      id: _nextId(),
      span: stream.spanFrom(startSpan),
      name: nameToken.lexeme,
      nameSpan: nameToken.span,
      dimensionCount: dimensionCount,
      type: parsedType?.primitiveType,
      customTypeName: parsedType?.customTypeName,
      typeSpan: parsedType?.span,
      passingMode: passingMode,
      passingModeSpan: passingSpan,
    );
  }

  void _checkModifierBeforeName(
    TokenStream stream,
    List<Diagnostic> diagnostics,
  ) {
    if (stream.check(TokenType.byValue) ||
        stream.check(TokenType.byReference)) {
      final modifierToken = stream.advance();
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.passingModifierBeforeParameterName,
          severity: Severity.error,
          span: modifierToken.span,
        ),
      );
    }
  }

  int _parseDimension(TokenStream stream, List<Diagnostic> diagnostics) {
    if (!stream.match(TokenType.leftBracket)) {
      return 0;
    }
    var dimensions = 1;
    while (stream.match(TokenType.comma)) {
      dimensions++;
    }
    if (!stream.match(TokenType.rightBracket)) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.unclosedBracket,
          severity: Severity.error,
          span: stream.peek().span,
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

  (ParameterPassingMode, Span?) _parsePassingMode(
    TokenStream stream,
    List<Diagnostic> diagnostics,
  ) {
    if (stream.match(TokenType.byReference)) {
      final refSpan = stream.previousToken.span;
      if (stream.match(TokenType.byValue)) {
        diagnostics.add(
          Diagnostic(
            code: DiagnosticCode.duplicatePassingModifier,
            severity: Severity.error,
            span: stream.previousToken.span,
          ),
        );
      }
      return (ParameterPassingMode.byReference, refSpan);
    }

    if (stream.match(TokenType.byValue)) {
      final valSpan = stream.previousToken.span;
      if (stream.match(TokenType.byReference)) {
        diagnostics.add(
          Diagnostic(
            code: DiagnosticCode.duplicatePassingModifier,
            severity: Severity.error,
            span: stream.previousToken.span,
          ),
        );
      }
      return (ParameterPassingMode.byValue, valSpan);
    }

    return (ParameterPassingMode.byValue, null);
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
