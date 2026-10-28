use crate::channel_model::{ChannelAction, ChannelExpression};
use crate::expression_model::{HirExpression, HirPlace, Literal};
use crate::identities::TypeId;
use crate::session::AnalysisSession;
use crate::statement_model::{HirCase, HirStatement};
use crate::types::Type;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_syntax::NodeKind;

pub(crate) fn check(session: &mut AnalysisSession<'_>, node: usize) -> Option<HirStatement> {
    crate::channel_checker::suspension_context(session, node);
    let branches = session.children(node);
    if branches.len() < 2 {
        session.report(DiagnosticCode::SelectNeedsTwoBranches, node);
    }
    let integer = session.module.types.intern(Type::Integer);
    let storage = crate::task_bindings::declare(session, node, integer, "$selection".to_owned());
    let selector = session.emit(HirExpression::Local(storage), integer, session.span(node));
    let mut channels = Vec::new();
    let mut cases = Vec::new();
    for (index, branch) in branches.into_iter().enumerate() {
        let children = session.children(branch);
        let channel_node = *children.get(1)?;
        let channel = crate::expression_checker::check(session, channel_node);
        let Some(element) =
            crate::channel_types::element(session, &session.expression_type(channel))
        else {
            session.report(DiagnosticCode::AwaitOperandInvalid, channel_node);
            continue;
        };
        channels.push(channel);
        let body = branch_body(session, branch, element)?;
        let label = label(session, (index, integer), branch);
        cases.push(HirCase {
            labels: vec![label],
            body,
        });
    }
    Some(HirStatement::Select(Box::new(
        crate::channel_model::HirSelect {
            channels,
            storage,
            selector,
            cases,
        },
    )))
}

fn branch_body(
    session: &mut AnalysisSession<'_>,
    branch: usize,
    element: TypeId,
) -> Option<Vec<crate::StatementId>> {
    let name_node = *session.children(branch).first()?;
    let body_node = session.child(branch, NodeKind::Body)?;
    let kind = crate::channel_checker::optional(session, element, branch);
    session.bindings.enter();
    let local = crate::task_bindings::declare(session, name_node, kind, session.name(name_node));
    let value = session.emit(
        HirExpression::Channel(ChannelExpression {
            action: ChannelAction::Selected,
            element,
            receiver: None,
            arguments: Vec::new(),
        }),
        kind,
        session.span(branch),
    );
    let assignment = session.statement(
        HirStatement::Assign {
            destination: HirPlace::Local(local),
            value,
        },
        session.span(branch),
    );
    let mut statements = vec![assignment];
    statements.extend(crate::statement_checker::body(session, body_node));
    crate::scope_bindings::leave(session);
    Some(statements)
}

fn label(
    session: &mut AnalysisSession<'_>,
    (index, integer): (usize, TypeId),
    branch: usize,
) -> crate::ExpressionId {
    session.emit(
        HirExpression::Literal(Literal::Integer(i64::try_from(index).unwrap_or(0))),
        integer,
        session.span(branch),
    )
}
