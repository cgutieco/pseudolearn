#![forbid(unsafe_code)]

use crate::builder::FunctionBuilder;
use crate::environment::VariableEnvironment;
use crate::expressions::{ExpressionContext, lower_expression};
use pseudolearn_ir::{IrType, Operand, Operation, PredicateKind, ValueId};
use pseudolearn_semantic::identities::{EnumId, ExpressionId};
use pseudolearn_semantic::types::Type;

pub(crate) fn lower_value(
    expression: ExpressionId,
    context: &ExpressionContext<'_>,
    environment: &mut VariableEnvironment,
    builder: &mut FunctionBuilder,
) -> ValueId {
    if let Some(value) = function_value(expression, context, environment, builder) {
        return value;
    }
    let value = lower_expression(expression, context, environment, builder);
    let enumeration = usize::try_from(expression.0)
        .ok()
        .and_then(|slot| context.module.expressions.types.get(slot))
        .and_then(|type_id| match context.module.types.get(*type_id) {
            Type::Enum(enumeration) => Some(enumeration),
            _ => None,
        });
    match enumeration {
        Some(enumeration) => member_name(value, enumeration, context, builder),
        None => value,
    }
}

fn member_name(
    ordinal: ValueId,
    enumeration: EnumId,
    context: &ExpressionContext<'_>,
    builder: &mut FunctionBuilder,
) -> ValueId {
    let names = usize::try_from(enumeration.0)
        .ok()
        .and_then(|slot| context.module.enums.get(slot))
        .map(|model| model.members.clone())
        .unwrap_or_default();
    let merge_block = builder.create_block();
    for (position, name) in names.iter().enumerate() {
        let is_last = position.saturating_add(1) == names.len();
        if is_last {
            jump_with_name(name, merge_block, builder);
            break;
        }
        let match_block = builder.create_block();
        let next_block = builder.create_block();
        let same = ordinal_equals(ordinal, position, builder);
        branch(same, (match_block, next_block), builder);
        builder.set_current_block(match_block);
        jump_with_name(name, merge_block, builder);
        builder.set_current_block(next_block);
    }
    if names.is_empty() {
        jump_with_name("", merge_block, builder);
    }
    builder.set_current_block(merge_block);
    let result = builder.next_value();
    builder.add_block_parameter(merge_block, result, IrType::Str);
    result
}

fn ordinal_equals(ordinal: ValueId, position: usize, builder: &mut FunctionBuilder) -> ValueId {
    let expected = builder.next_value();
    builder.emit_with_target(
        Operation::ConstI64,
        vec![Operand::LiteralI64(i64::try_from(position).unwrap_or(0))],
        (Some(expected), None),
    );
    let same = builder.next_value();
    builder.emit_with_target(
        Operation::IntCmp,
        vec![
            Operand::Predicate(PredicateKind::Equal),
            Operand::Value(ordinal),
            Operand::Value(expected),
        ],
        (Some(same), None),
    );
    same
}

pub(crate) fn branch(
    condition: ValueId,
    targets: (pseudolearn_ir::BlockId, pseudolearn_ir::BlockId),
    builder: &mut FunctionBuilder,
) {
    builder.emit_void(
        Operation::Branch,
        vec![
            Operand::Value(condition),
            Operand::BlockTarget {
                target_block: targets.0,
                arguments: vec![],
            },
            Operand::BlockTarget {
                target_block: targets.1,
                arguments: vec![],
            },
        ],
        None,
    );
}

fn jump_with_name(name: &str, merge_block: pseudolearn_ir::BlockId, builder: &mut FunctionBuilder) {
    let text = builder.next_value();
    builder.emit_with_target(
        Operation::ConstStr,
        vec![Operand::LiteralStr(name.to_owned())],
        (Some(text), None),
    );
    builder.emit_void(
        Operation::Jump,
        vec![Operand::BlockTarget {
            target_block: merge_block,
            arguments: vec![text],
        }],
        None,
    );
}

fn function_value(
    expression: ExpressionId,
    context: &ExpressionContext<'_>,
    environment: &mut VariableEnvironment,
    builder: &mut FunctionBuilder,
) -> Option<ValueId> {
    if !is_function(expression, context.module) {
        return None;
    }
    let mut state = crate::expressions::ExpressionState {
        context,
        environment,
        builder,
    };
    crate::record_values::lower_range(expression, (0, 2), &mut state);
    let span = usize::try_from(expression.0)
        .ok()
        .and_then(|index| context.module.expressions.spans.get(index))
        .copied();
    let english = span
        .and_then(|span| context.module.source_profiles.get(&span.source_id))
        .is_some_and(|profile| *profile == pseudolearn_semantic::Profile::English);
    let marker = if english {
        "<subroutine>"
    } else {
        "<subprograma>"
    };
    let value = state.builder.next_value();
    state.builder.emit_with_target(
        Operation::ConstStr,
        vec![Operand::LiteralStr(marker.to_owned())],
        (Some(value), None),
    );
    Some(value)
}

fn is_function(expression: ExpressionId, module: &pseudolearn_semantic::HirModule) -> bool {
    usize::try_from(expression.0)
        .ok()
        .and_then(|index| module.expressions.types.get(index))
        .is_some_and(|kind| {
            if let Type::Record(record) = module.types.get(*kind) {
                module.function_types.contains_key(&record)
            } else {
                false
            }
        })
}
