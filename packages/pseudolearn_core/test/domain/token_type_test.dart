import 'package:pseudolearn_core/src/domain/token_type.dart';
import 'package:test/test.dart';

void main() {
  group('TokenType', () {
    test('contains expected total count of tokens', () {
      expect(TokenType.values.length, equals(80));
    });

    test('open tokens are correctly identified', () {
      final openTokens = TokenType.values.where((t) => t.isOpen).toSet();
      expect(
        openTokens,
        equals({
          TokenType.identifier,
          TokenType.integerLiteral,
          TokenType.realLiteral,
          TokenType.stringLiteral,
          TokenType.characterLiteral,
          TokenType.endOfLine,
          TokenType.endOfFile,
        }),
      );
      expect(openTokens.length, equals(7));
    });

    test('reserved tokens are complementary to open tokens', () {
      for (final token in TokenType.values) {
        expect(
          token.isReserved,
          equals(!token.isOpen),
          reason: 'Token $token must be either open or reserved',
        );
      }
    });

    test('reserved tokens count is 73', () {
      final reservedCount = TokenType.values.where((t) => t.isReserved).length;
      expect(reservedCount, equals(73));
    });
  });
}
