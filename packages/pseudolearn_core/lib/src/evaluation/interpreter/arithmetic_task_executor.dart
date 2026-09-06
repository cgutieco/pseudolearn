import '../../domain/diagnostic.dart';
import '../../domain/diagnostic_argument.dart';
import '../../domain/diagnostic_code.dart';
import '../../domain/pseudo_integer.dart';
import '../../domain/span.dart';
import '../../syntax/ast/operators.dart';
import '../values/comparison_evaluator.dart';
import '../values/integer_arithmetic.dart';
import '../values/integer_division.dart';
import '../values/logical_evaluator.dart';
import '../values/real_arithmetic.dart';
import '../values/runtime_value.dart';
import 'execution_task.dart';
import 'interpreter.dart';
import 'interpreter_frame.dart';

typedef _NumericOps = ({
  PseudoInteger? Function(PseudoInteger, PseudoInteger) integer,
  double Function(double, double) real,
});

typedef _Computed = ({RuntimeValue? value, Diagnostic? diagnostic});

final class ArithmeticTaskExecutor {
  static const IntegerArithmetic _integerArithmetic = IntegerArithmetic();
  static const IntegerDivision _integerDivision = IntegerDivision();
  static const RealArithmetic _realArithmetic = RealArithmetic();
  static const ComparisonEvaluator _comparison = ComparisonEvaluator();
  static const LogicalEvaluator _logic = LogicalEvaluator();

  final Interpreter engine;

  ArithmeticTaskExecutor(this.engine);

  Diagnostic? finishUnary(FinishUnaryTask task, InterpreterFrame frame) {
    final operand = frame.popValue();
    return switch (task.node.operator) {
      UnaryOperator.positive => _pushOrNull(frame, operand),
      UnaryOperator.not => _pushOrNull(
          frame, BooleanValue(_logic.not((operand as BooleanValue).value))),
      UnaryOperator.negate =>
        _finishNegate(operand, task.node.operatorSpan, frame),
    };
  }

  Diagnostic? _pushOrNull(InterpreterFrame frame, RuntimeValue value) {
    frame.pushOperand(value);
    return null;
  }

  Diagnostic? _finishNegate(
      RuntimeValue operand, Span span, InterpreterFrame frame) {
    if (operand is RealValue) {
      return _pushOrNull(frame, RealValue(-operand.value));
    }
    final result = _integerArithmetic.negate((operand as IntegerValue).value);
    if (result == null) {
      return engine.diagnostic(DiagnosticCode.integerOverflow, span);
    }
    return _pushOrNull(frame, IntegerValue(result));
  }

  void evaluateLogicalRight(
      EvaluateLogicalRightTask task, InterpreterFrame frame) {
    final left = (frame.popValue() as BooleanValue).value;
    final isAnd = task.node.operator == BinaryOperator.and;
    if ((isAnd && !left) || (!isAnd && left)) {
      frame.pushOperand(BooleanValue(left));
      return;
    }
    frame.pushTask(FinishLogicalTask(task.node, left));
    frame.pushTask(EvaluateExpressionTask(task.node.right));
  }

  void finishLogical(FinishLogicalTask task, InterpreterFrame frame) {
    final right = (frame.popValue() as BooleanValue).value;
    final result = task.node.operator == BinaryOperator.and
        ? _logic.and(task.leftValue, right)
        : _logic.or(task.leftValue, right);
    frame.pushOperand(BooleanValue(result));
  }

  Diagnostic? finishBinary(FinishBinaryTask task, InterpreterFrame frame) {
    final right = frame.popValue();
    final left = frame.popValue();
    final span = task.node.operatorSpan;
    return switch (task.node.operator) {
      BinaryOperator.add =>
        _applyComputed(frame, _computeAdd(left, right, span)),
      BinaryOperator.subtract =>
        _applyComputed(frame, _computeSubtract(left, right, span)),
      BinaryOperator.multiply =>
        _applyComputed(frame, _computeMultiply(left, right, span)),
      BinaryOperator.divide =>
        _applyComputed(frame, _computeDivide(left, right, span)),
      BinaryOperator.integerDivide => _applyComputed(
          frame, _computeIntegerDivision(left, right, span, isModulo: false)),
      BinaryOperator.modulo => _applyComputed(
          frame, _computeIntegerDivision(left, right, span, isModulo: true)),
      BinaryOperator.power =>
        _applyComputed(frame, _computePower(left, right, span)),
      BinaryOperator.lessThan =>
        _finishOrdered(left, right, frame, (c) => c < 0),
      BinaryOperator.lessThanOrEqual =>
        _finishOrdered(left, right, frame, (c) => c <= 0),
      BinaryOperator.greaterThan =>
        _finishOrdered(left, right, frame, (c) => c > 0),
      BinaryOperator.greaterThanOrEqual =>
        _finishOrdered(left, right, frame, (c) => c >= 0),
      BinaryOperator.equal =>
        _pushOrNull(frame, BooleanValue(_comparison.equalValues(left, right))),
      BinaryOperator.notEqual =>
        _pushOrNull(frame, BooleanValue(!_comparison.equalValues(left, right))),
      BinaryOperator.and ||
      BinaryOperator.or =>
        throw StateError('and/or must go through EvaluateLogicalRightTask'),
    };
  }

