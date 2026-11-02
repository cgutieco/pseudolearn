import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_projection.dart';

ExecutionProjection projection({
  List<String> events = const ['a', 'b'],
  List<String> output = const ['programOutput:1'],
  String termination = 'completed',
  String? failure,
}) => ExecutionProjection(
  events: events,
  output: output,
  termination: termination,
  failure: failure,
);

void main() {
  group('ExecutionProjection', () {
    test('identical projections are equal and have no divergence', () {
      expect(projection(), projection());
      expect(projection().hashCode, projection().hashCode);
      expect(projection().firstDivergence(projection()), isNull);
    });

    test('empty projections are equal', () {
      final empty = projection(events: [], output: []);
      expect(empty.firstDivergence(projection(events: [], output: [])), isNull);
    });

    test('the first differing event index is reported', () {
      expect(projection().firstDivergence(projection(events: ['a', 'x'])), 1);
      expect(projection().firstDivergence(projection(events: ['x', 'b'])), 0);
    });

    test('a truncated or extended event list diverges at the shared length', () {
      expect(projection().firstDivergence(projection(events: ['a'])), 1);
      expect(
        projection().firstDivergence(projection(events: ['a', 'b', 'c'])),
        2,
      );
    });

    test('termination, failure and output differences are divergences', () {
      expect(projection().firstDivergence(projection(termination: 'failed')), 2);
      expect(projection().firstDivergence(projection(failure: 'x')), 2);
      expect(projection().firstDivergence(projection(output: [])), 2);
      expect(projection(), isNot(projection(output: ['programOutput:2'])));
    });
  });
}
