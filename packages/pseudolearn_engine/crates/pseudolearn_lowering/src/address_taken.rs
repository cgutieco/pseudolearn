use pseudolearn_semantic::{expression_model::HirExpression, hir::HirModule, identities::LocalId};

pub(crate) fn contains(local: LocalId, module: &HirModule) -> bool {
    module.expressions.kinds.iter().any(|expression| {
        let (function, arguments) = match expression {
            HirExpression::Call {
                function,
                arguments,
            }
            | HirExpression::VirtualCall {
                function,
                arguments,
                ..
            } => (*function, arguments),
            HirExpression::SuperCall {
                function: Some(function),
                arguments,
                ..
            } => (*function, arguments),
            HirExpression::New { class, arguments } => match constructor(class.0, module) {
                Some(function) => (function, arguments),
                None => return false,
            },
            _ => return false,
        };
        let Some(function) = usize::try_from(function.0)
            .ok()
            .and_then(|index| module.functions.get(index))
        else {
            return false;
        };
        function
            .parameters
            .iter()
            .zip(arguments)
            .any(|(parameter, argument)| references_local(module, local, (*parameter, *argument)))
    })
}

fn references_local(
    module: &HirModule,
    local: LocalId,
    (parameter, argument): (LocalId, pseudolearn_semantic::identities::ExpressionId),
) -> bool {
    let by_reference = usize::try_from(parameter.0)
        .ok()
        .and_then(|index| module.locals.get(index))
        .is_some_and(|local| crate::parameter_passing::requires_cell(local, module));
    by_reference && addressed_locals(module, argument).contains(&local)
}

fn addressed_locals(
    module: &HirModule,
    argument: pseudolearn_semantic::identities::ExpressionId,
) -> Vec<LocalId> {
    let mut total = 0_u32;
    let mut current = argument;
    loop {
        let Some(kind) = usize::try_from(current.0)
            .ok()
            .and_then(|index| module.expressions.kinds.get(index))
        else {
            return Vec::new();
        };
        match kind {
            HirExpression::RecordField { record, offset } => {
                total = total.saturating_add(*offset);
                current = *record;
            }
            HirExpression::Local(local) => {
                let type_id = usize::try_from(argument.0)
                    .ok()
                    .and_then(|index| module.expressions.types.get(index))
                    .copied();
                return match type_id {
                    Some(type_id) => {
                        crate::records::slice_targets(*local, (total, type_id), module)
                    }
                    None => vec![*local],
                };
            }
            _ => return Vec::new(),
        }
    }
}

fn constructor(
    class: u32,
    module: &HirModule,
) -> Option<pseudolearn_semantic::identities::FunctionId> {
    crate::constructor_flow::find(class, module).map(pseudolearn_semantic::identities::FunctionId)
}
