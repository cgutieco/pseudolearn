#![forbid(unsafe_code)]

use crate::builder::FunctionBuilder;
use crate::expressions::{ExpressionState, lower_expression_with_state};
use pseudolearn_ir::{IrSpan, Operand, Operation, PredicateKind, ValueId};
use pseudolearn_semantic::BuiltinKind;
use pseudolearn_semantic::ExpressionId;
use pseudolearn_semantic::expression_model::BinaryOperator;

pub fn lower_builtin_call(
    builtin: BuiltinKind,
    arguments: &[ValueId],
    span: Option<IrSpan>,
    builder: &mut FunctionBuilder,
) -> ValueId {
    let operation = builtin_operation(builtin);
    let operands = arguments.iter().copied().map(Operand::Value).collect();
    let result_value = builder.next_value();
    builder.emit_with_target(operation, operands, (Some(result_value), span));
    result_value
}

fn builtin_operation(builtin: BuiltinKind) -> Operation {
    match builtin {
        BuiltinKind::SquareRoot => Operation::MathSqrt,
        BuiltinKind::AbsoluteValue => Operation::MathAbs,
        BuiltinKind::NaturalLogarithm => Operation::MathLn,
        BuiltinKind::Exponential => Operation::MathExp,
        BuiltinKind::Sine => Operation::MathSin,
        BuiltinKind::Cosine => Operation::MathCos,
        BuiltinKind::ArcTangent => Operation::MathAtan,
        BuiltinKind::Truncate => Operation::RealTrunc,
        BuiltinKind::Round => Operation::RealRound,
        BuiltinKind::Length => Operation::TextLength,
        BuiltinKind::CharacterAt => Operation::TextCharAt,
        BuiltinKind::CharacterCode => Operation::CharCode,
        BuiltinKind::CharacterFromCode => Operation::CharFromCode,
        BuiltinKind::TextToInteger => Operation::TextToInteger,
        BuiltinKind::TextToReal => Operation::TextToReal,
        BuiltinKind::ToText => Operation::TextFormat,
        BuiltinKind::Snapshot => Operation::SnapshotCopy,
        BuiltinKind::ShallowCopy => Operation::ObjectCopy,
        BuiltinKind::Random => Operation::HostRandom,
        BuiltinKind::Contains
        | BuiltinKind::EndsWith
        | BuiltinKind::Join
        | BuiltinKind::PositionOf
        | BuiltinKind::ReplaceAll
        | BuiltinKind::Split
        | BuiltinKind::StartsWith
        | BuiltinKind::Substring
        | BuiltinKind::Trim => Operation::Unreachable,
        other => numeric_operation(other).unwrap_or(Operation::Unreachable),
    }
}

pub fn select_integer_binary_operation(operator: BinaryOperator) -> Option<Operation> {
    match operator {
        BinaryOperator::Add => Some(Operation::IntAdd),
        BinaryOperator::Subtract => Some(Operation::IntSub),
        BinaryOperator::Multiply => Some(Operation::IntMul),
        BinaryOperator::Divide | BinaryOperator::IntegerDivide => Some(Operation::IntDiv),
        BinaryOperator::Modulo => Some(Operation::IntMod),
        BinaryOperator::Power => Some(Operation::IntPow),
        _ => None,
    }
}

pub fn select_real_binary_operation(operator: BinaryOperator) -> Option<Operation> {
    match operator {
        BinaryOperator::Add => Some(Operation::RealAdd),
        BinaryOperator::Subtract => Some(Operation::RealSub),
        BinaryOperator::Multiply => Some(Operation::RealMul),
        BinaryOperator::Divide | BinaryOperator::IntegerDivide => Some(Operation::RealDiv),
        BinaryOperator::Power => Some(Operation::RealPow),
        _ => None,
    }
}

pub fn select_comparison_predicate(operator: BinaryOperator) -> Option<PredicateKind> {
    match operator {
        BinaryOperator::Equal => Some(PredicateKind::Equal),
        BinaryOperator::NotEqual => Some(PredicateKind::NotEqual),
        BinaryOperator::Less => Some(PredicateKind::LessThan),
        BinaryOperator::LessEqual => Some(PredicateKind::LessEqual),
        BinaryOperator::Greater => Some(PredicateKind::GreaterThan),
        BinaryOperator::GreaterEqual => Some(PredicateKind::GreaterEqual),
        _ => None,
    }
}

pub fn lower_builtin(
    arguments: &[ExpressionId],
    function: BuiltinKind,
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> ValueId {
    if function == BuiltinKind::Snapshot {
        return arguments
            .first()
            .map(|argument| crate::snapshot_values::copy(*argument, span, state))
            .and_then(|values| values.first().copied())
            .unwrap_or_else(|| state.builder.next_value());
    }
    let mut lowered = Vec::new();
    for &argument_id in arguments {
        lowered.push(lower_expression_with_state(argument_id, state));
    }
    if let Some(value) = integer_extremum(function, (arguments, &lowered), span, state) {
        return value;
    }
    lower_builtin_call(function, &lowered, span, state.builder)
}

fn numeric_operation(builtin: BuiltinKind) -> Option<Operation> {
    Some(match builtin {
        BuiltinKind::Tangent => Operation::MathTan,
        BuiltinKind::ArcSine => Operation::MathAsin,
        BuiltinKind::ArcCosine => Operation::MathAcos,
        BuiltinKind::ArcTangent2 => Operation::MathAtan2,
        BuiltinKind::Logarithm10 => Operation::MathLog10,
        BuiltinKind::Logarithm2 => Operation::MathLog2,
        BuiltinKind::Floor => Operation::RealFloor,
        BuiltinKind::Ceiling => Operation::RealCeil,
        BuiltinKind::Minimum => Operation::RealMin,
        BuiltinKind::Maximum => Operation::RealMax,
        _ => return None,
    })
}

fn integer_extremum(
    function: BuiltinKind,
    (arguments, lowered): (&[ExpressionId], &[ValueId]),
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> Option<ValueId> {
    if matches!(function, BuiltinKind::Minimum | BuiltinKind::Maximum)
        && arguments.first().is_some_and(|argument| {
            state
                .context
                .module
                .expressions
                .types
                .get(usize::try_from(argument.0).unwrap_or(usize::MAX))
                .is_some_and(|kind| {
                    state.context.module.types.get(*kind) == pseudolearn_semantic::Type::Integer
                })
        })
    {
        let operation = if function == BuiltinKind::Minimum {
            Operation::IntMin
        } else {
            Operation::IntMax
        };
        return Some(crate::collections::emit(
            operation,
            lowered.iter().copied().map(Operand::Value).collect(),
            span,
            state,
        ));
    }
    None
}
