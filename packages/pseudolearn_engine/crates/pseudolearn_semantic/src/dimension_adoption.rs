use crate::block_scopes::BindingTarget;
use crate::hir::Passing;
use crate::identities::LocalId;
use crate::session::AnalysisSession;
use crate::statement_model::HirStatement;
use crate::types::Type;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_syntax::NodeKind;

pub(crate) const MISSING: LocalId = LocalId(u32::MAX);

pub(crate) fn adopt(session: &mut AnalysisSession<'_>, node: usize) {
    let mut locals = Vec::new();
    for dimensioned in session.children(node) {
        if session.kind(dimensioned) != NodeKind::Dimensioned {
            continue;
        }
        let Some(name_node) = session.child(dimensioned, NodeKind::Identifier) else {
            locals.push(MISSING);
            continue;
        };
        let rank = u32::try_from(session.children(dimensioned).len().saturating_sub(1)).unwrap_or(0);
        match candidate(session, name_node) {
            Some(local) => {
                retype(session, local, (rank, name_node));
                locals.push(local);
            }
            None => {
                reject(session, name_node);
                locals.push(MISSING);
            }
        }
    }
    session.declarations.insert(node, locals);
}

fn candidate(session: &AnalysisSession<'_>, name_node: usize) -> Option<LocalId> {
    let name = session.name(name_node);
    let Some(BindingTarget::Local(local)) = session.bindings.current(&name) else {
        return None;
    };
    let index = usize::try_from(local.0).ok()?;
    let declaration = session.module.locals.get(index)?;
    let untouched = !session.initialized.get(index).copied().unwrap_or(true)
        && !session.assignment.possibly.contains(&local)
        && !session.reads.contains(&local)
        && !session.writes.contains(&local)
        && !session.invalid.contains(&local);
    let declared = !declaration.parameter
        && declaration.reassignable
        && declaration.scope == session.current
        && !matches!(
            session.module.types.get(declaration.type_id),
            Type::Array { .. }
        );
    (untouched && declared).then_some(local)
}

fn retype(session: &mut AnalysisSession<'_>, local: LocalId, (rank, name_node): (u32, usize)) {
    let Some(element) = usize::try_from(local.0)
        .ok()
        .and_then(|index| session.module.locals.get(index))
        .map(|declaration| declaration.type_id)
    else {
        return;
    };
    let array = session.module.types.intern(Type::Array { element, rank });
    if let Some(declaration) = usize::try_from(local.0)
        .ok()
        .and_then(|index| session.module.locals.get_mut(index))
    {
        declaration.type_id = array;
        declaration.passing = Passing::Reference;
    }
    if let Some(leaves) = session.module.record_locals.remove(&local) {
        session.invalid.extend(leaves);
    }
    crate::local_registry::register_components(session, local, (array, name_node));
    for kind in &mut session.module.statements.kinds {
        if let HirStatement::Declare(declared) = kind {
            declared.retain(|candidate| *candidate != local);
        }
    }
}

fn reject(session: &mut AnalysisSession<'_>, name_node: usize) {
    let name = session.name(name_node);
    session.named_report(DiagnosticCode::DimensionWithoutType, name_node, &name);
    let related = session
        .local(&name)
        .and_then(|local| usize::try_from(local.0).ok())
        .and_then(|index| session.module.locals.get(index))
        .map(|declaration| declaration.span);
    if let (Some(span), Some(diagnostic)) = (related, session.diagnostics.last_mut()) {
        diagnostic.related.push(span);
    }
}
