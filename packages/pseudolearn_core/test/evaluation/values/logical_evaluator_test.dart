import 'package:pseudolearn_core/src/evaluation/values/logical_evaluator.dart';
import 'package:test/test.dart';

void main() {
  const logic = LogicalEvaluator();

  test('not negates', () {
    expect(logic.not(true), isFalse);
    expect(logic.not(false), isTrue);
  });

  test('and is true only when both are true', () {
    expect(logic.and(true, true), isTrue);
    expect(logic.and(true, false), isFalse);
    expect(logic.and(false, false), isFalse);
  });

  test('or is true when at least one is true', () {
    expect(logic.or(false, false), isFalse);
    expect(logic.or(true, false), isTrue);
    expect(logic.or(false, true), isTrue);
  });
}
