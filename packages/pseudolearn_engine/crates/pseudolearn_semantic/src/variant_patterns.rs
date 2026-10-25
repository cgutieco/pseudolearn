use crate::expression_model::{HirExpression, HirPlace, Literal};
use crate::identities::{ExpressionId, StatementId};
use crate::session::AnalysisSession;
use crate::statement_model::{HirCase, HirStatement};
use crate::types::Type;
use crate::variant_model::{HirVariant, HirVariantMatch, VariantFamily};
use pseudolearn_diagnostics::{DiagnosticCode, DiagnosticSeverity};
use pseudolearn_lexicon::KeywordKind;
use pseudolearn_syntax::NodeKind;
use std::collections::BTreeSet;

pub(crate) fn check(
    session: &mut AnalysisSession<'_>,
    node: usize,
    value: ExpressionId,
) -> Option<HirStatement> {
    let (variant, mut matching) = prepare(session, node, value)?;
    let mut branches = BranchState::new(session);
    let start = session.diagnostics.len();
    for branch in session.children(node).into_iter().skip(1) {
        check_branch(session, branch, (&variant, &mut matching), &mut branches);
    }
    if !branches.has_default
        && !session
            .diagnostics
            .iter()
            .skip(start)
            .any(|diagnostic| diagnostic.severity == DiagnosticSeverity::Error)
    {
        missing(session, (&variant, &branches.seen), node);
    }
    session.pending_results = branches.pending_after;
    session.initialized = branches.initialized;
    session
        .initialized
        .resize(session.module.locals.len(), false);
    Some(HirStatement::VariantMatch(Box::new(matching)))
}

fn branch_case(
    session: &mut AnalysisSession<'_>,
    syntax: (usize, ExpressionId),
    variant: &HirVariant,
    seen: &mut BTreeSet<usize>,
) -> Option<HirCase> {
    let (branch, value) = syntax;
    let labels = session.child(branch, NodeKind::Labels)?;
    let patterns = session.children(labels);
    if patterns.len() != 1 {
        session.report(DiagnosticCode::IncompatibleSwitchCaseType, labels);
        return None;
    }
    let pattern = *patterns.first()?;
    let Some(alternative) =
        crate::variant_checker::alternative(variant.family, session.token_kind(pattern))
    else {
        session.report(DiagnosticCode::IncompatibleSwitchCaseType, pattern);
        return None;
    };
    if !seen.insert(alternative) {
        session.report(DiagnosticCode::DuplicateSwitchCaseLabel, pattern);
    }
    let statements = branch_statements(session, (branch, pattern), (value, variant), alternative);
    let integer = session.module.types.intern(Type::Integer);
    let label = session.emit(
        HirExpression::Literal(Literal::Integer(i64::try_from(alternative).unwrap_or(0))),
        integer,
        session.span(pattern),
    );
    Some(HirCase {
        labels: vec![label],
        body: statements,
    })
}

fn payload_binding(
    session: &mut AnalysisSession<'_>,
    syntax: (usize, ExpressionId),
    model: (&HirVariant, usize),
) -> Vec<StatementId> {
    let (variant, alternative) = model;
    let Some(kind) = variant.payloads.get(alternative).copied().flatten() else {
        return Vec::new();
    };
    let Some(name) = session.child(syntax.0, NodeKind::Identifier) else {
        return Vec::new();
    };
    let local = crate::variant_bindings::pattern(session, kind, name);
    let value = session.emit(
        HirExpression::VariantPayload {
            value: syntax.1,
            alternative: u32::try_from(alternative).unwrap_or(0),
        },
        kind,
        session.span(syntax.0),
    );
    crate::result_obligations::assign(session, local, value, name);
    vec![session.statement(
        HirStatement::Assign {
            destination: HirPlace::Local(local),
            value,
        },
        session.span(syntax.0),
    )]
}

fn body(session: &mut AnalysisSession<'_>, branch: usize) -> Vec<StatementId> {
    session
        .child(branch, NodeKind::Body)
        .map(|body| crate::statement_checker::body(session, body))
        .unwrap_or_default()
}