  Diagnostic? _applyComputed(InterpreterFrame frame, _Computed result) {
    if (result.diagnostic != null) return result.diagnostic;
    frame.pushOperand(result.value!);
    return null;
  }

  Diagnostic? _finishOrdered(
    RuntimeValue left,
    RuntimeValue right,
    InterpreterFrame frame,
    bool Function(int comparison) predicate,
  ) =>
      _pushOrNull(frame,
          BooleanValue(predicate(_comparison.compareOrdered(left, right))));

  _Computed _computeAdd(RuntimeValue left, RuntimeValue right, Span span) {
    if (left is StringValue ||
        left is CharacterValue ||
        right is StringValue ||
        right is CharacterValue) {
      return (
        value: StringValue(_textOf(left) + _textOf(right)),
        diagnostic: null
      );
    }
    return _computeArithmetic(
      left,
      right,
      span,
      (integer: _integerArithmetic.add, real: _realArithmetic.add),
    );
  }

  _Computed _computeSubtract(
          RuntimeValue left, RuntimeValue right, Span span) =>
      _computeArithmetic(
        left,
        right,
        span,
        (integer: _integerArithmetic.subtract, real: _realArithmetic.subtract),
      );

  _Computed _computeMultiply(
          RuntimeValue left, RuntimeValue right, Span span) =>
      _computeArithmetic(
        left,
        right,
        span,
        (integer: _integerArithmetic.multiply, real: _realArithmetic.multiply),
      );

  String _textOf(RuntimeValue value) => switch (value) {
        StringValue(:final value) => value,
        CharacterValue(:final value) => value,
        _ => throw StateError('Non-text operand reached concatenation: $value'),
      };

  _Computed _computeArithmetic(
      RuntimeValue left, RuntimeValue right, Span span, _NumericOps ops) {
    if (left is IntegerValue && right is IntegerValue) {
      final result = ops.integer(left.value, right.value);
      if (result == null) {
        return (
          value: null,
          diagnostic: engine.diagnostic(DiagnosticCode.integerOverflow, span)
        );
      }
      return (value: IntegerValue(result), diagnostic: null);
    }
    final result = ops.real(_asDouble(left), _asDouble(right));
    if (!_realArithmetic.isFiniteResult(result)) {
      return (
        value: null,
        diagnostic: engine.diagnostic(DiagnosticCode.nonFiniteRealResult, span)
      );
    }
    return (value: RealValue(result), diagnostic: null);
  }

  double _asDouble(RuntimeValue value) => switch (value) {
        IntegerValue(:final value) => value.value.toDouble(),
        RealValue(:final value) => value,
        _ => throw StateError('Non-numeric operand reached arithmetic: $value'),
      };

  _Computed _computeDivide(RuntimeValue left, RuntimeValue right, Span span) {
    if (_asDouble(right) == 0.0) {
      return (
        value: null,
        diagnostic: engine.diagnostic(DiagnosticCode.divisionByZero, span)
      );
    }
    final result = _realArithmetic.divide(_asDouble(left), _asDouble(right));
    if (!_realArithmetic.isFiniteResult(result)) {
      return (
        value: null,
        diagnostic: engine.diagnostic(DiagnosticCode.nonFiniteRealResult, span)
      );
    }
    return (value: RealValue(result), diagnostic: null);
  }

  _Computed _computeIntegerDivision(
    RuntimeValue left,
    RuntimeValue right,
    Span span, {
    required bool isModulo,
  }) {
    final dividend = (left as IntegerValue).value;
    final divisor = (right as IntegerValue).value;
    if (divisor == PseudoInteger.zero) {
      return (
        value: null,
        diagnostic: engine.diagnostic(DiagnosticCode.divisionByZero, span)
      );
    }
    final result = isModulo
        ? _integerDivision.remainder(dividend, divisor)
        : _integerDivision.quotient(dividend, divisor);
    if (result == null) {
      return (
        value: null,
        diagnostic: engine.diagnostic(DiagnosticCode.integerOverflow, span)
      );
    }
    return (value: IntegerValue(result), diagnostic: null);
  }

  _Computed _computePower(RuntimeValue left, RuntimeValue right, Span span) {
    if (left is IntegerValue && right is IntegerValue) {
      if (right.value.isNegative) {
        return (
          value: null,
          diagnostic: engine.diagnostic(
            DiagnosticCode.negativeIntegerExponent,
            span,
            arguments: {
              'exponent': IntegerValueDiagnosticArgument(right.value)
            },
          ),
        );
      }
      final result = _integerArithmetic.power(left.value, right.value);
      if (result == null) {
        return (
          value: null,
          diagnostic: engine.diagnostic(DiagnosticCode.integerOverflow, span)
        );
      }
      return (value: IntegerValue(result), diagnostic: null);
    }
    final result = _realArithmetic.power(_asDouble(left), _asDouble(right));
    if (!_realArithmetic.isFiniteResult(result)) {
      return (
        value: null,
        diagnostic: engine.diagnostic(DiagnosticCode.nonFiniteRealResult, span)
      );
    }
    return (value: RealValue(result), diagnostic: null);
  }
}
