import '../../../domain/model/analysis/highlight_span.dart';
import 'code_language.dart';

final class LexicalToken {
  final int end;
  final HighlightCategory? category;

  const LexicalToken(this.end, [this.category]);
}

final class LexicalTokenScanner {
  final String _source;
  final CodeLanguage _language;

  const LexicalTokenScanner(this._source, this._language);

  LexicalToken tokenAt(int position) =>
      _comment(position) ?? _quoted(position) ?? _number(position) ?? _word(position) ?? LexicalToken(position + 1);

  LexicalToken? _comment(int position) {
    for (final marker in _language.lineComments) {
      if (!_source.startsWith(marker, position)) continue;
      final lineEnd = _source.indexOf('\n', position);
      return LexicalToken(lineEnd < 0 ? _source.length : lineEnd, HighlightCategory.comment);
    }
    final open = _language.blockCommentOpen;
    final close = _language.blockCommentClose;
    if (open == null || close == null || !_source.startsWith(open, position)) return null;
    final closeAt = _source.indexOf(close, position + open.length);
    return LexicalToken(closeAt < 0 ? _source.length : closeAt + close.length, HighlightCategory.comment);
  }

  LexicalToken? _quoted(int position) {
    for (final quote in _language.quotes) {
      if (_source.startsWith(quote, position)) return LexicalToken(_quoteEnd(position, quote), HighlightCategory.literalString);
    }
    return null;
  }

  int _quoteEnd(int position, String quote) {
    final multiline = quote.length > 1 || quote == '`';
    var cursor = position + quote.length;
    while (cursor < _source.length) {
      if (_source.startsWith(quote, cursor)) return cursor + quote.length;
      if (!multiline && _source[cursor] == '\n') return cursor;
      cursor += _source[cursor] == r'\' ? 2 : 1;
    }
    return _source.length;
  }

  LexicalToken? _number(int position) {
    if (!_isDigit(_source.codeUnitAt(position)) || _continuesWord(position)) return null;
    var cursor = position + 1;
    while (cursor < _source.length && _isNumberPart(_source.codeUnitAt(cursor))) {
      cursor += 1;
    }
    return LexicalToken(cursor, HighlightCategory.literalNumber);
  }

  LexicalToken? _word(int position) {
    if (!_isWordStart(_source.codeUnitAt(position)) || _continuesWord(position)) return null;
    var cursor = position + 1;
    while (cursor < _source.length && _isWordPart(_source.codeUnitAt(cursor))) {
      cursor += 1;
    }
    return LexicalToken(cursor, _wordCategory(_source.substring(position, cursor), position, cursor));
  }

  HighlightCategory _wordCategory(String word, int start, int end) {
    if (_language.isKeyword(word)) return HighlightCategory.keywordStructured;
    if (_language.isType(word)) return HighlightCategory.type;
    if (_language.isConstant(word)) return HighlightCategory.literalBoolean;
    if (_language.tagNames && _followsTagOpener(start)) return HighlightCategory.keywordStructured;
    if (end < _source.length && _source[end] == '(') return HighlightCategory.keywordProcedural;
    return HighlightCategory.identifier;
  }

  bool _followsTagOpener(int start) =>
      (start >= 1 && _source[start - 1] == '<') || (start >= 2 && _source.startsWith('</', start - 2));

  bool _continuesWord(int position) => position > 0 && _isWordPart(_source.codeUnitAt(position - 1));
}

bool _isDigit(int unit) => unit >= 0x30 && unit <= 0x39;

bool _isLetter(int unit) => (unit >= 0x41 && unit <= 0x5A) || (unit >= 0x61 && unit <= 0x7A) || unit >= 0xC0;

bool _isWordStart(int unit) => _isLetter(unit) || unit == 0x5F || unit == 0x24;

bool _isWordPart(int unit) => _isWordStart(unit) || _isDigit(unit);

bool _isNumberPart(int unit) => _isWordPart(unit) || unit == 0x2E;
