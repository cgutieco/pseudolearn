import '../../domain/model/analysis/highlight_span.dart';
import 'source_offset_index.dart';

final class RustSyntaxHighlighter {
  final SourceOffsetIndex _offsets;

  const RustSyntaxHighlighter(this._offsets);

  List<HighlightSpan> project(List<Object?> tokens) {
    final spans = <HighlightSpan>[];
    for (final token in tokens) {
      if (token is! Map<String, Object?>) continue;
      final category = _categoryOf(token);
      final span = token['span'];
      if (category == null || span is! Map<String, Object?>) continue;
      final start = span['start'];
      final end = span['end'];
      if (start is! Map<String, Object?> || end is! Map<String, Object?>) {
        continue;
      }
      final startLine = start['line'];
      final startColumn = start['column'];
      final endLine = end['line'];
      final endColumn = end['column'];
      if (startLine is! int ||
          startColumn is! int ||
          endLine is! int ||
          endColumn is! int) {
        continue;
      }
      spans.add(
        HighlightSpan(
          range: _offsets.rangeOf(
            startLine: startLine,
            startColumn: startColumn,
            endLine: endLine,
            endColumn: endColumn,
          ),
          category: category,
        ),
      );
    }
    return spans;
  }

  HighlightCategory? _categoryOf(Map<String, Object?> token) {
    final kind = token['kind'];
    if (kind == 'identifier') return HighlightCategory.identifier;
    if (kind == 'integer_literal' || kind == 'real_literal') {
      return HighlightCategory.literalNumber;
    }
    if (kind == 'string_literal' || kind == 'character_literal') {
      return HighlightCategory.literalString;
    }
    if (kind == 'boolean_literal') return HighlightCategory.literalBoolean;
    if (kind == 'comment') return HighlightCategory.comment;
    if (kind == 'operator') return HighlightCategory.operator;
    if (kind == 'punctuation') return HighlightCategory.punctuation;
    if (kind != 'keyword') return null;
    return _keywordCategory(token['keyword']);
  }

  HighlightCategory? _keywordCategory(Object? keyword) =>
      _structuredKeyword(keyword) ??
      _proceduralKeyword(keyword) ??
      _objectKeyword(keyword) ??
      _typeKeyword(keyword) ??
      _booleanKeyword(keyword) ??
      _operatorKeyword(keyword) ??
      _punctuationKeyword(keyword);

  HighlightCategory? _structuredKeyword(Object? keyword) => switch (keyword) {
    'algorithm' ||
    'endAlgorithm' ||
    'declare' ||
    'dimension' ||
    'read' ||
    'write' ||
    'withoutNewline' ||
    'ifKeyword' ||
    'then' ||
    'elseKeyword' ||
    'endIf' ||
    'switchKeyword' ||
    'defaultCase' ||
    'endSwitch' ||
    'whileKeyword' ||
    'doKeyword' ||
    'endWhile' ||
    'repeat' ||
    'until' ||
    'forKeyword' ||
    'to' ||
    'step' ||
    'endFor' => HighlightCategory.keywordStructured,
    _ => null,
  };

  HighlightCategory? _proceduralKeyword(Object? keyword) => switch (keyword) {
    'subroutine' ||
    'endSubroutine' ||
    'byReference' ||
    'byValue' ||
    'returnKeyword' => HighlightCategory.keywordProcedural,
    _ => null,
  };

  HighlightCategory? _objectKeyword(Object? keyword) => switch (keyword) {
    'classKeyword' ||
    'endClass' ||
    'inheritsFrom' ||
    'method' ||
    'endMethod' ||
    'constructor' ||
    'publicVisibility' ||
    'privateVisibility' ||
    'newInstance' ||
    'thisObject' ||
    'superClass' => HighlightCategory.keywordOop,
    _ => null,
  };

  HighlightCategory? _typeKeyword(Object? keyword) => switch (keyword) {
    'integerType' ||
    'realType' ||
    'booleanType' ||
    'characterType' ||
    'stringType' => HighlightCategory.type,
    _ => null,
  };

  HighlightCategory? _booleanKeyword(Object? keyword) => switch (keyword) {
    'booleanTrue' || 'booleanFalse' => HighlightCategory.literalBoolean,
    _ => null,
  };

  HighlightCategory? _operatorKeyword(Object? keyword) => switch (keyword) {
    'and' ||
    'or' ||
    'not' ||
    'plus' ||
    'minus' ||
    'multiply' ||
    'divide' ||
    'integerDivide' ||
    'modulo' ||
    'power' ||
    'lessThan' ||
    'lessThanOrEqual' ||
    'greaterThan' ||
    'greaterThanOrEqual' ||
    'equal' ||
    'notEqual' ||
    'assignment' => HighlightCategory.operator,
    _ => null,
  };

  HighlightCategory? _punctuationKeyword(Object? keyword) => switch (keyword) {
    'typeConnector' ||
    'branchSeparator' ||
    'comma' ||
    'dot' ||
    'leftBracket' ||
    'leftParenthesis' ||
    'rightBracket' ||
    'rightParenthesis' ||
    'semicolon' ||
    'quote' => HighlightCategory.punctuation,
    _ => null,
  };
}
