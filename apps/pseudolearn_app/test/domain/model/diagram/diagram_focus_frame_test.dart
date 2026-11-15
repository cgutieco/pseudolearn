import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_focus_frame.dart';

void main() {
  group('DiagramFocusFrame', () {
    test('two frames with the same measurements are the same frame', () {
      const one = DiagramFocusFrame(x: 10, y: 20, width: 30, height: 40);
      const other = DiagramFocusFrame(x: 10, y: 20, width: 30, height: 40);

      expect(one, equals(other));
      expect(one.hashCode, equals(other.hashCode));
    });

    test('a frame moved by one pixel is another frame', () {
      const one = DiagramFocusFrame(x: 10, y: 20, width: 30, height: 40);
      const moved = DiagramFocusFrame(x: 11, y: 20, width: 30, height: 40);

      expect(one, isNot(equals(moved)));
    });

    test('the centre sits halfway along each side', () {
      const frame = DiagramFocusFrame(x: 10, y: 20, width: 30, height: 40);

      expect(frame.centerX, 25);
      expect(frame.centerY, 40);
    });

    test('a frame without area has its centre on its own corner', () {
      const frame = DiagramFocusFrame(x: 7, y: 9, width: 0, height: 0);

      expect(frame.centerX, 7);
      expect(frame.centerY, 9);
    });
  });
}
