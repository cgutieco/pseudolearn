use crate::expression_model::{HirExpression, HirPlace};
use crate::identities::{ExpressionId, LocalId};
use crate::session::AnalysisSession;
use crate::statement_model::HirStatement;
use std::collections::BTreeSet;

pub(crate) fn collect(
    session: &AnalysisSession<'_>,
    root: ExpressionId,
    calls: &mut BTreeSet<usize>,
) -> bool {
    let mut pending = vec![root];
    let mut effects = false;
    let mut visited = BTreeSet::new();
    while let Some(identifier) = pending.pop() {
        if !visited.insert(identifier) {
            continue;
        }
        let Some(expression) = usize::try_from(identifier.0)
            .ok()
            .and_then(|index| session.module.expressions.kinds.get(index))
        else {
            continue;
        };
        if let HirExpression::Effect { operation, .. } = expression {
            effects |= pseudolearn_abi::EFFECT_OPERATIONS
                .iter()
                .any(|candidate| candidate.id == *operation && candidate.effect);
        }
        effects |= matches!(expression, HirExpression::Channel(call) if call.action != crate::channel_model::ChannelAction::New);
        pending.extend(crate::effect_operands::expression(expression));
        collect_target(session, expression, calls, &mut pending);
    }
    effects
}

fn collect_constructor(session: &AnalysisSession<'_>, class: u32, calls: &mut BTreeSet<usize>) {
    if let Some(constructor) = usize::try_from(class)
        .ok()
        .and_then(|index| session.module.classes.get(index))
        .and_then(|class| class.constructor)
    {
        calls.insert(crate::effect_check::unwrap_function_value(
            session,
            constructor,
        ));
    }
}

fn collect_capture(
    session: &AnalysisSession<'_>,
    (function, capture): (&crate::FunctionId, u32),
    pending: &mut Vec<ExpressionId>,
) {
    let source = session.module.closures.get(function).and_then(|closure| {
        usize::try_from(capture)
            .ok()
            .and_then(|index| closure.captures.get(index))
    });
    if let Some((source, _)) = source {
        collect_local(session, *source, pending);
    }
}

fn collect_target(
    session: &AnalysisSession<'_>,
    expression: &HirExpression,
    calls: &mut BTreeSet<usize>,
    pending: &mut Vec<ExpressionId>,
) {
    match expression {
        HirExpression::Call { function, .. }
        | HirExpression::FunctionValue(function)
        | HirExpression::SuperCall {
            function: Some(function),
            ..
        } => {
            calls.insert(crate::effect_check::unwrap_function_value(
                session, *function,
            ));
        }
        HirExpression::VirtualCall { function, .. } => collect_virtual(session, *function, calls),
        HirExpression::New { class, .. } => collect_constructor(session, class.0, calls),
        HirExpression::Local(local) => collect_local(session, *local, pending),
        HirExpression::Captured { function, capture } => {
            collect_capture(session, (function, *capture), pending);
        }
        _ => {}
    }
}

fn collect_local(session: &AnalysisSession<'_>, local: LocalId, pending: &mut Vec<ExpressionId>) {
    for statement in &session.module.statements.kinds {
        if let HirStatement::Assign {
            destination: HirPlace::Local(target),
            value,
        } = statement
            && *target == local
        {
            pending.push(*value);
        }
    }
}

fn collect_virtual(
    session: &AnalysisSession<'_>,
    function: crate::identities::FunctionId,
    calls: &mut BTreeSet<usize>,
) {
    calls.insert(crate::effect_check::unwrap_function_value(
        session, function,
    ));
    let Some(declaration) = crate::hierarchy::function(session, function) else {
        return;
    };
    for class in &session.module.classes {
        for candidate in &class.virtual_slots {
            if crate::hierarchy::function(session, *candidate)
                .is_some_and(|method| method.name == declaration.name)
            {
                calls.insert(crate::effect_check::unwrap_function_value(
                    session, *candidate,
                ));
            }
        }
    }
}
