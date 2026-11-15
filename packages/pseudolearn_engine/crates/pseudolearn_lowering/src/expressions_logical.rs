#![forbid(unsafe_code)]

use crate::builder::FunctionBuilder;
use crate::environment::VariableEnvironment;
use crate::expressions::{ExpressionContext, lower_expression};
use pseudolearn_ir::{BlockId, IrType, Operand, Operation, ValueId};
use pseudolearn_semantic::identities::ExpressionId;

pub struct LogicalExpressionState<'state, 'context> {
    pub context: &'state ExpressionContext<'context>,
    pub environment: &'state mut VariableEnvironment,
    pub builder: &'state mut FunctionBuilder,
}

pub fn lower_short_circuit_and(
    operands: (ExpressionId, ExpressionId),
    state: &mut LogicalExpressionState<'_, '_>,
) -> ValueId {
    let (left, right) = operands;
    let left_value = lower_expression(left, state.context, state.environment, state.builder);
    let evaluation_block = state.builder.create_block();
    let false_block = state.builder.create_block();
    let merge_block = state.builder.create_block();

    state.builder.emit_void(
        Operation::Branch,
        vec![
            Operand::Value(left_value),
            Operand::BlockTarget {
                target_block: evaluation_block,
                arguments: vec![],
            },
            Operand::BlockTarget {
                target_block: false_block,
                arguments: vec![],
            },
        ],
        None,
    );

    lower_evaluation_branch(right, evaluation_block, merge_block, state);
    lower_constant_boolean_branch(false, false_block, merge_block, state.builder);

    state.builder.set_current_block(merge_block);
    let result = state.builder.next_value();
    state
        .builder
        .add_block_parameter(merge_block, result, IrType::Bool);
    result
}

pub fn lower_short_circuit_or(
    operands: (ExpressionId, ExpressionId),
    state: &mut LogicalExpressionState<'_, '_>,
) -> ValueId {
    let (left, right) = operands;
    let left_value = lower_expression(left, state.context, state.environment, state.builder);
    let evaluation_block = state.builder.create_block();
    let true_block = state.builder.create_block();
    let merge_block = state.builder.create_block();

    state.builder.emit_void(
        Operation::Branch,
        vec![
            Operand::Value(left_value),
            Operand::BlockTarget {
                target_block: true_block,
                arguments: vec![],
            },
            Operand::BlockTarget {
                target_block: evaluation_block,
                arguments: vec![],
            },
        ],
        None,
    );

    lower_constant_boolean_branch(true, true_block, merge_block, state.builder);
    lower_evaluation_branch(right, evaluation_block, merge_block, state);

    state.builder.set_current_block(merge_block);
    let result = state.builder.next_value();
    state
        .builder
        .add_block_parameter(merge_block, result, IrType::Bool);
    result
}

fn lower_evaluation_branch(
    expression: ExpressionId,
    evaluation_block: BlockId,
    merge_block: BlockId,
    state: &mut LogicalExpressionState<'_, '_>,
) {
    state.builder.set_current_block(evaluation_block);
    let right_value = lower_expression(expression, state.context, state.environment, state.builder);
    let right_block = state.builder.current_block.unwrap_or(evaluation_block);
    state.builder.set_current_block(right_block);
    state.builder.emit_void(
        Operation::Jump,
        vec![Operand::BlockTarget {
            target_block: merge_block,
            arguments: vec![right_value],
        }],
        None,
    );
}

pub(crate) fn lower_constant_boolean_branch(
    value: bool,
    constant_block: BlockId,
    merge_block: BlockId,
    builder: &mut FunctionBuilder,
) {
    builder.set_current_block(constant_block);
    let constant_value = builder.next_value();
    builder.emit_with_target(
        Operation::ConstBool,
        vec![Operand::LiteralBool(value)],
        (Some(constant_value), None),
    );
    builder.emit_void(
        Operation::Jump,
        vec![Operand::BlockTarget {
            target_block: merge_block,
            arguments: vec![constant_value],
        }],
        None,
    );
}
