import '../../domain/position.dart';
import '../../domain/span.dart';

final class CharacterScanner {
  final String source;
  int _offset = 0;
  int _line = 1;
  int _column = 1;

  CharacterScanner(this.source);

  bool get isAtEnd => _offset >= source.length;

  Position get currentPosition =>
      Position(line: _line, column: _column, offset: _offset);

  String peek() => isAtEnd ? '' : source[_offset];

  String peekAhead(int count) {
    final targetOffset = _offset + count;
    if (targetOffset >= source.length) return '';
    return source[targetOffset];
  }

  String advance() {
    if (isAtEnd) return '';
    final character = source[_offset];
    if (character == '\r') {
      _offset++;
      if (!isAtEnd && source[_offset] == '\n') {
        _offset++;
      }
      _line++;
      _column = 1;
      return '\n';
    }
    if (character == '\n') {
      _offset++;
      _line++;
      _column = 1;
      return '\n';
    }
    _offset++;
    _column++;
    return character;
  }

  bool match(String expected) {
    if (isAtEnd || source[_offset] != expected) return false;
    advance();
    return true;
  }

  Span spanFrom(Position start) => Span(start: start, end: currentPosition);
}
