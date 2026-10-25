use crate::expression_model::HirPlace;
use crate::identities::LocalId;
use crate::session::AnalysisSession;
use crate::statement_model::HirStatement;
use pseudolearn_diagnostics::DiagnosticCode;

pub(crate) fn initialize(session: &mut AnalysisSession<'_>, node: usize) -> Option<HirStatement> {
    let local = session.declarations.get(&node)?.first().copied()?;
    let declaration = session
        .module
        .locals
        .get(usize::try_from(local.0).ok()?)?
        .clone();
    let value_node = session.children(node).last().copied()?;
    let before = session.diagnostics.len();
    let value = crate::expression_checker::check_expected(session, value_node, declaration.type_id);
    crate::result_obligations::assign(session, local, value, node);
    replace_self_read(session, before, &declaration.name);
    let expected = session.module.types.get(declaration.type_id);
    if !crate::type_resolution::assignable(session, &expected, &session.expression_type(value)) {
        session.report(DiagnosticCode::IncompatibleTypesInAssignment, node);
        crate::diagnostic_arguments::assignment_types(
            session,
            &expected,
            &session.expression_type(value),
        );
    }
    let value = crate::expression_checker::widen(session, value, &expected);
    mark_initialized(session, local);
    Some(HirStatement::Assign {
        destination: HirPlace::Local(local),
        value,
    })
}

pub(crate) fn mark_initialized(session: &mut AnalysisSession<'_>, local: LocalId) {
    let targets = session
        .module
        .record_locals
        .get(&local)
        .cloned()
        .unwrap_or_default();
    for target in std::iter::once(local).chain(targets) {
        if let Some(assigned) = usize::try_from(target.0)
            .ok()
            .and_then(|index| session.initialized.get_mut(index))
        {
            *assigned = true;
        }
    }
}

pub(crate) fn check_destination(session: &mut AnalysisSession<'_>, place: &HirPlace, node: usize) {
    let local = match place {
        HirPlace::Local(local) | HirPlace::RecordField { local, .. } => *local,
        _ => return,
    };
    if session.controls.contains(&local) {
        let name = usize::try_from(local.0)
            .ok()
            .and_then(|index| session.module.locals.get(index))
            .map(|local| local.name.clone())
            .unwrap_or_default();
        session.named_report(DiagnosticCode::ControlVariableModified, node, &name);
        return;
    }
    if session.invalid.contains(&local) {
        return;
    }
    if usize::try_from(local.0)
        .ok()
        .and_then(|index| session.module.locals.get(index))
        .is_some_and(|local| !local.mutable)
    {
        session.report(DiagnosticCode::ImmutableBindingAssignment, node);
    }
}

fn replace_self_read(session: &mut AnalysisSession<'_>, start: usize, name: &str) {
    for diagnostic in session.diagnostics.iter_mut().skip(start) {
        if diagnostic.code == DiagnosticCode::VariableUsedUninitialized
            && diagnostic.arguments.get("lexeme").is_some_and(|argument| {
                *argument == pseudolearn_diagnostics::DiagnosticArgument::Lexeme(name.to_owned())
            })
        {
            *diagnostic = pseudolearn_diagnostics::Diagnostic::new(
                DiagnosticCode::BindingReadsOwnInitializer,
                diagnostic.span,
            );
        }
    }
}
