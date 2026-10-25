use crate::expressions::ExpressionState;
use pseudolearn_ir::{IrSpan, Operand, Operation, ValueId};
use pseudolearn_semantic::identities::ExpressionId;
use pseudolearn_semantic::{HirExpression, Passing, Type};

pub(crate) fn lower(
    callee: ExpressionId,
    syntax_arguments: &[ExpressionId],
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> (ValueId, Vec<ValueId>) {
    let values = crate::record_values::lower_range(callee, (0, 2), state);
    let code = values
        .first()
        .copied()
        .unwrap_or_else(|| state.builder.next_value());
    let environment = values
        .get(1)
        .copied()
        .unwrap_or_else(|| state.builder.next_value());
    let (signature, parameters) = signature(callee, state);
    let mut operands = arguments(syntax_arguments, &parameters, (environment, span), state);
    let cells = parameters
        .map(|signature| {
            crate::expressions_complex::allocate_result_cells(signature.result, span, state)
        })
        .unwrap_or_default();
    operands.extend(cells.iter().copied());
    let result = state.builder.next_value();
    let prototype = crate::function_prototypes::name(signature.map_or(u32::MAX, |record| record.0));
    state.builder.emit_with_target(
        Operation::CallIndirect,
        vec![
            Operand::Value(code),
            Operand::FunctionTarget {
                function_name: prototype,
                arguments: operands,
            },
        ],
        (Some(result), span),
    );
    (result, cells)
}

pub(crate) fn aggregate(
    expression: ExpressionId,
    state: &mut ExpressionState<'_, '_>,
) -> Option<Vec<ValueId>> {
    let index = usize::try_from(expression.0).ok()?;
    let kind = state.context.module.expressions.kinds.get(index)?.clone();
    let span = state
        .context
        .module
        .expressions
        .spans
        .get(index)
        .and_then(|span| crate::spans::resolve_span(*span, state.context.source));
    match kind {
        HirExpression::FunctionValue(function) => {
            Some(crate::closure_values::create(function, span, state))
        }
        HirExpression::Captured { function, capture } => Some(crate::closure_values::captured(
            function, capture, span, state,
        )),
        HirExpression::IndirectCall { callee, arguments } => {
            let (_, cells) = lower(callee, &arguments, span, state);
            Some(crate::record_values::load_cells(&cells, span, state))
        }
        _ => None,
    }
}

fn signature(
    callee: ExpressionId,
    state: &ExpressionState<'_, '_>,
) -> (
    Option<pseudolearn_semantic::identities::RecordId>,
    Option<pseudolearn_semantic::function_model::FunctionSignature>,
) {
    let signature = usize::try_from(callee.0)
        .ok()
        .and_then(|index| state.context.module.expressions.types.get(index))
        .and_then(|kind| {
            if let Type::Record(record) = state.context.module.types.get(*kind) {
                Some(record)
            } else {
                None
            }
        });
    let parameters = signature
        .and_then(|record| state.context.module.function_types.get(&record))
        .cloned();
    (signature, parameters)
}

fn arguments(
    arguments: &[ExpressionId],
    parameters: &Option<pseudolearn_semantic::function_model::FunctionSignature>,
    (environment, span): (ValueId, Option<IrSpan>),
    state: &mut ExpressionState<'_, '_>,
) -> Vec<ValueId> {
    let mut operands = vec![environment];
    if let Some(parameters) = &parameters {
        for (argument, (_, passing)) in arguments.iter().zip(&parameters.parameters) {
            if *passing == Passing::Reference {
                operands.push(crate::expressions_complex::lower_cell_argument(
                    *argument, span, state,
                ));
            } else {
                operands.extend(crate::variant_values::values(*argument, state));
            }
        }
    }
    operands
}
