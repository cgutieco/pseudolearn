import '../../domain/lexeme_shape.dart';
import '../../domain/profile/lexer_profile.dart';
import '../../domain/profile/profile_normalizer.dart';
import '../../domain/token_type.dart';
import 'character_scanner.dart';

final class WordPhraseMatch {
  final TokenType tokenType;
  final String fullLexeme;
  final int additionalCharactersToAdvance;

  const WordPhraseMatch({
    required this.tokenType,
    required this.fullLexeme,
    required this.additionalCharactersToAdvance,
  });
}

final class LexicalMatcher {
  final LexerProfile profile;
  final ProfileNormalizer normalizer;
  final List<MapEntry<String, TokenType>> _sortedSymbols = [];
  final Map<String, TokenType> _wordTokens = {};
  int _maxWordCount = 1;

  LexicalMatcher(this.profile)
      : normalizer = ProfileNormalizer(
          casePolicy: profile.casePolicy,
          accentPolicy: profile.accentPolicy,
        ) {
    _buildTables();
  }

  void _buildTables() {
    for (final entry in profile.reservedLexemes.entries) {
      final tokenType = entry.key;
      final lexemeEntry = entry.value;
      _registerLexeme(lexemeEntry.canonicalLexeme, tokenType);
      for (final alias in lexemeEntry.aliases) {
        _registerLexeme(alias, tokenType);
      }
    }
    _sortedSymbols.sort((a, b) => b.key.length.compareTo(a.key.length));
  }

  void _registerLexeme(String rawLexeme, TokenType tokenType) {
    final normalized = normalizer.normalize(rawLexeme);
    if (LexemeShape.isWord(rawLexeme)) {
      _wordTokens[normalized] = tokenType;
      final wordCount = normalized.split(' ').length;
      if (wordCount > _maxWordCount) {
        _maxWordCount = wordCount;
      }
    } else {
      _sortedSymbols.add(MapEntry(rawLexeme, tokenType));
    }
  }

  MapEntry<String, TokenType>? matchSymbol(CharacterScanner scanner) {
    for (final entry in _sortedSymbols) {
      final symbol = entry.key;
      if (_matchesPrefix(scanner, symbol)) {
        return entry;
      }
    }
    return null;
  }

  bool _matchesPrefix(CharacterScanner scanner, String prefix) {
    for (var i = 0; i < prefix.length; i++) {
      if (scanner.peekAhead(i) != prefix[i]) {
        return false;
      }
    }
    return true;
  }

  WordPhraseMatch? matchWordPhrase(
    CharacterScanner scanner,
    String firstWord,
  ) {
    final lookaheadResult = _collectLookaheadWords(scanner);
    final words = [firstWord, ...lookaheadResult.words];
    final spaceLengths = lookaheadResult.spaceLengths;

    for (var count = words.length; count >= 2; count--) {
      final candidateWords = words.sublist(0, count);
      final candidateLexeme = candidateWords.join(' ');
      final normalizedCandidate = normalizer.normalize(candidateLexeme);
      final tokenType = _wordTokens[normalizedCandidate];
      if (tokenType != null) {
        final additionalAdvance = _calculateAdditionalAdvance(
          candidateWords,
          spaceLengths,
        );
        return WordPhraseMatch(
          tokenType: tokenType,
          fullLexeme: _buildRawLexeme(scanner, firstWord, additionalAdvance),
          additionalCharactersToAdvance: additionalAdvance,
        );
      }
    }

    final normalizedSingle = normalizer.normalize(firstWord);
    final singleTokenType = _wordTokens[normalizedSingle];
    if (singleTokenType != null) {
      return WordPhraseMatch(
        tokenType: singleTokenType,
        fullLexeme: firstWord,
        additionalCharactersToAdvance: 0,
      );
    }
    return null;
  }

  _LookaheadWords _collectLookaheadWords(CharacterScanner scanner) {
    final words = <String>[];
    final spaceLengths = <int>[];
    var currentOffset = 0;

    for (var i = 1; i < _maxWordCount; i++) {
      final spaces = _countLookaheadSpaces(scanner, currentOffset);
      if (spaces == 0) break;
      final wordStart = currentOffset + spaces;
      final word = _readLookaheadWord(scanner, wordStart);
      if (word.isEmpty) break;

      words.add(word);
      spaceLengths.add(spaces);
      currentOffset = wordStart + word.length;
    }
    return _LookaheadWords(words: words, spaceLengths: spaceLengths);
  }

  int _countLookaheadSpaces(CharacterScanner scanner, int fromOffset) {
    var count = 0;
    while (true) {
      final character = scanner.peekAhead(fromOffset + count);
      if (character == ' ' || character == '\t') {
        count++;
      } else {
        break;
      }
    }
    return count;
  }

  String _readLookaheadWord(CharacterScanner scanner, int fromOffset) {
    final buffer = StringBuffer();
    var offset = fromOffset;
    while (true) {
      final character = scanner.peekAhead(offset);
      if (character.isEmpty || !_isValidContinuation(character)) {
        break;
      }
      buffer.write(character);
      offset++;
    }
    return buffer.toString();
  }

  bool _isValidContinuation(String character) =>
      profile.identifierAlphabet.isValidContinuationCharacter(character);

  int _calculateAdditionalAdvance(
    List<String> words,
    List<int> spaceLengths,
  ) {
    var total = 0;
    for (var i = 1; i < words.length; i++) {
      total += spaceLengths[i - 1] + words[i].length;
    }
    return total;
  }

  String _buildRawLexeme(
    CharacterScanner scanner,
    String firstWord,
    int additionalChars,
  ) {
    final buffer = StringBuffer(firstWord);
    for (var i = 0; i < additionalChars; i++) {
      buffer.write(scanner.peekAhead(i));
    }
    return buffer.toString();
  }
}

final class _LookaheadWords {
  final List<String> words;
  final List<int> spaceLengths;

  const _LookaheadWords({
    required this.words,
    required this.spaceLengths,
  });
}
