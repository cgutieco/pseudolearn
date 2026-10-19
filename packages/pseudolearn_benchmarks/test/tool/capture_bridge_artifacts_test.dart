import '../../tool/capture_bridge_artifacts.dart';

import 'package:test/test.dart';

void main() {
  group('isWithinBudget', () {
    test('accepts an artifact at the byte limit', () {
      expect(isWithinBudget(600, 600), isTrue);
    });

    test('rejects an artifact above the byte limit', () {
      expect(isWithinBudget(601, 600), isFalse);
    });
  });
}
