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
    if crate::snapshot_types::reject_write(session, destination, target) {
        return None;
    }
    let value_node = children.get(1).copied()?;
    let mut value = assignment_value(session, destination, value_node)?;
    let Some(location) = place(session, destination) else {
        if crate::record_access::is_field(session, destination) {
            session.report(DiagnosticCode::InvalidAssignmentTarget, target);
        }
        return None;
    };
    crate::binding_checker::check_destination(session, &location, target);
    if let HirPlace::RecordField {
        local,
        offset,
        type_id,
    } = location
    {
        session.writes.insert(local);
        let span = session.span(node);
        crate::record_assignment::write_field(session, (local, offset, type_id), span);
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
    if !crate::type_resolution::assignable(session, &expected, &actual) {
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
    if session.module.locals.get(index).is_none() {
        return;
    }
    crate::result_obligations::assign(session, local, value, node);
    session.writes.insert(local);
    let span = session.span(node);
    crate::definite_assignment_state::assign(session, local, span);
    crate::binding_checker::mark_initialized(session, local);
}

pub(crate) fn input(session: &mut AnalysisSession<'_>, node: usize) -> HirStatement {
    let mut destinations = Vec::new();
    for target in session.children(node) {
        let value = check_for(session, target, ExpressionPurpose::Destination);
        if crate::snapshot_types::reject_write(session, value, target) {
            continue;
        }
        let Some(location) = place(session, value) else {
            session.report(DiagnosticCode::InvalidReadTarget, target);
            continue;
        };
        if matches!(session.expression_type(value), Type::Record(_)) {
            session.report(DiagnosticCode::InvalidReadTarget, target);
            continue;
        }
        crate::binding_checker::check_destination(session, &location, target);
        if let HirPlace::RecordField {
            local,
            offset,
            type_id,
        } = location
        {
            session.writes.insert(local);
            let span = session.span(target);
            crate::record_assignment::write_field(session, (local, offset, type_id), span);
        }
        if let HirPlace::Local(local) = location {
            session.writes.insert(local);
            let span = session.span(target);
            crate::definite_assignment_state::assign(session, local, span);
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

fn assignment_value(
    session: &mut AnalysisSession<'_>,
    destination: ExpressionId,
    node: usize,
) -> Option<ExpressionId> {
    let index = usize::try_from(destination.0).ok()?;
    let kind = *session.module.expressions.types.get(index)?;
    Some(crate::expression_checker::check_expected(
        session, node, kind,
    ))
}
