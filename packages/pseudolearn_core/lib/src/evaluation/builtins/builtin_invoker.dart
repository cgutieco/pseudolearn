import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_argument.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/profile/builtin_function.dart';
import '../../domain/pseudo_integer.dart';
import '../../domain/severity.dart';
import '../../domain/span.dart';
import '../values/random_source.dart';
import '../values/runtime_value.dart';
import '../values/value_formatter.dart';
import 'conversion_builtins.dart';
import 'math_builtins.dart';
import 'rounding_builtins.dart';
import 'text_builtins.dart';

typedef BuiltinInvocationResult = ({
  RuntimeValue? value,
  Diagnostic? diagnostic
});

final class BuiltinInvoker {
  final MathBuiltins _math = const MathBuiltins();
  final RoundingBuiltins _rounding = const RoundingBuiltins();
  final TextBuiltins _text = const TextBuiltins();
  final ConversionBuiltins _conversion;
  final RandomSource _random;
  final Severity Function(DiagnosticCode code) _severityFor;
  final int Function()? _nextInstanceId;

  BuiltinInvoker({
    required RandomSource random,
    required ValueFormatter formatter,
    required Severity Function(DiagnosticCode code) severityFor,
    int Function()? nextInstanceId,
  })  : _random = random,
        _conversion = ConversionBuiltins(formatter),
        _severityFor = severityFor,
        _nextInstanceId = nextInstanceId;

  BuiltinInvocationResult invoke(
    BuiltinFunction function,
    List<RuntimeValue> arguments,
    Span callSpan,
  ) =>
      _isMathOrRounding(function)
          ? _invokeMath(function, arguments, callSpan)
          : _invokeTextOrConversion(function, arguments, callSpan);

  bool _isMathOrRounding(BuiltinFunction function) => switch (function) {
        BuiltinFunction.squareRoot ||
        BuiltinFunction.absoluteValue ||
        BuiltinFunction.naturalLogarithm ||
        BuiltinFunction.exponential ||
        BuiltinFunction.sine ||
        BuiltinFunction.cosine ||
        BuiltinFunction.arcTangent ||
        BuiltinFunction.truncate ||
        BuiltinFunction.round ||
        BuiltinFunction.random =>
          true,
        _ => false,
      };

  BuiltinInvocationResult _invokeMath(
    BuiltinFunction function,
    List<RuntimeValue> arguments,
    Span callSpan,
  ) =>
      switch (function) {
        BuiltinFunction.squareRoot =>
          _mathUnary(_math.squareRoot, arguments, callSpan),
        BuiltinFunction.absoluteValue =>
          _mathUnary(_math.absoluteValue, arguments, callSpan),
        BuiltinFunction.naturalLogarithm =>
          _mathUnary(_math.naturalLogarithm, arguments, callSpan),
        BuiltinFunction.exponential =>
          _mathUnary(_math.exponential, arguments, callSpan),
        BuiltinFunction.sine => _mathUnary(_math.sine, arguments, callSpan),
        BuiltinFunction.cosine => _mathUnary(_math.cosine, arguments, callSpan),
        BuiltinFunction.arcTangent =>
          _mathUnary(_math.arcTangent, arguments, callSpan),
        BuiltinFunction.truncate =>
          _truncateOrRound(_rounding.truncate, arguments, callSpan),
        BuiltinFunction.round =>
          _truncateOrRound(_rounding.round, arguments, callSpan),
        BuiltinFunction.random => (
            value: RealValue(_rounding.random(_random)),
            diagnostic: null
          ),
        _ => throw StateError('Not a math function: $function'),
      };

  BuiltinInvocationResult _invokeTextOrConversion(
    BuiltinFunction function,
    List<RuntimeValue> arguments,
    Span callSpan,
  ) =>
      switch (function) {
        BuiltinFunction.toText => (
            value: StringValue(_conversion.toText(arguments[0])),
            diagnostic: null
          ),
        BuiltinFunction.textToInteger => _textToInteger(arguments, callSpan),
        BuiltinFunction.textToReal => _textToReal(arguments, callSpan),
        BuiltinFunction.length => (
            value: IntegerValue(
                PseudoInteger.fromInt(_text.length(_string(arguments[0])))),
            diagnostic: null,
          ),
        BuiltinFunction.characterAt => _characterAt(arguments, callSpan),
        BuiltinFunction.characterCode => (
            value: IntegerValue(
              PseudoInteger.fromInt(
                  _text.characterCode(_character(arguments[0]))),
            ),
            diagnostic: null,
          ),
        BuiltinFunction.characterFromCode =>
          _characterFromCode(arguments, callSpan),
        BuiltinFunction.shallowCopy => _shallowCopy(arguments[0]),
        _ => throw StateError('Not a text or conversion function: $function'),
      };

