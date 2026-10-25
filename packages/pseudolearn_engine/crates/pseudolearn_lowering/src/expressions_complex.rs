#![forbid(unsafe_code)]

use crate::expressions::{ExpressionState, lower_expression_with_state};
use crate::expressions_builtins::lower_builtin_call;
use pseudolearn_ir::{IrSpan, Operand, Operation, ValueId};
use pseudolearn_semantic::BuiltinKind;
use pseudolearn_semantic::expression_model::HirExpression;
use pseudolearn_semantic::hir::{FunctionKind, HirFunction};
use pseudolearn_semantic::identities::ExpressionId;

pub fn lower_call(
    arguments: &[ExpressionId],
    function_index: u32,
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> ValueId {
    emit_function_call(arguments, function_index, span, state).0
}

pub(crate) fn emit_function_call(
    arguments: &[ExpressionId],
    function_index: u32,
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> (ValueId, Vec<ValueId>) {
    let target_function = usize::try_from(function_index)
        .ok()
        .and_then(|index| state.context.module.functions.get(index));
    let function_name = resolve_target_function_name(target_function);
    let mut lowered_arguments = Vec::new();
    for (parameter_index, &argument_id) in arguments.iter().enumerate() {
        let is_reference = is_reference_parameter(target_function, parameter_index, state);
        lowered_arguments.extend(lower_call_argument(
            argument_id,
            (is_reference, span),
            state,
        ));
    }
    let cells = result_cells(function_index, span, state);
    lowered_arguments.extend(cells.iter().copied());
    let result = state.builder.next_value();
    let operand = Operand::FunctionTarget {
        function_name,
        arguments: lowered_arguments,
    };
    state
        .builder
        .emit_with_target(Operation::Call, vec![operand], (Some(result), span));
    (result, cells)
}

fn is_reference_parameter(
    function: Option<&HirFunction>,
    position: usize,
    state: &ExpressionState<'_, '_>,
) -> bool {
    function
        .and_then(|function| function.parameters.get(position))
        .and_then(|local_id| usize::try_from(local_id.0).ok())
        .and_then(|local_index| state.context.module.locals.get(local_index))
        .is_some_and(|local| crate::parameter_passing::requires_cell(local, state.context.module))
}

fn lower_call_argument(
    argument: ExpressionId,
    passing: (bool, Option<IrSpan>),
    state: &mut ExpressionState<'_, '_>,
) -> Vec<ValueId> {
    let (is_reference, span) = passing;
    if is_reference {
        return vec![lower_cell_argument(argument, span, state)];
    }
    match crate::records::expression_width(argument, state.context.module) {
        Some(width) => crate::record_values::lower_range(argument, (0, width), state),
        None => vec![lower_expression_with_state(argument, state)],
    }
}

pub(crate) fn result_cells(
    function_index: u32,
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> Vec<ValueId> {
    let module = state.context.module;
    let leaves = usize::try_from(function_index)
        .ok()
        .and_then(|slot| module.functions.get(slot))
        .and_then(|function| match module.types.get(function.result) {
            pseudolearn_semantic::types::Type::Record(record) => Some(record),
            _ => None,
        })
        .and_then(|record| usize::try_from(record.0).ok())
        .and_then(|slot| module.records.get(slot))
        .map(|model| model.leaf_types.clone())
        .unwrap_or_default();
    let mut cells = Vec::new();
    for leaf in leaves {
        let cell = state.builder.next_value();
        state.builder.emit_with_target(
            Operation::CellLocal,
            vec![Operand::Type(crate::types::lower_type(leaf, module))],
            (Some(cell), span),
        );
        cells.push(cell);
    }
    cells
}

fn resolve_target_function_name(target_function: Option<&HirFunction>) -> String {
    let Some(function) = target_function else {
        return "unknown".to_owned();
    };
    if function.kind == FunctionKind::Main {
        "@main".to_owned()
    } else if function.name.starts_with('@') {
        function.name.clone()
    } else {
        format!("@{}", function.name)
    }
}

pub(crate) fn lower_cell_argument(
    argument_id: ExpressionId,
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> ValueId {
    let index = usize::try_from(argument_id.0).unwrap_or(0);
    if let Some(HirExpression::Local(local_id)) = state.context.module.expressions.kinds.get(index)
    {
        if let Some(cell) = state.environment.get_cell(*local_id) {
            return cell;
        }
        let local_type = crate::environment::get_local_ir_type(*local_id, state.context.module);
        let cell = state.builder.next_value();
        state.builder.emit_with_target(
            Operation::CellLocal,
            vec![Operand::Type(local_type)],
            (Some(cell), span),
        );
        if let Some(value) = state.environment.get_value(*local_id) {
            state.builder.emit_void(
                Operation::CellStore,
                vec![Operand::Value(cell), Operand::Value(value)],
                span,
            );
        }
        state.environment.bind_cell(*local_id, cell);
        cell
    } else {
        crate::places::lower_cell(argument_id, span, state)
    }
}

pub fn lower_builtin(
    arguments: &[ExpressionId],
    function: BuiltinKind,
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> ValueId {
    let mut lowered = Vec::new();
    for &argument_id in arguments {
        lowered.push(lower_expression_with_state(argument_id, state));
    }
    lower_builtin_call(function, &lowered, span, state.builder)
}

pub fn lower_new(
    class_index: u32,
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> ValueId {
    let class_name = usize::try_from(class_index)
        .ok()
        .and_then(|index| state.context.module.classes.get(index))
        .map(|class_declaration| class_declaration.name.clone())
        .unwrap_or_else(|| "Object".to_owned());
    let result = state.builder.next_value();
    state.builder.emit_with_target(
        Operation::ObjectNew,
        vec![Operand::Identifier(class_name)],
        (Some(result), span),
    );
    result
}

pub fn lower_field(
    receiver: ExpressionId,
    field_index: u32,
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> ValueId {
    let receiver_value = lower_expression_with_state(receiver, state);
    let field_name = usize::try_from(field_index)
        .ok()
        .and_then(|_field_position| {
            state
                .context
                .module
                .classes
                .iter()
                .flat_map(|class_declaration| &class_declaration.fields)
                .find(|field| field.id.0 == field_index)
        })
        .map(|field| field.name.clone())
        .unwrap_or_else(|| "field".to_owned());
    let result = state.builder.next_value();
    state.builder.emit_with_target(
        Operation::ObjectLoad,
        vec![
            Operand::Value(receiver_value),
            Operand::Identifier(field_name),
        ],
        (Some(result), span),
    );
    result
}

pub fn lower_element(
    array: ExpressionId,
    indices: &[ExpressionId],
    span: Option<IrSpan>,
    state: &mut ExpressionState<'_, '_>,
) -> ValueId {
    let array_value = lower_expression_with_state(array, state);
    let mut operands = vec![Operand::Value(array_value)];
    for &index_expression in indices {
        operands.push(Operand::Value(lower_expression_with_state(
            index_expression,
            state,
        )));
    }
    let result = state.builder.next_value();
    state
        .builder
        .emit_with_target(Operation::ArrayLoad, operands, (Some(result), span));
    result
}
