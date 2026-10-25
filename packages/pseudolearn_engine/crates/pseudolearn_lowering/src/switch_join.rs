use crate::environment::VariableEnvironment;
use crate::statement_context::StatementContext;
use pseudolearn_ir::{BlockId, Operand, Operation, OriginEntry, VariableId};
use pseudolearn_semantic::identities::LocalId;

pub(crate) fn finish(
    exits: &[(BlockId, VariableEnvironment)],
    target: BlockId,
    context: &mut StatementContext<'_, '_>,
) {
    let locals: Vec<LocalId> = context.environment.values.keys().copied().collect();
    let mut locals = locals;
    locals.sort();
    let mut arguments = vec![Vec::new(); exits.len()];
    for local in locals {
        merge(local, (exits, &mut arguments), target, context);
    }
    for ((block, _), arguments) in exits.iter().zip(arguments) {
        context.builder.set_current_block(*block);
        context.builder.emit_void(
            Operation::Jump,
            vec![Operand::BlockTarget {
                target_block: target,
                arguments,
            }],
            None,
        );
    }
    context.builder.set_current_block(target);
}

fn merge(
    local: LocalId,
    inputs: (
        &[(BlockId, VariableEnvironment)],
        &mut [Vec<pseudolearn_ir::ValueId>],
    ),
    target: BlockId,
    context: &mut StatementContext<'_, '_>,
) {
    if context.environment.get_cell(local).is_some() {
        return;
    }
    let values: Vec<_> = inputs
        .0
        .iter()
        .filter_map(|(_, environment)| environment.get_value(local))
        .collect();
    let Some(first) = values.first().copied() else {
        return;
    };
    if values.iter().all(|value| *value == first) {
        context.environment.bind_value(local, first);
        return;
    }
    let parameter = context.builder.next_value();
    let kind = crate::environment::get_local_ir_type(local, context.expression_context.module);
    context.builder.add_block_parameter(target, parameter, kind);
    for (arguments, value) in inputs.1.iter_mut().zip(values) {
        arguments.push(value);
    }
    context.environment.bind_value(local, parameter);
    context.environment.mark_assigned(local);
    record_origin(local, parameter, context);
}

fn record_origin(
    local: LocalId,
    parameter: pseudolearn_ir::ValueId,
    context: &mut StatementContext<'_, '_>,
) {
    if let Some(declaration) = usize::try_from(local.0)
        .ok()
        .and_then(|index| context.expression_context.module.locals.get(index))
    {
        context.origins.push(OriginEntry {
            function: context.builder.name.clone(),
            value: parameter,
            variable: VariableId(local.0),
            name: declaration.name.clone(),
        });
    }
}
