#![forbid(unsafe_code)]

use crate::builder::FunctionBuilder;
use pseudolearn_ir::{IrSpan, Operand, Operation, PredicateKind, ValueId};
use pseudolearn_semantic::BuiltinKind;
use pseudolearn_semantic::expression_model::BinaryOperator;

pub fn lower_builtin_call(
    builtin: BuiltinKind,
    arguments: &[ValueId],
    span: Option<IrSpan>,
    builder: &mut FunctionBuilder,
) -> ValueId {
    let operation = match builtin {
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
        BuiltinKind::ShallowCopy => Operation::ObjectCopy,
        BuiltinKind::Random => Operation::HostRandom,
    };
    let operands = arguments.iter().copied().map(Operand::Value).collect();
    let result_value = builder.next_value();
    builder.emit_with_target(operation, operands, (Some(result_value), span));
    result_value
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
