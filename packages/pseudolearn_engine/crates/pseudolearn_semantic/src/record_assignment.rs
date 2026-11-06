use crate::expression_checker::ExpressionPurpose;
use crate::expression_model::HirPlace;
use crate::identities::{ExpressionId, LocalId, TypeId};
use crate::session::AnalysisSession;
use crate::types::Type;
use pseudolearn_source::Span;

pub(crate) fn read_field(
    session: &mut AnalysisSession<'_>,
    field: ExpressionId,
    purpose: ExpressionPurpose,
) {
    if matches!(
        purpose,
        ExpressionPurpose::Receiver | ExpressionPurpose::Destination
    ) {
        return;
    }
    let Some(HirPlace::RecordField {
        local,
        offset,
        type_id,
    }) = crate::record_access::place(session, field)
    else {
        return;
    };
    let span = usize::try_from(field.0)
        .ok()
        .and_then(|index| session.module.expressions.spans.get(index))
        .copied()
        .unwrap_or_default();
    session.reads.insert(local);
    let unassigned = leaves(session, local, (offset, type_id))
        .into_iter()
        .find(|leaf| !assigned(session, *leaf));
    if let Some(leaf) = unassigned.filter(|_| !session.invalid.contains(&local)) {
        crate::definite_assignment_report::unassigned_read(session, leaf, span);
    }
}

pub(crate) fn write_field(
    session: &mut AnalysisSession<'_>,
    (local, offset, type_id): (LocalId, u32, TypeId),
    span: Span,
) {
    let written = leaves(session, local, (offset, type_id));
    for leaf in &written {
        crate::definite_assignment_state::assign(session, *leaf, span);
        set(session, *leaf);
    }
    let complete = session
        .module
        .record_locals
        .get(&local)
        .is_some_and(|all| all.iter().all(|leaf| assigned(session, *leaf)));
    if complete {
        set(session, local);
    }
}

fn leaves(session: &AnalysisSession<'_>, local: LocalId, (offset, type_id): (u32, TypeId)) -> Vec<LocalId> {
    let width = match session.module.types.representation(type_id) {
        Type::Record(record) => crate::record_locals::leaf_count(session, record),
        _ => 1,
    };
    let start = usize::try_from(offset).unwrap_or(usize::MAX);
    session
        .module
        .record_locals
        .get(&local)
        .map(|all| all.iter().skip(start).take(width).copied().collect())
        .unwrap_or_default()
}

fn assigned(session: &AnalysisSession<'_>, local: LocalId) -> bool {
    usize::try_from(local.0)
        .ok()
        .and_then(|index| session.initialized.get(index))
        .copied()
        .unwrap_or(false)
}

fn set(session: &mut AnalysisSession<'_>, local: LocalId) {
    if let Some(value) = usize::try_from(local.0)
        .ok()
        .and_then(|index| session.initialized.get_mut(index))
    {
        *value = true;
    }
}