fn missing(session: &mut AnalysisSession<'_>, model: (&HirVariant, &BTreeSet<usize>), node: usize) {
    let keywords = match model.0.family {
        VariantFamily::Optional => [KeywordKind::NoneVariant, KeywordKind::SomeVariant],
        VariantFamily::Result => [KeywordKind::SuccessVariant, KeywordKind::ErrorVariant],
    };
    let missing: Vec<_> = keywords
        .iter()
        .enumerate()
        .filter(|(index, _)| !model.1.contains(index))
        .filter_map(|(_, keyword)| keyword.lexeme(session.options.profile))
        .collect();
    if !missing.is_empty() {
        session.named_report(
            DiagnosticCode::NonExhaustiveSwitch,
            node,
            &missing.join(", "),
        );
    }
}

struct BranchState {
    seen: BTreeSet<usize>,
    has_default: bool,
    pending_before: BTreeSet<crate::identities::LocalId>,
    pending_after: BTreeSet<crate::identities::LocalId>,
    initialized: Vec<bool>,
}

impl BranchState {
    fn new(session: &AnalysisSession<'_>) -> Self {
        Self {
            seen: BTreeSet::new(),
            has_default: false,
            pending_before: session.pending_results.clone(),
            pending_after: BTreeSet::new(),
            initialized: session.initialized.clone(),
        }
    }
}

fn check_branch(
    session: &mut AnalysisSession<'_>,
    branch: usize,
    matching: (&HirVariant, &mut HirVariantMatch),
    state: &mut BranchState,
) {
    session.pending_results.clone_from(&state.pending_before);
    session.initialized.clone_from(&state.initialized);
    session
        .initialized
        .resize(session.module.locals.len(), false);
    if state.has_default {
        session.report(DiagnosticCode::UnreachableSwitchPattern, branch);
    }
    if session.kind(branch) == NodeKind::DefaultCase {
        state.has_default = true;
        session.bindings.enter();
        matching.1.default = body(session, branch);
        crate::scope_bindings::leave(session);
    } else if let Some(case) = branch_case(
        session,
        (branch, payload_source(session, matching.1.selector)),
        matching.0,
        &mut state.seen,
    ) {
        matching.1.cases.push(case);
    }
    state
        .pending_after
        .extend(session.pending_results.iter().copied());
}

fn payload_source(session: &AnalysisSession<'_>, selector: ExpressionId) -> ExpressionId {
    match usize::try_from(selector.0)
        .ok()
        .and_then(|index| session.module.expressions.kinds.get(index))
    {
        Some(HirExpression::VariantTag(value)) => *value,
        _ => selector,
    }
}

fn branch_statements(
    session: &mut AnalysisSession<'_>,
    syntax: (usize, usize),
    selection: (ExpressionId, &HirVariant),
    alternative: usize,
) -> Vec<StatementId> {
    session.bindings.enter();
    let start = session.module.locals.len();
    let mut statements =
        payload_binding(session, (syntax.1, selection.0), (selection.1, alternative));
    statements.extend(body(session, syntax.0));
    crate::scope_bindings::visibility(session, start, syntax.0);
    crate::scope_bindings::leave(session);
    statements
}

fn prepare(
    session: &mut AnalysisSession<'_>,
    node: usize,
    value: ExpressionId,
) -> Option<(HirVariant, HirVariantMatch)> {
    let kind = *session
        .module
        .expressions
        .types
        .get(usize::try_from(value.0).ok()?)?;
    let variant = crate::variant_types::get(session, &session.module.types.get(kind))?;
    crate::result_obligations::consume(session, value);
    let storage = crate::variant_bindings::temporary(session, kind, node);
    session.reads.insert(storage);
    let reference = session.emit(HirExpression::Local(storage), kind, session.span(node));
    let integer = session.module.types.intern(Type::Integer);
    let selector = session.emit(
        HirExpression::VariantTag(reference),
        integer,
        session.span(node),
    );
    let matching = HirVariantMatch {
        value,
        storage,
        selector,
        cases: Vec::new(),
        default: Vec::new(),
    };
    Some((variant, matching))
}
