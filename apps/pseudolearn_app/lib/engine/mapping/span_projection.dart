import 'package:pseudolearn_core/pseudolearn_core.dart';
import '../../domain/model/analysis/highlight_span.dart';
import '../../domain/model/analysis/source_range.dart';

final class SpanProjection {
  const SpanProjection._();

  static SourceRange toSourceRange(Span span) {
    return SourceRange(
      startOffset: span.start.offset,
      endOffset: span.end.offset,
      startLine: span.start.line,
      startColumn: span.start.column,
      endLine: span.end.line,
      endColumn: span.end.column,
    );
  }

  static HighlightSpan? toHighlightSpan(Token token) {
    final category = _toCategory(token.type);
    if (category == null) return null;
    return HighlightSpan(
      range: toSourceRange(token.span),
      category: category,
    );
  }

  static HighlightCategory? _toCategory(TokenType type) {
    return _structuredKeyword(type) ??
        _proceduralOrOopKeyword(type) ??
        _literalOrTypeCategory(type) ??
        _operatorOrPunctuation(type);
  }

  static HighlightCategory? _structuredKeyword(TokenType type) {
    return switch (type) {
      TokenType.algorithm ||
      TokenType.endAlgorithm ||
      TokenType.ifKeyword ||
      TokenType.then ||
      TokenType.elseKeyword ||
      TokenType.endIf ||
      TokenType.switchKeyword ||
      TokenType.defaultCase ||
      TokenType.endSwitch ||
      TokenType.whileKeyword ||
      TokenType.doKeyword ||
      TokenType.endWhile ||
      TokenType.repeat ||
      TokenType.until ||
      TokenType.forKeyword ||
      TokenType.to ||
      TokenType.step ||
      TokenType.endFor ||
      TokenType.declare ||
      TokenType.dimension ||
      TokenType.read ||
      TokenType.write ||
      TokenType.withoutNewline =>
        HighlightCategory.keywordStructured,
      _ => null,
    };
  }

  static HighlightCategory? _proceduralOrOopKeyword(TokenType type) {
    return switch (type) {
      TokenType.subroutine ||
      TokenType.endSubroutine ||
      TokenType.byReference ||
      TokenType.byValue ||
      TokenType.returnKeyword =>
        HighlightCategory.keywordProcedural,
      TokenType.classKeyword ||
      TokenType.endClass ||
      TokenType.inheritsFrom ||
      TokenType.method ||
      TokenType.endMethod ||
      TokenType.constructor ||
      TokenType.publicVisibility ||
      TokenType.privateVisibility ||
      TokenType.newInstance ||
      TokenType.thisObject ||
      TokenType.superClass =>
        HighlightCategory.keywordOop,
      _ => null,
    };
  }

  static HighlightCategory? _literalOrTypeCategory(TokenType type) {
    return switch (type) {
      TokenType.integerType ||
      TokenType.realType ||
      TokenType.booleanType ||
      TokenType.characterType ||
      TokenType.stringType =>
        HighlightCategory.type,
      TokenType.integerLiteral ||
      TokenType.realLiteral =>
        HighlightCategory.literalNumber,
      TokenType.stringLiteral ||
      TokenType.characterLiteral =>
        HighlightCategory.literalString,
      TokenType.booleanTrue ||
      TokenType.booleanFalse =>
        HighlightCategory.literalBoolean,
      _ => null,
    };
  }

  static HighlightCategory? _operatorOrPunctuation(TokenType type) {
    return switch (type) {
      TokenType.plus ||
      TokenType.minus ||
      TokenType.multiply ||
      TokenType.divide ||
      TokenType.integerDivide ||
      TokenType.modulo ||
      TokenType.power ||
      TokenType.lessThan ||
      TokenType.lessThanOrEqual ||
      TokenType.greaterThan ||
      TokenType.greaterThanOrEqual ||
      TokenType.equal ||
      TokenType.notEqual ||
      TokenType.and ||
      TokenType.or ||
      TokenType.not ||
      TokenType.assignment =>
        HighlightCategory.operator,
      TokenType.leftParenthesis ||
      TokenType.rightParenthesis ||
      TokenType.leftBracket ||
      TokenType.rightBracket ||
      TokenType.comma ||
      TokenType.semicolon ||
      TokenType.typeConnector ||
      TokenType.branchSeparator ||
      TokenType.dot =>
        HighlightCategory.punctuation,
      TokenType.identifier => HighlightCategory.identifier,
      _ => null,
    };
  }
}
