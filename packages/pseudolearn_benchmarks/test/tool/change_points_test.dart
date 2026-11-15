import 'package:test/test.dart';

import '../../tool/change_points.dart';

void main() {
  test('does not invent a change for constant samples', () {
    expect(detectChangePoints(List.filled(30, 10)), isEmpty);
  });
  test('detects an abrupt persistent level change', () {
    expect(
      detectChangePoints([...List.filled(15, 10.0), ...List.filled(15, 20.0)]),
      contains(15),
    );
  });
  test('does not infer stationarity from insufficient samples', () {
    expect(detectChangePoints([]), isEmpty);
    expect(detectChangePoints([1]), isEmpty);
  });
}
