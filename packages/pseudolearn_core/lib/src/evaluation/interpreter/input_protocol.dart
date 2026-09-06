import '../../domain/diagnostic_argument.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/node_id.dart';
import '../../domain/primitive_type.dart';
import '../../domain/span.dart';
import '../environment/reference_binding.dart';
import '../events/execution_event.dart';
import '../values/runtime_value.dart';
import 'interpreter.dart';

typedef PendingInput = ({
  NodeId designatorId,
  Span designatorSpan,
  ReferenceBinding binding,
  PrimitiveType? expectedType,
});

final class InputProtocol {
  final Interpreter engine;
  PendingInput? pending;

  InputProtocol(this.engine);

  void begin({
    required NodeId designatorId,
    required Span designatorSpan,
    required ReferenceBinding binding,
    required PrimitiveType? expectedType,
  }) {
    pending = (
      designatorId: designatorId,
      designatorSpan: designatorSpan,
      binding: binding,
      expectedType: expectedType,
    );
  }

  void provideInput(String text) {
    final current = pending;
    if (current == null) return;
    if (current.expectedType == null) {
      _acceptIndeterminate(current, text);
      return;
    }
    _acceptTyped(current, text, current.expectedType!);
  }

  void _acceptIndeterminate(PendingInput current, String text) {
    final classified = engine.readClassifier.classify(text);
    current.binding.write(classified);
    pending = null;
    engine.observer?.onEvent(InputAcceptedEvent(text));
    final name =
        engine.program.resolution.symbolFor(current.designatorId)?.name ?? '';
    final inferred = engine.diagnostic(
      DiagnosticCode.inferredVariableType,
      current.designatorSpan,
      arguments: {
        'lexeme': LexemeDiagnosticArgument(name),
        'type': _typeArgument(classified),
      },
    );
    engine.observer?.onEvent(DiagnosticEmittedEvent(inferred));
  }

  void _acceptTyped(PendingInput current, String text, PrimitiveType expected) {
    final parsed = engine.readClassifier.parseAs(text, expected);
    if (parsed == null) {
      final mismatch = engine.diagnostic(
        DiagnosticCode.readValueTypeMismatch,
        current.designatorSpan,
        arguments: {
          'expected': TypeDiagnosticArgument(expected),
          'found': LexemeDiagnosticArgument(text),
        },
      );
      engine.observer?.onEvent(DiagnosticEmittedEvent(mismatch));
      return;
    }
    current.binding.write(parsed);
    pending = null;
    engine.observer?.onEvent(InputAcceptedEvent(text));
  }

  DiagnosticArgument _typeArgument(RuntimeValue value) => switch (value) {
        IntegerValue() => const TypeDiagnosticArgument(PrimitiveType.integer),
        RealValue() => const TypeDiagnosticArgument(PrimitiveType.real),
        BooleanValue() => const TypeDiagnosticArgument(PrimitiveType.boolean),
        CharacterValue() =>
          const TypeDiagnosticArgument(PrimitiveType.character),
        StringValue() => const TypeDiagnosticArgument(PrimitiveType.string),
        ObjectValue(:final instance) =>
          LexemeDiagnosticArgument(instance.classSymbol.name),
      };
}
