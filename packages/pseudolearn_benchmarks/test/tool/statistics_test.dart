import 'package:test/test.dart';

import '../../tool/statistics.dart';

void main() {
  test('constant independent samples have exact confidence interval', () {
    expect(confidenceInterval([2, 2, 2]), [2, 2]);
  });
  test('empty samples have no invented confidence interval', () {
    expect(confidenceInterval([]), isEmpty);
  });
  test('bootstrap is reproducible', () {
    expect(confidenceInterval([1, 2, 3]), confidenceInterval([1, 2, 3]));
  });
}
