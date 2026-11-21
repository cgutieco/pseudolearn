import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/execution/read_value_type.dart';
import 'package:pseudolearn_app/engine/rust/rust_read_request_tracker.dart';
import 'package:pseudolearn_app/engine/rust/rust_wire_models.dart';

RustEvent _event(String name, {String node = 'n1', String? type}) => RustEvent(
  eventClass: name,
  line: 4,
  depth: 1,
  data: {'tipo': ?type},
  nodeId: node,
);

void main() {
  group('RustReadRequestTracker', () {
    test('opens a request for the first designator with its type', () {
      final tracker = RustReadRequestTracker();
      final request = tracker.open(
        _event('input_requested', type: 'entero'),
        'Leer a, b;',
        null,
      );
      expect(request.designator, 'a');
      expect(request.valueType, ReadValueType.integer);
      expect(request.line, 4);
      expect(request.rejection, isNull);
      expect(tracker.request, same(request));
    });

    test('an accepted value moves to the next designator', () {
      final tracker = RustReadRequestTracker()
        ..open(_event('input_requested', type: 'entero'), 'Leer a, b;', null);
      final answered = tracker.receive();
      final next = tracker.open(
        _event('input_requested', type: 'cadena'),
        'Leer a, b;',
        null,
      );
      expect(answered?.designator, 'a');
      expect(next.designator, 'b');
      expect(next.valueType, ReadValueType.text);
      expect(tracker.request, same(next));
    });

    test('a request without an answer in between is a rejection', () {
      final tracker = RustReadRequestTracker()
        ..open(_event('input_requested', type: 'entero'), 'Leer a;', null)
        ..submit('veinte');
      final retry = tracker.open(
        _event('input_requested', type: 'entero'),
        'Leer a;',
        'Se esperaba un valor de tipo Entero',
      );
      expect(retry.designator, 'a');
      expect(retry.rejection?.rejectedText, 'veinte');
      expect(retry.rejection?.message, 'Se esperaba un valor de tipo Entero');
    });

    test('a rejection of a value that was not typed here has no text', () {
      final tracker = RustReadRequestTracker()
        ..open(_event('input_requested', type: 'entero'), 'Leer a;', null);
      final retry = tracker.open(
        _event('input_requested', type: 'entero'),
        'Leer a;',
        null,
      );
      expect(retry.rejection, isNotNull);
      expect(retry.rejection?.rejectedText, isNull);
    });

    test(
      'entering the same statement again starts from its first designator',
      () {
        final tracker = RustReadRequestTracker()
          ..open(_event('input_requested'), 'Leer a, b;', null)
          ..receive()
          ..enter(_event('statement_entered'));
        final request = tracker.open(
          _event('input_requested'),
          'Leer a, b;',
          null,
        );
        expect(request.designator, 'a');
        expect(request.rejection, isNull);
      },
    );

    test('another statement starts its own count', () {
      final tracker = RustReadRequestTracker()
        ..open(_event('input_requested'), 'Leer a;', null)
        ..receive();
      final request = tracker.open(
        _event('input_requested', node: 'n2'),
        'Leer z;',
        null,
      );
      expect(request.designator, 'z');
      expect(request.rejection, isNull);
    });

    test('submitting and clearing leave no open request', () {
      final tracker = RustReadRequestTracker()
        ..open(_event('input_requested'), 'Leer a;', null)
        ..submit('1');
      expect(tracker.request, isNull);
      tracker.clear();
      expect(tracker.receive(), isNull);
    });

    test('an unknown type leaves the request untyped', () {
      final request = RustReadRequestTracker().open(
        _event('input_requested', type: 'matriz'),
        'Leer a;',
        null,
      );
      expect(request.valueType, isNull);
    });
  });
}
