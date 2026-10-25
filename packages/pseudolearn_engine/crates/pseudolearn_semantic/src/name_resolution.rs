use crate::expression_checker::ExpressionPurpose;
use crate::expression_model::HirExpression;
use crate::hir::{HirLocal, Passing};
use crate::identities::{ExpressionId, LocalId};
use crate::session::AnalysisSession;
use crate::types::Type;
use pseudolearn_diagnostics::DiagnosticCode;

pub(crate) fn local(
    session: &mut AnalysisSession<'_>,
    node: usize,
    purpose: ExpressionPurpose,
) -> ExpressionId {
    let name = session.name(node);
    if session.local(&name).is_none()
        && let Some(index) =
            crate::constant_registry::find_in(session, Some(session.current), &name)
    {
        return crate::constant_use::reference(session, index, node, purpose);
    }
    let local = session
        .local(&name)
        .unwrap_or_else(|| implicit(session, node, &name, purpose));
    let index = usize::try_from(local.0).unwrap_or(usize::MAX);
    let Some(declaration) = session.module.locals.get(index).cloned() else {
        return crate::expression_checker::invalid(session, node);
    };
    if !session.invalid.contains(&local) && session.span(node).start < declaration.span.start {
        session.named_report(DiagnosticCode::VariableUsedBeforeDeclaration, node, &name);
        session.invalid.insert(local);
    }
    if purpose != ExpressionPurpose::Destination {
        check_read(session, local, node, purpose);
    }
    session.emit(
        HirExpression::Local(local),
        declaration.type_id,
        session.span(node),
    )
}

fn check_read(
    session: &mut AnalysisSession<'_>,
    local: LocalId,
    node: usize,
    purpose: ExpressionPurpose,
) {
    session.reads.insert(local);
    let index = usize::try_from(local.0).unwrap_or(usize::MAX);
    let Some(declaration) = session.module.locals.get(index) else {
        return;
    };
    let name = declaration.name.clone();
    let kind = session.module.types.get(declaration.type_id);
    if matches!(kind, Type::Array { .. }) && purpose == ExpressionPurpose::Value {
        session.named_report(DiagnosticCode::ArrayCannotBeUsedAsValue, node, &name);
        return;
    }
    if !session.initialized.get(index).copied().unwrap_or(false)
        && !session.invalid.contains(&local)
    {
        session.named_report(DiagnosticCode::VariableUsedUninitialized, node, &name);
    }
}

fn implicit(
    session: &mut AnalysisSession<'_>,
    node: usize,
    name: &str,
    purpose: ExpressionPurpose,
) -> LocalId {
    if let Some(owner) = session.owner()
        && crate::hierarchy::find_field(session, owner, name).is_some()
    {
        session.named_report(
            DiagnosticCode::IdentifierMatchesFieldWithoutThis,
            node,
            name,
        );
    }
    let kind = session.module.types.intern(Type::Error);
    let identifier = LocalId(u32::try_from(session.module.locals.len()).unwrap_or(u32::MAX));
    session.module.locals.push(HirLocal {
        name: name.to_owned(),
        type_id: kind,
        passing: Passing::Value,
        span: session.span(node),
        scope: session.current,
        parameter: false,
        mutable: false,
    });
    session.initialized.push(false);
    session.bindings.insert(
        name.to_owned(),
        crate::block_scopes::BindingTarget::Local(identifier),
    );
    if !crate::scope_bindings::outside(session, node, name) {
        session.named_report(DiagnosticCode::UndeclaredVariable, node, name);
    }
    classify_implicit(session, identifier, purpose);
    identifier
}

fn classify_implicit(
    session: &mut AnalysisSession<'_>,
    identifier: LocalId,
    _purpose: ExpressionPurpose,
) {
    session.invalid.insert(identifier);
}
