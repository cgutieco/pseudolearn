use crate::expression_model::HirExpression;
use crate::hir::{FunctionKind, HirFunction, HirModule};
use crate::identities::FunctionId;
use crate::session::AnalysisSession;
use crate::statement_model::HirStatement;
use pseudolearn_diagnostics::DiagnosticCode;

pub fn first_parent_constructor(function: &HirFunction, module: &HirModule) -> Option<FunctionId> {
    let statement = function
        .body
        .first()
        .and_then(|identity| usize::try_from(identity.0).ok())
        .and_then(|index| module.statements.kinds.get(index));
    let Some(HirStatement::Call(expression)) = statement else {
        return None;
    };
    let expression = usize::try_from(expression.0)
        .ok()
        .and_then(|index| module.expressions.kinds.get(index));
    let Some(HirExpression::SuperCall {
        function: Some(target),
        ..
    }) = expression
    else {
        return None;
    };
    usize::try_from(target.0)
        .ok()
        .and_then(|index| module.functions.get(index))
        .filter(|function| function.kind == FunctionKind::Constructor)
        .map(|_| *target)
}

pub(crate) fn check(session: &mut AnalysisSession<'_>) {
    for index in 0..session.module.classes.len() {
        session.enter_class(index);
        let Some(class) = session.module.classes.get(index) else {
            continue;
        };
        let parent = class
            .superclass
            .and_then(|parent| usize::try_from(parent.0).ok())
            .and_then(|index| session.module.classes.get(index));
        let target = parent.and_then(|parent| parent.constructor);
        let required = target
            .and_then(|target| usize::try_from(target.0).ok())
            .and_then(|index| session.module.functions.get(index));
        if required.is_none_or(|function| function.parameters.is_empty()) {
            continue;
        }
        let constructor = class
            .constructor
            .and_then(|identity| usize::try_from(identity.0).ok())
            .and_then(|index| session.module.functions.get(index));
        if constructor
            .is_some_and(|function| first_parent_constructor(function, &session.module) == target)
        {
            continue;
        }
        let syntax = constructor.map_or(class.syntax, |function| function.syntax);
        session.report(DiagnosticCode::MissingSuperConstructorCall, syntax);
    }
}
