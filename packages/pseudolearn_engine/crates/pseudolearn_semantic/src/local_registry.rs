use crate::hir::{FunctionKind, HirLocal, Passing};
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
    mutable: bool,
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
        check_record_parameter(session, (name, parameter), type_id, by_reference);
        if session.has_token(parameter, TokenKind::LeftBracket) {
            type_id = array_parameter_type(session, parameter, type_id);
        }
        let passing = passing(
            session,
            type_id,
            by_reference && !is_record(session, type_id),
        );
        let local = register(
            session,
            LocalDeclaration {
                name_node: name,
                type_id,
                passing,
                parameter: true,
                mutable: true,
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

fn array_parameter_type(
    session: &mut AnalysisSession<'_>,
    parameter: usize,
    element: TypeId,
) -> TypeId {
    let rank = session
        .count_token(parameter, TokenKind::Comma)
        .saturating_add(1);
    session.module.types.intern(Type::Array { element, rank })
}

fn is_record(session: &AnalysisSession<'_>, type_id: TypeId) -> bool {
    matches!(session.module.types.get(type_id), Type::Record(_))
}

fn check_record_parameter(
    session: &mut AnalysisSession<'_>,
    nodes: (usize, usize),
    type_id: TypeId,
    by_reference: bool,
) {
    if !is_record(session, type_id) {
        return;
    }
    let (name_node, parameter) = nodes;
    let name = session.name(name_node);
    if by_reference {
        session.named_report(DiagnosticCode::RecordPassedByReference, name_node, &name);
    }
    if session.has_token(parameter, TokenKind::LeftBracket) {
        session.report(DiagnosticCode::RecordArrayElementNotSupported, name_node);
    }
    let member = usize::try_from(session.current.0)
        .ok()
        .and_then(|index| session.module.functions.get(index))
        .is_some_and(|function| {
            matches!(
                function.kind,
                FunctionKind::Method | FunctionKind::Constructor
            )
        });
    if member && crate::variant_types::get(session, &session.module.types.get(type_id)).is_none() {
        session.report(DiagnosticCode::RecordMemberSignatureNotSupported, name_node);
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
        match session.kind(node) {
            NodeKind::Declaration | NodeKind::DimensionDeclaration => declaration(session, node),
            NodeKind::ConstantDeclaration => crate::constant_registry::collect_local(session, node),
            _ => {}
        }
    }
}

fn declaration(session: &mut AnalysisSession<'_>, node: usize) {
    let kind_node = session.child(node, NodeKind::Type);
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
        locals.push(register(
            session,
            LocalDeclaration {
                name_node,
                type_id,
                passing: Passing::Value,
                parameter: false,
                mutable: mutable_declaration(session, node),
            },
        ));
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
        mutable: declaration.mutable,
    });
    session.initialized.push(declaration.parameter);
    if session.module.types.get(declaration.type_id) == Type::Error {
        session.invalid.insert(identifier);
    }
    if let Type::Record(record) = session.module.types.get(declaration.type_id) {
        crate::record_locals::components(session, identifier, record);
    }
    identifier
}

fn conflicting_declaration(
    session: &mut AnalysisSession<'_>,
    declaration: &LocalDeclaration,
    name: &str,
) -> Option<LocalId> {
    if let Some(previous) = session.local(name) {
        let code = if declaration.parameter {
            DiagnosticCode::DuplicateParameterName
        } else {
            DiagnosticCode::DuplicateVariableDeclaration
        };
        session.named_report(code, declaration.name_node, name);
        session.invalid.insert(previous);
        return Some(previous);
    }
    if crate::constant_registry::local_constant(session, name).is_some() {
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

fn mutable_declaration(session: &AnalysisSession<'_>, node: usize) -> bool {
    session.has_token(node, TokenKind::Keyword(KeywordKind::MutableKeyword))
        || session.kind(node) == NodeKind::DimensionDeclaration
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
            if is_record(session, base) {
                session.report(DiagnosticCode::RecordArrayElementNotSupported, name);
            }
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
