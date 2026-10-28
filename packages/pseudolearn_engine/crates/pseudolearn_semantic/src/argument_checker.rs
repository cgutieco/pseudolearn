use crate::hir::{HirLocal, Passing};
use crate::identities::{ExpressionId, FunctionId, LocalId};
use crate::session::AnalysisSession;
use crate::types::Type;
use pseudolearn_diagnostics::DiagnosticCode;

pub(crate) fn check(
    session: &mut AnalysisSession<'_>,
    function: FunctionId,
    arguments: &mut [ExpressionId],
    node: usize,
) {
    let parameters = crate::hierarchy::function(session, function)
        .map(|function| function.parameters.clone())
        .unwrap_or_default();
    if parameters.len() != arguments.len() {
        arity(session, (parameters.len(), arguments.len()), node);
        return;
    }
    for (parameter, argument) in parameters.iter().zip(arguments) {
        check_argument(session, *parameter, argument, node);
    }
}

fn check_argument(
    session: &mut AnalysisSession<'_>,
    parameter: LocalId,
    argument: &mut ExpressionId,
    node: usize,
) {
    if session.invalid.contains(&parameter) {
        return;
    }
    let Some(local) = usize::try_from(parameter.0)
        .ok()
        .and_then(|index| session.module.locals.get(index))
        .cloned()
    else {
        return;
    };
    let actual = session.expression_type(*argument);
    let expected = session.module.types.get(local.type_id);
    if expected == Type::Unknown && matches!(actual, Type::Record(_)) {
        session.named_report(DiagnosticCode::RecordNotInferable, node, &local.name);
        return;
    }
    if expected == Type::Unknown && actual != Type::Error {
        infer_parameter(session, parameter, actual);
        return;
    }
    if local.passing == Passing::Reference {
        check_reference(session, &local, *argument, node);
        return;
    }
    if !crate::type_resolution::assignable(session, &expected, &actual) {
        session.named_report(DiagnosticCode::IncompatibleArgumentType, node, &local.name);
        return;
    }
    crate::result_obligations::consume(session, *argument);
    *argument = crate::expression_checker::widen(session, *argument, &expected);
}

fn infer_parameter(session: &mut AnalysisSession<'_>, parameter: LocalId, kind: Type) {
    let type_id = session.module.types.intern(kind);
    if let Some(local) = usize::try_from(parameter.0)
        .ok()
        .and_then(|index| session.module.locals.get_mut(index))
    {
        local.type_id = type_id;
    }
    session.signature_changed = true;
}

fn check_reference(
    session: &mut AnalysisSession<'_>,
    local: &HirLocal,
    argument: ExpressionId,
    node: usize,
) {
    if crate::snapshot_types::reject_write(session, argument, node) {
        return;
    }
    if crate::expression_checker::place(session, argument).is_none() {
        session.report(DiagnosticCode::ByReferenceArgumentRequiresDesignator, node);
        return;
    }
    if let Some(place) = crate::expression_checker::place(session, argument) {
        crate::binding_checker::check_destination(session, &place, node);
        if let crate::expression_model::HirPlace::Local(identifier) = place {
            session.writes.insert(identifier);
        }
    }
    let actual = session.expression_type(argument);
    if session.module.types.get(local.type_id) != actual && actual != Type::Error {
        session.report(DiagnosticCode::ByReferenceArgumentTypeMismatch, node);
    }
}

pub(crate) fn arity(session: &mut AnalysisSession<'_>, counts: (usize, usize), node: usize) {
    session.report(DiagnosticCode::ArgumentCountMismatch, node);
    if let Some(diagnostic) = session.diagnostics.last_mut() {
        diagnostic.arguments.insert(
            "expected".to_owned(),
            pseudolearn_diagnostics::DiagnosticArgument::Number(
                u64::try_from(counts.0).unwrap_or(u64::MAX).into(),
            ),
        );
        diagnostic.arguments.insert(
            "found".to_owned(),
            pseudolearn_diagnostics::DiagnosticArgument::Number(
                u64::try_from(counts.1).unwrap_or(u64::MAX).into(),
            ),
        );
    }
}
