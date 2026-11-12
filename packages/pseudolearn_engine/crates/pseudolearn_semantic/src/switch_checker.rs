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
    if crate::variant_types::get(session, &expected).is_some() {
        return crate::variant_patterns::check(session, node, selector);
    }
    let mut state = SwitchState::new(session);
    for branch in children.into_iter().skip(1) {
        state.branch(session, branch, &expected);
    }
    state.finish(session, (&expected, node));
    Some(HirStatement::Switch {
        selector,
        cases: state.cases,
        default: state.default,
    })
}

struct SwitchState {
    initial: crate::definite_assignment_state::FlowPoint,
    paths: Vec<crate::definite_assignment_state::FlowPath>,
    before: BTreeSet<crate::identities::LocalId>,
    after: BTreeSet<crate::identities::LocalId>,
    cases: Vec<HirCase>,
    default: Vec<crate::identities::StatementId>,
    seen: BTreeSet<String>,
    diagnostic_start: usize,
    has_default: bool,
}

impl SwitchState {
    fn new(session: &AnalysisSession<'_>) -> Self {
        Self {
            initial: crate::definite_assignment_state::capture(session),
            paths: Vec::new(),
            before: session.pending_results.clone(),
            after: BTreeSet::new(),
            cases: Vec::new(),
            default: Vec::new(),
            seen: BTreeSet::new(),
            diagnostic_start: session.diagnostics.len(),
            has_default: false,
        }
    }

    fn branch(&mut self, session: &mut AnalysisSession<'_>, branch: usize, expected: &Type) {
        crate::definite_assignment_state::restore(session, &self.initial);
        session.pending_results.clone_from(&self.before);
        if self.has_default {
            session.report(DiagnosticCode::UnreachableSwitchPattern, branch);
        }
        if default_branch(session, branch, &mut self.default) {
            self.has_default = true;
        } else if let Some(labels) = session.child(branch, NodeKind::Labels) {
            let labels = labels_for(session, labels, expected, &mut self.seen);
            let body = branch_body(session, branch);
            self.cases.push(HirCase { labels, body });
        }
        self.after.extend(session.pending_results.iter().copied());
        self.paths.push(crate::definite_assignment_state::path(
            crate::definite_assignment_state::capture(session),
            crate::definite_assignment_state::AssignmentCause::BranchWithoutAssignment,
            session.span(branch),
        ));
    }

    fn finish(&mut self, session: &mut AnalysisSession<'_>, selector: (&Type, usize)) {
        if session.diagnostics.len() == self.diagnostic_start {
            crate::switch_coverage::check(
                session,
                (selector.0, &self.seen),
                (selector.1, self.has_default),
            );
        }
        if !self.has_default && !matches!(selector.0, Type::Enum(_)) {
            self.after.extend(self.before.iter().copied());
            self.paths.push(crate::definite_assignment_state::path(
                self.initial.clone(),
                crate::definite_assignment_state::AssignmentCause::SwitchWithoutDefault,
                session.span(selector.1),
            ));
        }
        session.pending_results.clone_from(&self.after);
        if self.paths.is_empty() {
            crate::definite_assignment_state::restore(session, &self.initial);
        } else {
            crate::definite_assignment_state::merge(session, &self.paths);
        }
    }
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
        if !matches!(kind, Type::Integer | Type::Enum(_) | Type::Error)
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

fn default_branch(
    session: &mut AnalysisSession<'_>,
    branch: usize,
    default: &mut Vec<crate::identities::StatementId>,
) -> bool {
    if session.kind(branch) != NodeKind::DefaultCase {
        return false;
    }
    if let Some(body) = session.child(branch, NodeKind::Body) {
        *default = crate::statement_checker::scoped_body(session, body);
    }
    true
}

fn branch_body(
    session: &mut AnalysisSession<'_>,
    branch: usize,
) -> Vec<crate::identities::StatementId> {
    session
        .child(branch, NodeKind::Body)
        .map(|body| crate::statement_checker::scoped_body(session, body))
        .unwrap_or_default()
}
