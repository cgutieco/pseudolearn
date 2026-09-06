import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/node_id.dart';
import '../../domain/profile/parser_profile.dart';
import '../../domain/severity.dart';
import '../../domain/span.dart';
import '../../domain/token_type.dart';
import '../ast/ast_node.dart';
import 'member_parser.dart';
import 'statement_parser.dart';
import 'token_stream.dart';

final class ClassParser {
  final NodeIdGenerator _nodeIdGenerator;
  final MemberParser _memberParser;

  ClassParser(this._nodeIdGenerator, ParserProfile profile)
      : _memberParser = MemberParser(_nodeIdGenerator, profile);

  NodeId _nextId() => _nodeIdGenerator.next();

  ClassNode parse(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    StatementParser statementParser,
  ) {
    final classToken = stream.advance();
    final (name, nameSpan) = _parseClassName(stream, diagnostics);
    final (superName, superSpan) = _parseInheritance(stream, diagnostics);

    final members = _memberParser.parseMembers(
      stream,
      diagnostics,
      statementParser,
      name,
    );

    _validateClassClosure(stream, diagnostics, classToken.span);

    return ClassNode(
      id: _nextId(),
      span: stream.spanFrom(classToken.span),
      name: name,
      nameSpan: nameSpan,
      superclassName: superName,
      superclassSpan: superSpan,
      members: members,
    );
  }

  (String, Span) _parseClassName(
    TokenStream stream,
    List<Diagnostic> diagnostics,
  ) {
    if (!stream.check(TokenType.identifier)) {
      final span = stream.peek().span;
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.expectedClassName,
          severity: Severity.error,
          span: span,
        ),
      );
      return ('', span);
    }
    final token = stream.advance();
    return (token.lexeme, token.span);
  }

  (String?, Span?) _parseInheritance(
    TokenStream stream,
    List<Diagnostic> diagnostics,
  ) {
    if (!stream.match(TokenType.inheritsFrom)) {
      return (null, null);
    }

    if (!stream.check(TokenType.identifier)) {
      final span = stream.peek().span;
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.expectedClassName,
          severity: Severity.error,
          span: span,
        ),
      );
      return (null, null);
    }

    final superToken = stream.advance();
    _checkMultipleInheritance(stream, diagnostics);
    return (superToken.lexeme, superToken.span);
  }

  void _checkMultipleInheritance(
    TokenStream stream,
    List<Diagnostic> diagnostics,
  ) {
    if (stream.match(TokenType.comma)) {
      final startSpan = stream.previousToken.span;
      var endSpan = startSpan;
      while (!stream.isAtEnd &&
          !stream.check(TokenType.endOfLine) &&
          !stream.check(TokenType.semicolon)) {
        endSpan = stream.advance().span;
      }
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.multipleInheritanceNotSupported,
          severity: Severity.error,
          span: stream.spanFrom(startSpan, endSpan),
        ),
      );
    }
  }

  void _validateClassClosure(
    TokenStream stream,
    List<Diagnostic> diagnostics,
    Span startSpan,
  ) {
    if (!stream.match(TokenType.endClass)) {
      diagnostics.add(
        Diagnostic(
          code: DiagnosticCode.unclosedClass,
          severity: Severity.error,
          span: stream.peek().span,
          relatedSpans: [startSpan],
        ),
      );
    }
  }
}
