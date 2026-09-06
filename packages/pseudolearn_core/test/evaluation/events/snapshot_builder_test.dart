import 'package:pseudolearn_core/src/domain/pseudo_integer.dart';
import 'package:pseudolearn_core/src/domain/span.dart';
import 'package:pseudolearn_core/src/evaluation/environment/call_frame.dart';
import 'package:pseudolearn_core/src/evaluation/events/snapshot_builder.dart';
import 'package:pseudolearn_core/src/evaluation/values/runtime_value.dart';
import 'package:pseudolearn_core/src/semantic/symbols/symbol.dart';
import 'package:test/test.dart';

VariableSymbol _variable(String name) =>
    VariableSymbol(name: name, span: Span.zero);

void main() {
  const builder = SnapshotBuilder();

  test('an empty frame produces an empty variable list', () {
    final snapshot = builder.build([CallFrame(subroutineName: 'Principal')]);
    expect(snapshot.frames, hasLength(1));
    expect(snapshot.frames.single.variables, isEmpty);
  });

  test('a declared-without-value variable shows hasValue false and no value',
      () {
    final frame = CallFrame(subroutineName: 'Principal');
    frame.scope.cellFor(_variable('x'));

    final snapshot = builder.build([frame]);

    final entry = snapshot.frames.single.variables.single;
    expect(entry.name, equals('x'));
    expect(entry.hasValue, isFalse);
    expect(entry.value, isNull);
  });

  test('an assigned variable shows its value', () {
    final frame = CallFrame(subroutineName: 'Principal');
    frame.scope
        .cellFor(_variable('x'))
        .assign(IntegerValue(PseudoInteger.fromInt(7)));

    final snapshot = builder.build([frame]);

    final entry = snapshot.frames.single.variables.single;
    expect(entry.hasValue, isTrue);
    expect(entry.value, equals(IntegerValue(PseudoInteger.fromInt(7))));
  });

  test('frames appear from oldest (algorithm) to newest (current call)', () {
    final algorithmFrame = CallFrame(subroutineName: 'Principal');
    final callFrame = CallFrame(subroutineName: 'Sumar');

    final snapshot = builder.build([algorithmFrame, callFrame]);

    expect(snapshot.frames[0].subroutineName, equals('Principal'));
    expect(snapshot.frames[1].subroutineName, equals('Sumar'));
  });
}
