use crate::expressions::{ExpressionState, lower_expression_with_state};
use pseudolearn_ir::{IrSpan, Operand, Operation, ValueId};
use pseudolearn_semantic::{expression_model::HirExpression, identities::ExpressionId};

pub(crate) fn lower_cell(
    argument: ExpressionId,
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> ValueId {
    let kind = usize::try_from(argument.0)
        .ok()
        .and_then(|index| state.context.module.expressions.kinds.get(index))
        .cloned();
    let (operation, mut operands) = match kind {
        Some(HirExpression::Field { receiver, field }) => field_cell(receiver, field, state),
        Some(HirExpression::Element { array, indices }) => element_cell(array, &indices, state),
        Some(HirExpression::RecordField { .. }) => {
            return crate::record_cells::lower_range(argument, (0, 1), span, state)
                .into_iter()
                .next()
                .unwrap_or_else(|| lower_expression_with_state(argument, state));
        }
        _ => return lower_expression_with_state(argument, state),
    };
    let result = state.builder.next_value();
    state.builder.emit_with_target(
        operation,
        std::mem::take(&mut operands),
        (Some(result), span),
    );
    result
}

fn field_cell(
    receiver: ExpressionId,
    field: pseudolearn_semantic::identities::FieldId,
    state: &mut ExpressionState<'_, '_>,
) -> (Operation, Vec<Operand>) {
    let receiver = lower_expression_with_state(receiver, state);
    let name = field_name(field, state.context.module);
    (
        Operation::CellField,
        vec![Operand::Value(receiver), Operand::Identifier(name)],
    )
}

fn element_cell(
    array: ExpressionId,
    indices: &[ExpressionId],
    state: &mut ExpressionState<'_, '_>,
) -> (Operation, Vec<Operand>) {
    let array = lower_expression_with_state(array, state);
    let mut operands = vec![Operand::Value(array)];
    for index in indices {
        operands.push(Operand::Value(lower_expression_with_state(*index, state)));
    }
    (Operation::CellElement, operands)
}

fn field_name(
    field: pseudolearn_semantic::identities::FieldId,
    module: &pseudolearn_semantic::hir::HirModule,
) -> String {
    module
        .classes
        .iter()
        .flat_map(|class| &class.fields)
        .find(|candidate| candidate.id == field)
        .map(|field| field.name.clone())
        .unwrap_or_default()
}
