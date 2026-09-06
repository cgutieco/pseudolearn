import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/execution/output_line.dart';
import 'package:pseudolearn_app/engine/execution/projecting_observer.dart';
import 'package:pseudolearn_core/pseudolearn_core.dart';

void main() {
  group('ProjectingObserver', () {
    test('records output and environment updates', () {
      final observer = ProjectingObserver();

      observer.onEvent(const OutputProducedEvent('Hola Mundo'));
      expect(observer.outputLines.length, 1);
      expect(observer.outputLines.first.text, 'Hola Mundo');
      expect(observer.outputLines.first.kind, OutputLineKind.programOutput);

      final frame = FrameSnapshot(
        subroutineName: 'global',
        variables: [
          VariableSnapshotEntry(
            name: 'x',
            hasValue: true,
            value: IntegerValue(PseudoInteger.one),
          ),
        ],
      );
      final env = EnvironmentSnapshot([frame]);

      observer.onEvent(
        StatementEnteredEvent(statementId: const NodeId(1), snapshot: env),
      );

      final step = observer.toExecutionStep(1);
      expect(step.stepNumber, 1);
      expect(step.variables.length, 1);
      expect(step.variables.first.name, 'x');
      expect(step.variables.first.formattedValue, '1');
      expect(step.variables.first.identityBadge, isNull);
    });

    test('projects receiver fields as qualified rows with identity badge', () {
      final observer = ProjectingObserver();

      final classNode = ClassNode(
        id: const NodeId(100),
        span: Span.zero,
        name: 'Vehiculo',
        nameSpan: Span.zero,
        members: const [],
      );

      final classSym = ClassSymbol(
        name: 'Vehiculo',
        span: Span.zero,
        declarationNode: classNode,
      );

      final marcaCell = VariableCell()..assign(const StringValue('Honda'));
      final velocidadCell = VariableCell()
        ..assign(IntegerValue(PseudoInteger.fromInt(75)));

      final instance = ObjectInstance(
        id: 42,
        classSymbol: classSym,
        fields: {
          'marca': marcaCell,
          'velocidad': velocidadCell,
        },
      );

      final frame = FrameSnapshot(
        subroutineName: 'Acelerar',
        receiver: ObjectValue(instance),
        variables: [
          VariableSnapshotEntry(
            name: 'delta',
            hasValue: true,
            value: IntegerValue(PseudoInteger.fromInt(75)),
          ),
        ],
      );

      final env = EnvironmentSnapshot([frame]);
      observer.onEvent(
        StatementEnteredEvent(statementId: const NodeId(2), snapshot: env),
      );

      final step = observer.toExecutionStep(2);
      expect(step.variables, hasLength(3));

      expect(step.variables[0].name, 'delta');
      expect(step.variables[0].formattedValue, '75');
      expect(step.variables[0].identityBadge, isNull);

      expect(step.variables[1].name, 'Este.marca');
      expect(step.variables[1].formattedValue, '"Honda"');
      expect(step.variables[1].identityBadge, 42);

      expect(step.variables[2].name, 'Este.velocidad');
      expect(step.variables[2].formattedValue, '75');
      expect(step.variables[2].identityBadge, 42);
    });

    test('concatenates output fragments until newline delimiter', () {
      final observer = ProjectingObserver();

      observer.onEvent(const OutputProducedEvent('Lectura '));
      observer.onEvent(const OutputProducedEvent('1'));
      observer.onEvent(const OutputProducedEvent(': '));
      observer.onEvent(const OutputProducedEvent('27'));
      observer.onEvent(const OutputProducedEvent(' grados'));
      observer.onEvent(const OutputProducedEvent('\n'));

      observer.onEvent(const OutputProducedEvent('Lectura '));
      observer.onEvent(const OutputProducedEvent('2'));
      observer.onEvent(const OutputProducedEvent(': '));
      observer.onEvent(const OutputProducedEvent('24'));
      observer.onEvent(const OutputProducedEvent(' grados'));
      observer.onEvent(const OutputProducedEvent('\n'));

      expect(observer.outputLines.length, 2);
      expect(observer.outputLines[0].text, 'Lectura 1: 27 grados');
      expect(observer.outputLines[0].kind, OutputLineKind.programOutput);
      expect(observer.outputLines[1].text, 'Lectura 2: 24 grados');
      expect(observer.outputLines[1].kind, OutputLineKind.programOutput);
    });

    test('handles empty lines produced by write statement without arguments', () {
      final observer = ProjectingObserver();

      observer.onEvent(const OutputProducedEvent('Hola'));
      observer.onEvent(const OutputProducedEvent('\n'));
      observer.onEvent(const OutputProducedEvent('\n'));
      observer.onEvent(const OutputProducedEvent('Mundo'));
      observer.onEvent(const OutputProducedEvent('\n'));

      expect(observer.outputLines.length, 3);
      expect(observer.outputLines[0].text, 'Hola');
      expect(observer.outputLines[1].text, '');
      expect(observer.outputLines[2].text, 'Mundo');
    });

    test('interleaves user input echoes and program outputs cleanly', () {
      final observer = ProjectingObserver();

      observer.onEvent(const OutputProducedEvent('Ingrese valor: '));
      observer.onEvent(const InputAcceptedEvent('42'));
      observer.onEvent(const OutputProducedEvent('Recibido: 42'));
      observer.onEvent(const OutputProducedEvent('\n'));

      expect(observer.outputLines.length, 3);
      expect(observer.outputLines[0].text, 'Ingrese valor: ');
      expect(observer.outputLines[0].kind, OutputLineKind.programOutput);
      expect(observer.outputLines[1].text, '42');
      expect(observer.outputLines[1].kind, OutputLineKind.userInputEcho);
      expect(observer.outputLines[2].text, 'Recibido: 42');
      expect(observer.outputLines[2].kind, OutputLineKind.programOutput);
    });
  });
}
