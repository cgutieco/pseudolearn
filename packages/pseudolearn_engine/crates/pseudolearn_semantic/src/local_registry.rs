use crate::hir::{HirLocal, Passing};
use crate::identities::{LocalId, TypeId};
use crate::session::AnalysisSession;
use crate::types::Type;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::KeywordKind;
use pseudolearn_syntax::{NodeKind, TokenKind};

struct LocalDeclaration {
    name_node: usize,
    type_id: TypeId,
    passing: Passing,
    parameter: bool,
}

pub(crate) fn parameters(session: &mut AnalysisSession<'_>, function: usize) {
    let Some(parameters) = session.child(function, NodeKind::Parameters) else {
        return;
    };
    for parameter in session.children(parameters) {
        let Some(name) = session.child(parameter, NodeKind::Identifier) else {
            continue;
        };
        register_parameter(session, parameter, name);
    }
}

fn register_parameter(session: &mut AnalysisSession<'_>, parameter: usize, name: usize) {
    let mut type_id = parameter_type(session, parameter);
    let by_reference = session.has_token(parameter, TokenKind::Keyword(KeywordKind::ByReference));
    if session.has_token(parameter, TokenKind::LeftBracket) {
        type_id = array_parameter_type(session, parameter, type_id);
    }
    let passing = passing(session, type_id, by_reference);
    let local = register(
        session,
        LocalDeclaration {
            name_node: name,
            type_id,
            passing,
            parameter: true,
        },
    );
    if session
        .child(parameter, NodeKind::Type)
        .is_some_and(|kind| crate::function_types::is_pure_syntax(session, kind))
    {
        session.module.pure_locals.insert(local);
    }
    if let Some(function) = usize::try_from(session.current.0)
        .ok()
        .and_then(|index| session.module.functions.get_mut(index))
    {
        function.parameters.push(local);
    }
}

pub(crate) fn array_parameter_type(
    session: &mut AnalysisSession<'_>,
    parameter: usize,
    element: TypeId,
) -> TypeId {
    let rank = session
        .count_token(parameter, TokenKind::Comma)
        .saturating_add(1);
    session.module.types.intern(Type::Array { element, rank })
}

pub(crate) fn parameter_type(session: &mut AnalysisSession<'_>, parameter: usize) -> TypeId {
    if let Some(kind) = session.child(parameter, NodeKind::Type) {
        return crate::type_resolution::resolve(session, kind);
    }
    session.report(DiagnosticCode::ExpectedType, parameter);
    session.module.types.intern(Type::Unknown)
}

pub(crate) fn declaration(session: &mut AnalysisSession<'_>, node: usize) {
    let kind_node = session.child(node, NodeKind::Type);
    let pure_type =
        kind_node.is_some_and(|kind| crate::function_types::is_pure_syntax(session, kind));
    let base = kind_node
        .map(|kind| crate::type_resolution::resolve(session, kind))
        .unwrap_or_else(|| session.module.types.intern(Type::Error));
    let mut locals = Vec::new();
    let names = session
        .children(node)
        .into_iter()
        .take_while(|child| Some(*child) != kind_node);
    for child in names {
        let Some((name_node, type_id)) = declared_name(session, child, base) else {
            continue;
        };
        let local = register(
            session,
            LocalDeclaration {
                name_node,
                type_id,
                passing: Passing::Value,
                parameter: false,
            },
        );
        if pure_type && type_id == base {
            session.module.pure_locals.insert(local);
        }
        locals.push(local);
    }
    session.declarations.insert(node, locals);
}

fn register(session: &mut AnalysisSession<'_>, declaration: LocalDeclaration) -> LocalId {
    let name = session.name(declaration.name_node);
    if let Some(conflict) = conflicting_declaration(session, &declaration, &name) {
        return conflict;
    }
    if session.functions.contains_key(&name) {
        session.named_report(
            DiagnosticCode::SubroutineAndVariableSameName,
            declaration.name_node,
            &name,
        );
    }
    let identifier = LocalId(u32::try_from(session.module.locals.len()).unwrap_or(u32::MAX));
    crate::scope_bindings::declare(
        session,
        name.clone(),
        crate::block_scopes::BindingTarget::Local(identifier),
        declaration.name_node,
    );
    session.module.locals.push(HirLocal {
        name,
        type_id: declaration.type_id,
        passing: declaration.passing,
        span: session.span(declaration.name_node),
        scope: session.current,
        parameter: declaration.parameter,
        reassignable: true,
    });
    session.initialized.push(declaration.parameter);
    crate::definite_assignment_state::declare(session, identifier);
    if session.module.types.representation(declaration.type_id) == Type::Error {
        session.invalid.insert(identifier);
    }
    register_components(
        session,
        identifier,
        (declaration.type_id, declaration.name_node),
    );
    identifier
}

pub(crate) fn register_components(
    session: &mut AnalysisSession<'_>,
    local: LocalId,
    (type_id, name_node): (TypeId, usize),
) {
    match session.module.types.representation(type_id) {
        Type::Record(record) => crate::record_locals::components(session, local, record),
        Type::Array { element, rank } => {
            if let Type::Record(record) = session.module.types.representation(element) {
                if crate::record_locals::leaf_count(session, record)
                    > pseudolearn_abi::RECORD_ARRAY_MAXIMUM_LEAVES
                {
                    session.report(DiagnosticCode::RecordArrayTooWide, name_node);
                    session.invalid.insert(local);
                    return;
                }
                crate::record_locals::array_components(session, local, (record, rank));
            }
        }
        _ => (),
    }
}

fn conflicting_declaration(
    session: &mut AnalysisSession<'_>,
    declaration: &LocalDeclaration,
    name: &str,
) -> Option<LocalId> {
    if let Some(crate::block_scopes::BindingTarget::Local(previous)) =
        session.bindings.current(name)
    {
        if crate::scope_bindings::recovery(
            session,
            crate::block_scopes::BindingTarget::Local(previous),
        ) {
            return None;
        }
        let code = if declaration.parameter {
            DiagnosticCode::DuplicateParameterName
        } else {
            DiagnosticCode::DuplicateVariableDeclaration
        };
        session.named_report(code, declaration.name_node, name);
        session.invalid.insert(previous);
        return Some(previous);
    }
    if matches!(
        session.bindings.current(name),
        Some(crate::block_scopes::BindingTarget::Constant(_))
    ) {
        session.named_report(
            DiagnosticCode::DuplicateVariableDeclaration,
            declaration.name_node,
            name,
        );
        return Some(LocalId(u32::MAX));
    }
    None
}

fn passing(session: &AnalysisSession<'_>, type_id: TypeId, explicit_reference: bool) -> Passing {
    if explicit_reference || matches!(session.module.types.get(type_id), Type::Array { .. }) {
        Passing::Reference
    } else {
        Passing::Value
    }
}

fn declared_name(
    session: &mut AnalysisSession<'_>,
    child: usize,
    base: TypeId,
) -> Option<(usize, TypeId)> {
    match session.kind(child) {
        NodeKind::Identifier => Some((child, base)),
        NodeKind::Dimensioned => {
            let name = session.child(child, NodeKind::Identifier)?;
            let rank = u32::try_from(session.tree.child_indices(child).len().saturating_sub(1))
                .unwrap_or(0);
            Some((
                name,
                session.module.types.intern(Type::Array {
                    element: base,
                    rank,
                }),
            ))
        }
        _ => None,
    }
}