  BuiltinInvocationResult _shallowCopy(RuntimeValue value) {
    if (value is! ObjectValue) {
      throw StateError('Cannot shallowCopy non-object value: $value');
    }
    final nextId = _nextInstanceId != null ? _nextInstanceId() : 1;
    return (
      value: ObjectValue(value.instance.shallowCopy(nextId)),
      diagnostic: null,
    );
  }

  double _numeric(RuntimeValue value) => switch (value) {
        IntegerValue(:final value) => value.value.toDouble(),
        RealValue(:final value) => value,
        _ => throw StateError(
            'Non-numeric argument reached a math builtin: $value'),
      };

  String _string(RuntimeValue value) => (value as StringValue).value;

  String _character(RuntimeValue value) => (value as CharacterValue).value;

  BuiltinInvocationResult _mathUnary(
    double? Function(double) operation,
    List<RuntimeValue> arguments,
    Span callSpan,
  ) {
    final result = operation(_numeric(arguments[0]));
    if (result == null) return _nonFiniteFailure(callSpan);
    return (value: RealValue(result), diagnostic: null);
  }

  BuiltinInvocationResult _truncateOrRound(
    PseudoInteger? Function(double) operation,
    List<RuntimeValue> arguments,
    Span callSpan,
  ) {
    final result = operation(_numeric(arguments[0]));
    if (result == null) return _overflowFailure(callSpan);
    return (value: IntegerValue(result), diagnostic: null);
  }

  BuiltinInvocationResult _textToInteger(
      List<RuntimeValue> arguments, Span callSpan) {
    final text = _string(arguments[0]);
    final result = _conversion.textToInteger(text);
    if (result == null) return _conversionFailure(text, callSpan);
    return (value: IntegerValue(result), diagnostic: null);
  }

  BuiltinInvocationResult _textToReal(
      List<RuntimeValue> arguments, Span callSpan) {
    final text = _string(arguments[0]);
    final result = _conversion.textToReal(text);
    if (result == null) return _conversionFailure(text, callSpan);
    return (value: RealValue(result), diagnostic: null);
  }

  BuiltinInvocationResult _characterAt(
      List<RuntimeValue> arguments, Span callSpan) {
    final text = _string(arguments[0]);
    final index = (arguments[1] as IntegerValue).value.toHostInt();
    final result = _text.characterAt(text, index);
    if (result == null) {
      return _positionFailure(index, _text.length(text), callSpan);
    }
    return (value: CharacterValue(result), diagnostic: null);
  }

  BuiltinInvocationResult _characterFromCode(
      List<RuntimeValue> arguments, Span callSpan) {
    final code = (arguments[0] as IntegerValue).value;
    final result = _text.characterFromCode(code.toHostInt());
    if (result == null) return _invalidCodeFailure(code, callSpan);
    return (value: CharacterValue(result), diagnostic: null);
  }

  BuiltinInvocationResult _nonFiniteFailure(Span span) => (
        value: null,
        diagnostic: Diagnostic(
          code: DiagnosticCode.nonFiniteRealResult,
          severity: _severityFor(DiagnosticCode.nonFiniteRealResult),
          span: span,
        ),
      );

  BuiltinInvocationResult _overflowFailure(Span span) => (
        value: null,
        diagnostic: Diagnostic(
          code: DiagnosticCode.integerOverflow,
          severity: _severityFor(DiagnosticCode.integerOverflow),
          span: span,
        ),
      );

  BuiltinInvocationResult _conversionFailure(String text, Span span) => (
        value: null,
        diagnostic: Diagnostic(
          code: DiagnosticCode.stringToNumberConversionFailed,
          severity: _severityFor(DiagnosticCode.stringToNumberConversionFailed),
          span: span,
          arguments: {'lexeme': LexemeDiagnosticArgument(text)},
        ),
      );

  BuiltinInvocationResult _positionFailure(
          int position, int length, Span span) =>
      (
        value: null,
        diagnostic: Diagnostic(
          code: DiagnosticCode.stringPositionOutOfRange,
          severity: _severityFor(DiagnosticCode.stringPositionOutOfRange),
          span: span,
          arguments: {
            'position': NumberDiagnosticArgument(position),
            'length': NumberDiagnosticArgument(length),
          },
        ),
      );

  BuiltinInvocationResult _invalidCodeFailure(PseudoInteger code, Span span) =>
      (
        value: null,
        diagnostic: Diagnostic(
          code: DiagnosticCode.invalidCharacterCode,
          severity: _severityFor(DiagnosticCode.invalidCharacterCode),
          span: span,
          arguments: {'code': IntegerValueDiagnosticArgument(code)},
        ),
      );
}
