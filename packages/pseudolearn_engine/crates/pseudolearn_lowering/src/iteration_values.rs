use crate::expressions::ExpressionState;
use crate::statement_context::StatementContext;
use crate::statements_for_each::Iteration;
use pseudolearn_ir::{Operand, Operation, ValueId};

pub(crate) fn binding_values(
    iteration: &Iteration,
    position: ValueId,
    context: &mut StatementContext<'_, '_>,
) -> Vec<Vec<ValueId>> {
    let mut values = Vec::new();
    let mut state = ExpressionState {
        context: context.expression_context,
        environment: context.environment,
        builder: context.builder,
    };
    if let Some(model) = &iteration.descriptor {
        if model.key.is_some() {
            values.push(vec![scalar(
                Operation::CollectionKey,
                iteration,
                position,
                &mut state,
            )]);
        }
        values.push(crate::collections::load(
            model,
            (iteration.collection, position),
            iteration.span,
            &mut state,
        ));
    } else {
        values.push(vec![scalar(
            Operation::ArrayLoad,
            iteration,
            position,
            &mut state,
        )]);
    }
    values
}

fn scalar(
    operation: Operation,
    iteration: &Iteration,
    position: ValueId,
    state: &mut ExpressionState<'_, '_>,
) -> ValueId {
    crate::collections::emit(
        operation,
        vec![
            Operand::Value(iteration.collection),
            Operand::Value(position),
        ],
        iteration.span,
        state,
    )
}
