import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/platform/system_clock.dart';

void main() {
  group('SystemClock Tests (CIM-F4)', () {
    test('now returns realistic current timestamp', () {
      const clock = SystemClock();
      final before = DateTime.now();
      final clockTime = clock.now();
      final after = DateTime.now();

      expect(clockTime.isAfter(before.subtract(const Duration(milliseconds: 50))), isTrue);
      expect(clockTime.isBefore(after.add(const Duration(milliseconds: 50))), isTrue);
    });
  });
}
