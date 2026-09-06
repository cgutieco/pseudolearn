import '../../domain/token_type.dart';
import '../ast/operators.dart';

final class OperatorPrecedence {
  static const int lowest = 0;
  static const int orPrecedence = 1;
  static const int andPrecedence = 2;
  static const int equalityPrecedence = 3;
  static const int relationalPrecedence = 4;
  static const int additivePrecedence = 5;
  static const int multiplicativePrecedence = 6;
  static const int powerPrecedence = 7;
  static const int unaryPrecedence = 8;
  static const int postfixPrecedence = 9;

  static int getInfixPrecedence(TokenType type) => switch (type) {
        TokenType.or => orPrecedence,
        TokenType.and => andPrecedence,
        TokenType.equal || TokenType.notEqual => equalityPrecedence,
        TokenType.lessThan ||
        TokenType.lessThanOrEqual ||
        TokenType.greaterThan ||
        TokenType.greaterThanOrEqual =>
          relationalPrecedence,
        TokenType.plus || TokenType.minus => additivePrecedence,
        TokenType.multiply ||
        TokenType.divide ||
        TokenType.integerDivide ||
        TokenType.modulo =>
          multiplicativePrecedence,
        TokenType.power => powerPrecedence,
        TokenType.leftBracket || TokenType.dot => postfixPrecedence,
        _ => lowest,
      };

  static bool isRightAssociative(TokenType type) => type == TokenType.power;

  static BinaryOperator? getBinaryOperator(TokenType type) => switch (type) {
        TokenType.plus => BinaryOperator.add,
        TokenType.minus => BinaryOperator.subtract,
        TokenType.multiply => BinaryOperator.multiply,
        TokenType.divide => BinaryOperator.divide,
        TokenType.integerDivide => BinaryOperator.integerDivide,
        TokenType.modulo => BinaryOperator.modulo,
        TokenType.power => BinaryOperator.power,
        TokenType.equal => BinaryOperator.equal,
        TokenType.notEqual => BinaryOperator.notEqual,
        TokenType.lessThan => BinaryOperator.lessThan,
        TokenType.lessThanOrEqual => BinaryOperator.lessThanOrEqual,
        TokenType.greaterThan => BinaryOperator.greaterThan,
        TokenType.greaterThanOrEqual => BinaryOperator.greaterThanOrEqual,
        TokenType.and => BinaryOperator.and,
        TokenType.or => BinaryOperator.or,
        _ => null,
      };

  static UnaryOperator? getUnaryOperator(TokenType type) => switch (type) {
        TokenType.plus => UnaryOperator.positive,
        TokenType.minus => UnaryOperator.negate,
        TokenType.not => UnaryOperator.not,
        _ => null,
      };
}
