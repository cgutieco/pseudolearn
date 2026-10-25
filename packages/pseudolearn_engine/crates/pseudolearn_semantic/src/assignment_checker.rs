use crate::expression_checker::{ExpressionPurpose, check_for, place};
use crate::expression_model::HirPlace;
use crate::identities::{ExpressionId, LocalId};
use crate::session::AnalysisSession;
use crate::statement_model::HirStatement;
use crate::types::Type;
use pseudolearn_diagnostics::DiagnosticCode;

pub(crate) fn assignment(session: &mut AnalysisSession<'_>, node: usize) -> Option<HirStatement> {
    let children = session.children(node);
    let target = children.first().copied()?;
    let destination = check_for(session, target, ExpressionPurpose::Destination);
    let value_node = children.get(1).copied()?;
    let mut value = crate::expression_checker::check(session, value_node);
    let Some(location) = place(session, destination) else {
        if crate::record_access::is_field(session, destination) {
            session.report(DiagnosticCode::InvalidAssignmentTarget, target);
        }
        return None;
    };
    if let HirPlace::RecordField { local, .. } = location {
        session.writes.insert(local);
    }
    if matches!(location, HirPlace::WholeArray(_)) {
        session.report(DiagnosticCode::ArrayCannotBeUsedAsValue, target);
        return None;
    }
    let expected = session.expression_type(destination);
    let actual = session.expression_type(value);
    if let HirPlace::Local(local) = location {
        assign_local(session, local, value, node);
    }
    if !session.inferred_place(&location)
        && !crate::type_resolution::assignable(session, &expected, &actual)
    {
        session.report(DiagnosticCode::IncompatibleTypesInAssignment, node);
        crate::diagnostic_arguments::assignment_types(session, &expected, &actual);
    }
    value = crate::expression_checker::widen(session, value, &expected);
    Some(HirStatement::Assign {
        destination: location,
        value,
    })
}

pub(crate) fn assign_local(
    session: &mut AnalysisSession<'_>,
    local: LocalId,
    value: ExpressionId,
    node: usize,
) {
    let index = usize::try_from(local.0).unwrap_or(usize::MAX);
    let Some(declaration) = session.module.locals.get(index).cloned() else {
        return;
    };
    infer_assignment(session, local, value, node);
    if session.controls.contains(&local) {
        session.named_report(
            DiagnosticCode::ControlVariableModified,
            node,
            &declaration.name,
        );
    }
    session.writes.insert(local);
    if let Some(initialized) = session.initialized.get_mut(index) {
        *initialized = true;
    }
}

pub(crate) fn input(session: &mut AnalysisSession<'_>, node: usize) -> HirStatement {
    let mut destinations = Vec::new();
    for target in session.children(node) {
        let value = check_for(session, target, ExpressionPurpose::Destination);
        let Some(location) = place(session, value) else {
            session.report(DiagnosticCode::InvalidReadTarget, target);
            continue;
        };
        if matches!(session.expression_type(value), Type::Record(_)) {
            session.report(DiagnosticCode::InvalidReadTarget, target);
            continue;
        }
        if let HirPlace::Local(local) = location {
            session.writes.insert(local);
            if let Some(initialized) = usize::try_from(local.0)
                .ok()
                .and_then(|index| session.initialized.get_mut(index))
            {
                *initialized = true;
            }
        }
        destinations.push(location);
    }
    HirStatement::Read(destinations)
}

fn reject_inferred_record(
    session: &mut AnalysisSession<'_>,
    local: LocalId,
    naming: (usize, &str),
) {
    session.named_report(DiagnosticCode::RecordNotInferable, naming.0, naming.1);
    session.invalid.insert(local);
}

fn inference_code(
    session: &AnalysisSession<'_>,
    expected: &Type,
    actual: &Type,
) -> Option<DiagnosticCode> {
    match (expected, actual) {
        (Type::Unknown, _) => Some(DiagnosticCode::InferredVariableType),
        (Type::Integer, Type::Real) => Some(DiagnosticCode::WidenedVariableType),
        _ if !crate::type_resolution::assignable(session, expected, actual) => {
            Some(DiagnosticCode::TypeConflictOnInferredVariable)
        }
        _ => None,
    }
}

fn infer_assignment(
    session: &mut AnalysisSession<'_>,
    local: LocalId,
    value: ExpressionId,
    node: usize,
) {
    let index = usize::try_from(local.0).unwrap_or(usize::MAX);
    let Some(declaration) = session.module.locals.get(index).cloned() else {
        return;
    };
    let actual = session.expression_type(value);
    let expected = session.module.types.get(declaration.type_id);
    if matches!(actual, Type::Unknown | Type::Error) {
        return;
    }
    if session.inferred.contains(&local) && matches!(actual, Type::Record(_)) {
        reject_inferred_record(session, local, (node, &declaration.name));
        return;
    }
    if session.inferred.contains(&local) {
        let type_id = session.module.types.intern(actual.clone());
        let code = inference_code(session, &expected, &actual);
        if let Some(code) = code {
            session.named_report(code, node, &declaration.name);
            if code == DiagnosticCode::InferredVariableType {
                crate::diagnostic_arguments::inferred_type(session, &actual);
            }
            if code == DiagnosticCode::TypeConflictOnInferredVariable {
                return;
            }
            if let Some(local) = session.module.locals.get_mut(index) {
                local.type_id = type_id;
            }
        }
    }
}
