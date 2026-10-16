#![forbid(unsafe_code)]

use crate::builder::FunctionBuilder;
use crate::expressions::lower_expression;
use crate::statement_context::StatementContext;
use crate::statements_for::ForLoopDescriptor;
use pseudolearn_ir::{BlockId, IrSpan, IrType, Operand, Operation, PredicateKind, ValueId};
use pseudolearn_semantic::identities::ExpressionId;

pub fn lower_for_condition(
    controls: (ValueId, ValueId),
    step_value: ValueId,
    span: Option<IrSpan>,
    builder: &mut FunctionBuilder,
) -> ValueId {
    let is_positive = check_step_sign(step_value, builder);
    let positive_block = builder.create_block();
    let negative_block = builder.create_block();
    let join_block = builder.create_block();

    create_condition_branches(is_positive, (positive_block, negative_block), builder);

    builder.set_current_block(positive_block);
    emit_for_comparison(
        PredicateKind::LessEqual,
        controls,
        (span, join_block),
        builder,
    );

    builder.set_current_block(negative_block);
    emit_for_comparison(
        PredicateKind::GreaterEqual,
        controls,
        (span, join_block),
        builder,
    );

    builder.set_current_block(join_block);
    let condition_value = builder.next_value();
    builder.add_block_parameter(join_block, condition_value, IrType::Bool);
    condition_value
}

fn check_step_sign(step_value: ValueId, builder: &mut FunctionBuilder) -> ValueId {
    let zero_value = builder.next_value();
    builder.emit_with_target(
        Operation::ConstI64,
        vec![Operand::LiteralI64(0)],
        (Some(zero_value), None),
    );
    let is_positive = builder.next_value();
    builder.emit_with_target(
        Operation::IntCmp,
        vec![
            Operand::Predicate(PredicateKind::GreaterEqual),
            Operand::Value(step_value),
            Operand::Value(zero_value),
        ],
        (Some(is_positive), None),
    );
    is_positive
}

fn create_condition_branches(
    is_positive: ValueId,
    target_blocks: (BlockId, BlockId),
    builder: &mut FunctionBuilder,
) {
    let (positive_block, negative_block) = target_blocks;
    builder.emit_void(
        Operation::Branch,
        vec![
            Operand::Value(is_positive),
            Operand::BlockTarget {
                target_block: positive_block,
                arguments: vec![],
            },
            Operand::BlockTarget {
                target_block: negative_block,
                arguments: vec![],
            },
        ],
        None,
    );
}

fn emit_for_comparison(
    predicate: PredicateKind,
    controls: (ValueId, ValueId),
    target: (Option<IrSpan>, BlockId),
    builder: &mut FunctionBuilder,
) {
    let (span, join_block) = target;
    let (current_control, ending_value) = controls;
    let condition = builder.next_value();
    builder.emit_with_target(
        Operation::IntCmp,
        vec![
            Operand::Predicate(predicate),
            Operand::Value(current_control),
            Operand::Value(ending_value),
        ],
        (Some(condition), span),
    );
    builder.emit_void(
        Operation::Jump,
        vec![Operand::BlockTarget {
            target_block: join_block,
            arguments: vec![condition],
        }],
        None,
    );
}

pub fn evaluate_for_bounds(
    descriptor: &ForLoopDescriptor<'_>,
    span: Option<IrSpan>,
    context: &mut StatementContext<'_, '_>,
) -> (ValueId, ValueId, ValueId) {
    let initial_value = lower_expression(
        descriptor.initial,
        context.expression_context,
        context.environment,
        context.builder,
    );
    let ending_value = lower_expression(
        descriptor.ending,
        context.expression_context,
        context.environment,
        context.builder,
    );
    let ending_value = freeze_control_value(ending_value, span, context.builder);
    let step_value = resolve_step_value(descriptor.step, span, context);
    let step_value = freeze_control_value(step_value, span, context.builder);
    context.builder.emit_void(
        Operation::LoopCheckStep,
        vec![Operand::Value(step_value)],
        span,
    );
    (initial_value, ending_value, step_value)
}

fn resolve_step_value(
    optional_step: Option<ExpressionId>,
    span: Option<IrSpan>,
    context: &mut StatementContext<'_, '_>,
) -> ValueId {
    if let Some(step_expression) = optional_step {
        lower_expression(
            step_expression,
            context.expression_context,
            context.environment,
            context.builder,
        )
    } else {
        let default_step = context.builder.next_value();
        context.builder.emit_with_target(
            Operation::ConstI64,
            vec![Operand::LiteralI64(1)],
            (Some(default_step), span),
        );
        default_step
    }
}

fn freeze_control_value(
    value: ValueId,
    span: Option<IrSpan>,
    builder: &mut FunctionBuilder,
) -> ValueId {
    let zero = builder.next_value();
    builder.emit_with_target(
        Operation::ConstI64,
        vec![Operand::LiteralI64(0)],
        (Some(zero), None),
    );
    let frozen = builder.next_value();
    builder.emit_with_target(
        Operation::IntAdd,
        vec![Operand::Value(value), Operand::Value(zero)],
        (Some(frozen), span),
    );
    frozen
}
