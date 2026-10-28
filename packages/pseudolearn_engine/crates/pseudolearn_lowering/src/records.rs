#![forbid(unsafe_code)]

use crate::expressions::ExpressionState;
use crate::record_values::lower_range;
use crate::spans::resolve_span;
use crate::statement_context::StatementContext;
use pseudolearn_ir::{IrSpan, Operand, Operation, ValueId};
use pseudolearn_semantic::expression_model::{BinaryOperator, HirPlace};
use pseudolearn_semantic::hir::HirModule;
use pseudolearn_semantic::identities::{ExpressionId, LocalId, TypeId};
use pseudolearn_semantic::types::Type;

pub(crate) fn targets(local: LocalId, module: &HirModule) -> Vec<LocalId> {
    module
        .record_locals
        .get(&local)
        .cloned()
        .unwrap_or_else(|| vec![local])
}

pub(crate) fn record_width(type_id: TypeId, module: &HirModule) -> Option<usize> {
    let Type::Record(record) = module.types.representation(type_id) else {
        return None;
    };
    usize::try_from(record.0)
        .ok()
        .and_then(|slot| module.records.get(slot))
        .map(|model| model.leaf_types.len())
}

pub(crate) fn expression_width(expression: ExpressionId, module: &HirModule) -> Option<usize> {
    usize::try_from(expression.0)
        .ok()
        .and_then(|slot| module.expressions.types.get(slot))
        .and_then(|type_id| record_width(*type_id, module))
}

pub(crate) fn slice_targets(
    local: LocalId,
    range: (u32, TypeId),
    module: &HirModule,
) -> Vec<LocalId> {
    let (offset, type_id) = range;
    let width = record_width(type_id, module).unwrap_or(1);
    targets(local, module)
        .into_iter()
        .skip(usize::try_from(offset).unwrap_or(usize::MAX))
        .take(width)
        .collect()
}

pub(crate) fn destination_targets(destination: &HirPlace, module: &HirModule) -> Vec<LocalId> {
    match destination {
        HirPlace::Local(local) => targets(*local, module),
        HirPlace::RecordField {
            local,
            offset,
            type_id,
        } => slice_targets(*local, (*offset, *type_id), module),
        _ => Vec::new(),
    }
}

pub(crate) fn lower_record_assignment(
    destination: &HirPlace,
    value: ExpressionId,
    span: Option<IrSpan>,
    context: &mut StatementContext<'_, '_>,
) {
    let module = context.expression_context.module;
    let width = expression_width(value, module).unwrap_or(0);
    let mut state = ExpressionState {
        context: context.expression_context,
        environment: &mut *context.environment,
        builder: &mut *context.builder,
    };
    let values = lower_range(value, (0, width), &mut state);
    for (local, component_value) in destination_targets(destination, module)
        .into_iter()
        .zip(values)
    {
        crate::statements_assignment::lower_assign_local(local, component_value, span, context);
    }
}

pub(crate) fn lower_return(
    expression: ExpressionId,
    context: &mut StatementContext<'_, '_>,
) -> bool {
    if context.builder.result_cells.is_empty() {
        return false;
    }
    let module = context.expression_context.module;
    let width = expression_width(expression, module).unwrap_or(0);
    let cells = context.builder.result_cells.clone();
    let mut state = ExpressionState {
        context: context.expression_context,
        environment: &mut *context.environment,
        builder: &mut *context.builder,
    };
    let values = lower_range(expression, (0, width), &mut state);
    for (cell, value) in cells.into_iter().zip(values) {
        context.builder.emit_void(
            Operation::CellStore,
            vec![Operand::Value(cell), Operand::Value(value)],
            None,
        );
    }
    true
}

pub(crate) fn lower_equality(
    operator: BinaryOperator,
    operands: (ExpressionId, ExpressionId),
    span: pseudolearn_source::Span,
    state: &mut ExpressionState<'_, '_>,
) -> ValueId {
    let (left, right) = operands;
    let module = state.context.module;
    let width = expression_width(left, module).unwrap_or(0);
    let first = lower_range(left, (0, width), state);
    let second = lower_range(right, (0, width), state);
    let ir_span = resolve_span(span, state.context.source);
    let leaves = leaf_types(left, module);
    let mut comparisons = Vec::new();
    for ((left_value, right_value), leaf) in first.into_iter().zip(second).zip(leaves) {
        comparisons.push(crate::expressions_binary::lower_binary_operation(
            BinaryOperator::Equal,
            (left_value, right_value),
            (leaf, ir_span),
            (module, &mut *state.builder),
        ));
    }
    let all = conjunction(&comparisons, state.builder);
    if operator == BinaryOperator::NotEqual {
        let negated = state.builder.next_value();
        state.builder.emit_with_target(
            Operation::BoolNot,
            vec![Operand::Value(all)],
            (Some(negated), ir_span),
        );
        return negated;
    }
    all
}

fn leaf_types(expression: ExpressionId, module: &HirModule) -> Vec<TypeId> {
    let record = usize::try_from(expression.0)
        .ok()
        .and_then(|slot| module.expressions.types.get(slot))
        .and_then(|type_id| match module.types.representation(*type_id) {
            Type::Record(record) => Some(record),
            _ => None,
        });
    record
        .and_then(|record| usize::try_from(record.0).ok())
        .and_then(|slot| module.records.get(slot))
        .map(|model| model.leaf_types.clone())
        .unwrap_or_default()
}

fn constant_true(builder: &mut crate::builder::FunctionBuilder) -> ValueId {
    let truth = builder.next_value();
    builder.emit_with_target(
        Operation::ConstBool,
        vec![Operand::LiteralBool(true)],
        (Some(truth), None),
    );
    truth
}

fn conjunction(values: &[ValueId], builder: &mut crate::builder::FunctionBuilder) -> ValueId {
    let Some((last, leading)) = values.split_last() else {
        return constant_true(builder);
    };
    if leading.is_empty() {
        return *last;
    }
    let false_block = builder.create_block();
    let merge_block = builder.create_block();
    for value in leading {
        let next_block = builder.create_block();
        crate::enum_output::branch(*value, (next_block, false_block), builder);
        builder.set_current_block(next_block);
    }
    builder.emit_void(
        Operation::Jump,
        vec![Operand::BlockTarget {
            target_block: merge_block,
            arguments: vec![*last],
        }],
        None,
    );
    crate::expressions_logical::lower_constant_boolean_branch(
        false,
        false_block,
        merge_block,
        builder,
    );
    builder.set_current_block(merge_block);
    let result = builder.next_value();
    builder.add_block_parameter(merge_block, result, pseudolearn_ir::IrType::Bool);
    result
}
