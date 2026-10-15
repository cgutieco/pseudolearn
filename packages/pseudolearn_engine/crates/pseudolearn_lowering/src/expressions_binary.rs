#![forbid(unsafe_code)]

use crate::builder::FunctionBuilder;
use crate::expressions_builtins::{
    select_comparison_predicate, select_integer_binary_operation, select_real_binary_operation,
};
use pseudolearn_ir::{IrSpan, Operand, Operation, PredicateKind, ValueId};
use pseudolearn_semantic::expression_model::BinaryOperator;
use pseudolearn_semantic::hir::HirModule;
use pseudolearn_semantic::identities::TypeId;
use pseudolearn_semantic::types::Type;

pub fn lower_binary_operation(
    operator: BinaryOperator,
    operands: (ValueId, ValueId),
    target: (TypeId, Option<IrSpan>),
    context: (&HirModule, &mut FunctionBuilder),
) -> ValueId {
    let (operand_type, span) = target;
    let (module, builder) = context;
    match module.types.get(operand_type) {
        Type::Integer => lower_integer_binary(operator, operands, span, builder),
        Type::Real => lower_real_binary(operator, operands, span, builder),
        Type::Boolean => lower_boolean_binary(operator, operands, span, builder),
        Type::String => lower_string_binary(operator, operands, span, builder),
        Type::Character => lower_character_binary(operator, operands, span, builder),
        _ => lower_fallback_binary(operator, operands, span, builder),
    }
}

fn lower_integer_binary(
    operator: BinaryOperator,
    operands: (ValueId, ValueId),
    span: Option<IrSpan>,
    builder: &mut FunctionBuilder,
) -> ValueId {
    let (left, right) = operands;
    if let Some(operation) = select_integer_binary_operation(operator) {
        let result = builder.next_value();
        let instruction_operands = vec![Operand::Value(left), Operand::Value(right)];
        builder.emit_with_target(operation, instruction_operands, (Some(result), span));
        result
    } else if let Some(predicate) = select_comparison_predicate(operator) {
        let result = builder.next_value();
        let instruction_operands = vec![
            Operand::Predicate(predicate),
            Operand::Value(left),
            Operand::Value(right),
        ];
        builder.emit_with_target(
            Operation::IntCmp,
            instruction_operands,
            (Some(result), span),
        );
        result
    } else {
        left
    }
}

fn lower_real_binary(
    operator: BinaryOperator,
    operands: (ValueId, ValueId),
    span: Option<IrSpan>,
    builder: &mut FunctionBuilder,
) -> ValueId {
    let (left, right) = operands;
    if let Some(operation) = select_real_binary_operation(operator) {
        let result = builder.next_value();
        let instruction_operands = vec![Operand::Value(left), Operand::Value(right)];
        builder.emit_with_target(operation, instruction_operands, (Some(result), span));
        result
    } else if let Some(predicate) = select_comparison_predicate(operator) {
        let result = builder.next_value();
        let instruction_operands = vec![
            Operand::Predicate(predicate),
            Operand::Value(left),
            Operand::Value(right),
        ];
        builder.emit_with_target(
            Operation::RealCmp,
            instruction_operands,
            (Some(result), span),
        );
        result
    } else {
        left
    }
}

fn lower_boolean_binary(
    operator: BinaryOperator,
    operands: (ValueId, ValueId),
    span: Option<IrSpan>,
    builder: &mut FunctionBuilder,
) -> ValueId {
    let (left, right) = operands;
    match operator {
        BinaryOperator::Equal | BinaryOperator::NotEqual => {
            let predicate = select_comparison_predicate(operator).unwrap_or(PredicateKind::Equal);
            let result = builder.next_value();
            let instruction_operands = vec![
                Operand::Predicate(predicate),
                Operand::Value(left),
                Operand::Value(right),
            ];
            builder.emit_with_target(
                Operation::BoolCmp,
                instruction_operands,
                (Some(result), span),
            );
            result
        }
        _ => left,
    }
}

fn lower_string_binary(
    operator: BinaryOperator,
    operands: (ValueId, ValueId),
    span: Option<IrSpan>,
    builder: &mut FunctionBuilder,
) -> ValueId {
    let (left, right) = operands;
    if operator == BinaryOperator::Add {
        let result = builder.next_value();
        let instruction_operands = vec![Operand::Value(left), Operand::Value(right)];
        builder.emit_with_target(
            Operation::TextConcat,
            instruction_operands,
            (Some(result), span),
        );
        result
    } else if let Some(predicate) = select_comparison_predicate(operator) {
        let result = builder.next_value();
        let instruction_operands = vec![
            Operand::Predicate(predicate),
            Operand::Value(left),
            Operand::Value(right),
        ];
        builder.emit_with_target(
            Operation::TextCmp,
            instruction_operands,
            (Some(result), span),
        );
        result
    } else {
        left
    }
}

fn lower_character_binary(
    operator: BinaryOperator,
    operands: (ValueId, ValueId),
    span: Option<IrSpan>,
    builder: &mut FunctionBuilder,
) -> ValueId {
    let (left, right) = operands;
    if let Some(predicate) = select_comparison_predicate(operator) {
        let result = builder.next_value();
        let instruction_operands = vec![
            Operand::Predicate(predicate),
            Operand::Value(left),
            Operand::Value(right),
        ];
        builder.emit_with_target(
            Operation::CharCmp,
            instruction_operands,
            (Some(result), span),
        );
        result
    } else {
        left
    }
}

fn lower_fallback_binary(
    operator: BinaryOperator,
    operands: (ValueId, ValueId),
    span: Option<IrSpan>,
    builder: &mut FunctionBuilder,
) -> ValueId {
    let (left, right) = operands;
    if let Some(predicate) = select_comparison_predicate(operator) {
        let result = builder.next_value();
        let instruction_operands = vec![
            Operand::Predicate(predicate),
            Operand::Value(left),
            Operand::Value(right),
        ];
        builder.emit_with_target(
            Operation::RefCmp,
            instruction_operands,
            (Some(result), span),
        );
        result
    } else {
        left
    }
}
