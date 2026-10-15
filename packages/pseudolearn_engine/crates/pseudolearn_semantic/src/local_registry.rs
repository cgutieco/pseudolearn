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
        let mut type_id = parameter_type(session, parameter);
        let by_reference =
            session.has_token(parameter, TokenKind::Keyword(KeywordKind::ByReference));
        if session.has_token(parameter, TokenKind::LeftBracket) {
            let rank = session
                .count_token(parameter, TokenKind::Comma)
                .saturating_add(1);
            type_id = session.module.types.intern(Type::Array {
                element: type_id,
                rank,
            });
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
        if let Some(function) = usize::try_from(session.current.0)
            .ok()
            .and_then(|index| session.module.functions.get_mut(index))
        {
            function.parameters.push(local);
        }
    }
}

fn parameter_type(session: &mut AnalysisSession<'_>, parameter: usize) -> TypeId {
    if let Some(kind) = session.child(parameter, NodeKind::Type) {
        return crate::type_resolution::resolve(session, kind);
    }
    if session.options.strict {
        session.report(DiagnosticCode::ExpectedType, parameter);
    }
    session.module.types.intern(Type::Unknown)
}

pub(crate) fn declarations(session: &mut AnalysisSession<'_>, function: usize) {
    let size = session
        .tree
        .node(function)
        .map_or(1, |node| usize::try_from(node.subtree_size).unwrap_or(1));
    let start = function.saturating_add(1).saturating_sub(size);
    for node in start..function {
        if !matches!(
            session.kind(node),
            NodeKind::Declaration | NodeKind::DimensionDeclaration
        ) {
            continue;
        }
        declaration(session, node);
    }
}

fn declaration(session: &mut AnalysisSession<'_>, node: usize) {
    let kind_node = session.child(node, NodeKind::Type);
    let base = kind_node
        .map(|kind| crate::type_resolution::resolve(session, kind))
        .unwrap_or_else(|| session.module.types.intern(Type::Error));
    let mut locals = Vec::new();
    for child in session.children(node) {
        let (name_node, type_id) = match session.kind(child) {
            NodeKind::Identifier => (child, base),
            NodeKind::Dimensioned => {
                let Some(name) = session.child(child, NodeKind::Identifier) else {
                    continue;
                };
                let rank = u32::try_from(session.tree.child_indices(child).len().saturating_sub(1))
                    .unwrap_or(0);
                (
                    name,
                    session.module.types.intern(Type::Array {
                        element: base,
                        rank,
                    }),
                )
            }
            _ => continue,
        };
        locals.push(register(
            session,
            LocalDeclaration {
                name_node,
                type_id,
                passing: Passing::Value,
                parameter: false,
            },
        ));
    }
    session.declarations.insert(node, locals);
}

fn register(session: &mut AnalysisSession<'_>, declaration: LocalDeclaration) -> LocalId {
    let name = session.name(declaration.name_node);
    if let Some(previous) = session.local(&name) {
        let code = if declaration.parameter {
            DiagnosticCode::DuplicateParameterName
        } else {
            DiagnosticCode::DuplicateVariableDeclaration
        };
        session.named_report(code, declaration.name_node, &name);
        session.invalid.insert(previous);
        return previous;
    }
    if session.functions.contains_key(&name) {
        session.named_report(
            DiagnosticCode::SubroutineAndVariableSameName,
            declaration.name_node,
            &name,
        );
    }
    let identifier = LocalId(u32::try_from(session.module.locals.len()).unwrap_or(u32::MAX));
    if let Some(names) = usize::try_from(session.current.0)
        .ok()
        .and_then(|index| session.local_names.get_mut(index))
    {
        names.insert(name.clone(), identifier);
    }
    session.module.locals.push(HirLocal {
        name,
        type_id: declaration.type_id,
        passing: declaration.passing,
        span: session.span(declaration.name_node),
        scope: session.current,
        parameter: declaration.parameter,
    });
    session.initialized.push(declaration.parameter);
    if session.module.types.get(declaration.type_id) == Type::Error {
        session.invalid.insert(identifier);
    }
    identifier
}

fn passing(session: &AnalysisSession<'_>, type_id: TypeId, explicit_reference: bool) -> Passing {
    if explicit_reference || matches!(session.module.types.get(type_id), Type::Array { .. }) {
        Passing::Reference
    } else {
        Passing::Value
    }
}
