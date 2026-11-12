use crate::constant_registry::ConstantState;
use crate::expression_checker::{ExpressionPurpose, invalid};
use crate::expression_model::HirExpression;
use crate::identities::ExpressionId;
use crate::session::AnalysisSession;
use pseudolearn_diagnostics::DiagnosticCode;

pub(crate) fn reference(
    session: &mut AnalysisSession<'_>,
    index: usize,
    node: usize,
    purpose: ExpressionPurpose,
) -> ExpressionId {
    let Some(entry) = session.constants.get(index).cloned() else {
        return invalid(session, node);
    };
    session.note_use(
        node,
        crate::service_model::ServiceSymbolTarget::Constant(crate::identities::ConstantId(
            u32::try_from(index).unwrap_or(u32::MAX),
        )),
    );
    if purpose == ExpressionPurpose::Destination {
        session.named_report(DiagnosticCode::ConstantReassigned, node, &entry.name);
        return invalid(session, node);
    }
    match entry.state {
        ConstantState::Value(literal, kind) => {
            let type_id = session.module.types.intern(kind);
            session.emit(HirExpression::Literal(literal), type_id, session.span(node))
        }
        _ => invalid(session, node),
    }
}
