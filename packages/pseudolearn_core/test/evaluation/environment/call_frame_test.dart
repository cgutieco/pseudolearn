import 'package:pseudolearn_core/src/domain/position.dart';
import 'package:pseudolearn_core/src/domain/span.dart';
import 'package:pseudolearn_core/src/evaluation/environment/call_frame.dart';
import 'package:test/test.dart';

void main() {
  group('CallFrame', () {
    test('the top-level algorithm frame has no call span', () {
      final frame = CallFrame(subroutineName: 'Principal');
      expect(frame.callSpan, isNull);
      expect(frame.scope.entries, isEmpty);
    });

    test('a subroutine frame carries where it was called from', () {
      final span = Span(
        start: const Position(line: 3, column: 1, offset: 10),
        end: const Position(line: 3, column: 5, offset: 14),
      );
      final frame = CallFrame(subroutineName: 'Sumar', callSpan: span);
      expect(frame.callSpan, equals(span));
    });

    test('each frame gets its own fresh scope', () {
      final a = CallFrame(subroutineName: 'A');
      final b = CallFrame(subroutineName: 'A');
      expect(identical(a.scope, b.scope), isFalse);
    });
  });
}
