use crate::statement_context::StatementContext;
use pseudolearn_ir::{BlockId, IrSpan, Operand, Operation, PredicateKind, ValueId};
use pseudolearn_semantic::expression_model::{HirExpression, Literal};
use pseudolearn_semantic::statement_model::HirCase;
use pseudolearn_semantic::types::Type;

pub(crate) fn dispatch(
    cases: &[HirCase],
    selector: (ValueId, pseudolearn_semantic::identities::ExpressionId),
    targets: (&[BlockId], BlockId),
    context: &mut StatementContext<'_, '_>,
) {
    if let Some(entries) = table(cases, targets.0, context) {
        let mut operands = vec![
            Operand::Value(selector.0),
            Operand::BlockTarget {
                target_block: targets.1,
                arguments: Vec::new(),
            },
        ];
        for (ordinal, target) in entries {
            operands.extend([
                Operand::LiteralI64(ordinal),
                Operand::BlockTarget {
                    target_block: target,
                    arguments: Vec::new(),
                },
            ]);
        }
        context.builder.emit_void(Operation::Switch, operands, None);
    } else {
        chain(cases, selector, targets, context);
    }
}

fn table(
    cases: &[HirCase],
    targets: &[BlockId],
    context: &StatementContext<'_, '_>,
) -> Option<Vec<(i64, BlockId)>> {
    let mut entries = Vec::new();
    for (case, target) in cases.iter().zip(targets) {
        for label in &case.labels {
            let Some(HirExpression::Literal(Literal::Integer(ordinal))) =
                usize::try_from(label.0).ok().and_then(|index| {
                    context
                        .expression_context
                        .module
                        .expressions
                        .kinds
                        .get(index)
                })
            else {
                return None;
            };
            if !(0..65_536).contains(ordinal) {
                return None;
            }
            entries.push((*ordinal, *target));
        }
    }
    entries.sort_by_key(|(ordinal, _)| *ordinal);
    if entries.len() < 4
        || entries.last()?.0.saturating_sub(entries.first()?.0)
            > i64::try_from(entries.len().saturating_mul(2)).ok()?
    {
        return None;
    }
    Some(entries)
}

fn chain(
    cases: &[HirCase],
    selector: (ValueId, pseudolearn_semantic::identities::ExpressionId),
    targets: (&[BlockId], BlockId),
    context: &mut StatementContext<'_, '_>,
) {
    for (case, target) in cases.iter().zip(targets.0) {
        for label in &case.labels {
            let following = context.builder.create_block();
            let condition = compare(*label, selector, None, context);
            crate::enum_output::branch(condition, (*target, following), context.builder);
            context.builder.set_current_block(following);
        }
    }
    context.builder.emit_void(
        Operation::Jump,
        vec![Operand::BlockTarget {
            target_block: targets.1,
            arguments: Vec::new(),
        }],
        None,
    );
}

fn compare(
    label: pseudolearn_semantic::identities::ExpressionId,
    selector: (ValueId, pseudolearn_semantic::identities::ExpressionId),
    span: Option<IrSpan>,
    context: &mut StatementContext<'_, '_>,
) -> ValueId {
    let label_value = crate::expressions::lower_expression(
        label,
        context.expression_context,
        context.environment,
        context.builder,
    );
    let operation = comparison_operation(selector.1, context);
    let result = context.builder.next_value();
    context.builder.emit_with_target(
        operation,
        vec![
            Operand::Predicate(PredicateKind::Equal),
            Operand::Value(selector.0),
            Operand::Value(label_value),
        ],
        (Some(result), span),
    );
    result
}

fn comparison_operation(
    selector: pseudolearn_semantic::identities::ExpressionId,
    context: &StatementContext<'_, '_>,
) -> Operation {
    let kind = usize::try_from(selector.0)
        .ok()
        .and_then(|index| {
            context
                .expression_context
                .module
                .expressions
                .types
                .get(index)
        })
        .map(|kind| context.expression_context.module.types.get(*kind));
    match kind {
        Some(Type::String) => Operation::TextCmp,
        Some(Type::Character) => Operation::CharCmp,
        Some(Type::Boolean) => Operation::BoolCmp,
        _ => Operation::IntCmp,
    }
}
