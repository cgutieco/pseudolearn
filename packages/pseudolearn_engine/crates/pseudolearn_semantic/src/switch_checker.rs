use crate::expression_model::HirExpression;
use crate::session::AnalysisSession;
use crate::statement_model::{HirCase, HirStatement};
use crate::types::Type;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_syntax::NodeKind;
use std::collections::BTreeSet;

pub(crate) fn check(session: &mut AnalysisSession<'_>, node: usize) -> Option<HirStatement> {
    let children = session.children(node);
    let selector = crate::expression_checker::check(session, *children.first()?);
    let expected = session.expression_type(selector);
    let before = session.initialized.clone();
    let mut cases = Vec::new();
    let mut default = Vec::new();
    let mut seen = BTreeSet::new();
    for branch in children.into_iter().skip(1) {
        session.initialized.clone_from(&before);
        if session.kind(branch) == NodeKind::DefaultCase {
            if let Some(body) = session.child(branch, NodeKind::Body) {
                default = crate::statement_checker::body(session, body);
            }
            continue;
        }
        let Some(labels) = session.child(branch, NodeKind::Labels) else {
            continue;
        };
        let labels = labels_for(session, labels, &expected, &mut seen);
        let body = session
            .child(branch, NodeKind::Body)
            .map(|body| crate::statement_checker::body(session, body))
            .unwrap_or_default();
        cases.push(HirCase { labels, body });
    }
    session.initialized = before;
    session
        .initialized
        .resize(session.module.locals.len(), false);
    Some(HirStatement::Switch {
        selector,
        cases,
        default,
    })
}

fn labels_for(
    session: &mut AnalysisSession<'_>,
    node: usize,
    expected: &Type,
    seen: &mut BTreeSet<String>,
) -> Vec<crate::identities::ExpressionId> {
    let mut labels = Vec::new();
    for label in session.children(node) {
        let expression = crate::expression_checker::check(session, label);
        let kind = session.expression_type(expression);
        if kind == Type::Real
            || session.options.strict
                && !matches!(kind, Type::Integer | Type::Enum(_) | Type::Error)
            || !crate::type_resolution::assignable(session, expected, &kind)
        {
            session.report(DiagnosticCode::IncompatibleSwitchCaseType, label);
        }
        let literal = usize::try_from(expression.0)
            .ok()
            .and_then(|index| session.module.expressions.kinds.get(index));
        let key = match literal {
            Some(HirExpression::Literal(literal)) => format!("{literal:?}"),
            Some(HirExpression::Unary { .. }) => session.lexeme(label).to_owned(),
            _ => {
                session.report(DiagnosticCode::NonLiteralSwitchCaseLabel, label);
                String::new()
            }
        };
        if !key.is_empty() && !seen.insert(key) {
            session.report(DiagnosticCode::DuplicateSwitchCaseLabel, label);
        }
        labels.push(expression);
    }
    labels
}
