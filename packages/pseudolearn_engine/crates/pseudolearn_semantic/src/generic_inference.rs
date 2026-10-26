use crate::generic_state::GenericTemplate;
use crate::identities::TypeId;
use crate::session::AnalysisSession;
use crate::types::Type;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::KeywordKind;
use pseudolearn_syntax::{NodeKind, TokenKind};

struct Binder<'template> {
    names: &'template [String],
    bound: Vec<Option<TypeId>>,
}

pub(crate) fn infer(
    session: &mut AnalysisSession<'_>,
    template: &GenericTemplate,
    (actual, node): (&[TypeId], usize),
) -> Option<Vec<TypeId>> {
    let parameters = parameter_nodes(session, template.node);
    if parameters.len() != actual.len() {
        crate::argument_checker::arity(session, (parameters.len(), actual.len()), node);
        return None;
    }
    let mut binder = Binder {
        names: &template.parameters,
        bound: vec![None; template.parameters.len()],
    };
    for (parameter, kind) in parameters.into_iter().zip(actual) {
        if let Err(conflict) = bind_parameter(session, parameter, *kind, &mut binder) {
            report(session, node, binder.names.get(conflict));
            return None;
        }
    }
    let unbound = binder.bound.iter().position(Option::is_none);
    if let Some(index) = unbound {
        report(session, node, binder.names.get(index));
        return None;
    }
    Some(binder.bound.into_iter().flatten().collect())
}

fn report(session: &mut AnalysisSession<'_>, node: usize, name: Option<&String>) {
    let spelling = name.cloned().unwrap_or_default();
    session.named_report(DiagnosticCode::CannotInferTypeArgument, node, &spelling);
}

fn parameter_nodes(session: &AnalysisSession<'_>, template: usize) -> Vec<usize> {
    session
        .child(template, NodeKind::Parameters)
        .map(|parameters| session.children(parameters))
        .unwrap_or_default()
}

fn bind_parameter(
    session: &AnalysisSession<'_>,
    parameter: usize,
    actual: TypeId,
    binder: &mut Binder<'_>,
) -> Result<(), usize> {
    let Some(node) = session.child(parameter, NodeKind::Type) else {
        return Ok(());
    };
    if !session.has_token(parameter, TokenKind::LeftBracket) {
        return bind(session, node, actual, binder);
    }
    match session.module.types.get(actual) {
        Type::Array { element, .. } => bind(session, node, element, binder),
        _ => Ok(()),
    }
}

fn bind(
    session: &AnalysisSession<'_>,
    node: usize,
    actual: TypeId,
    binder: &mut Binder<'_>,
) -> Result<(), usize> {
    if session.token_kind(node) == Some(TokenKind::Keyword(KeywordKind::Subroutine)) {
        return bind_function(session, node, actual, binder);
    }
    let name = session.name(node);
    if let Some(arguments) = session.child(node, NodeKind::TypeArguments) {
        return bind_record(session, (arguments, &name), actual, binder);
    }
    match binder.names.iter().position(|candidate| *candidate == name) {
        Some(index) => assign(binder, index, actual),
        None => Ok(()),
    }
}

fn assign(binder: &mut Binder<'_>, index: usize, actual: TypeId) -> Result<(), usize> {
    match binder.bound.get(index).copied().flatten() {
        Some(existing) if existing != actual => Err(index),
        Some(_) => Ok(()),
        None => {
            if let Some(slot) = binder.bound.get_mut(index) {
                *slot = Some(actual);
            }
            Ok(())
        }
    }
}

fn bind_record(
    session: &AnalysisSession<'_>,
    (arguments, name): (usize, &str),
    actual: TypeId,
    binder: &mut Binder<'_>,
) -> Result<(), usize> {
    if let Some(model) = crate::collection_types::get(session, &session.module.types.get(actual)) {
        let identity = crate::collection_types::identity(session, name);
        if (model.key.is_some() && identity == Some("dictionaryType"))
            || (model.key.is_none() && identity == Some("vectorType"))
        {
            let kinds = model.key.into_iter().chain(std::iter::once(model.value));
            for (child, kind) in session.children(arguments).into_iter().zip(kinds) {
                bind(session, child, kind, binder)?;
            }
        }
        return Ok(());
    }
    let Type::Record(record) = session.module.types.get(actual) else {
        return Ok(());
    };
    let Some((_, node, kinds)) = session.generic.origins.get(&record) else {
        return Ok(());
    };
    let expected = session
        .generics
        .records
        .get(name)
        .map(|template| template.node);
    if expected != Some(*node) {
        return Ok(());
    }
    for (child, kind) in session.children(arguments).into_iter().zip(kinds) {
        bind(session, child, *kind, binder)?;
    }
    Ok(())
}

fn bind_function(
    session: &AnalysisSession<'_>,
    node: usize,
    actual: TypeId,
    binder: &mut Binder<'_>,
) -> Result<(), usize> {
    let Some(signature) = crate::function_types::get(session, &session.module.types.get(actual))
    else {
        return Ok(());
    };
    let mut parameters = signature.parameters.iter();
    for child in session.children(node) {
        if session.kind(child) == NodeKind::FunctionParameterType {
            let (Some(inner), Some((kind, _))) =
                (session.child(child, NodeKind::Type), parameters.next())
            else {
                continue;
            };
            bind(session, inner, *kind, binder)?;
        } else if session.kind(child) == NodeKind::Type {
            bind(session, child, signature.result, binder)?;
        }
    }
    Ok(())
}

pub(crate) fn infer_record(
    session: &mut AnalysisSession<'_>,
    template: &GenericTemplate,
    (actual, node): (&[TypeId], usize),
) -> Option<Vec<TypeId>> {
    let fields = field_type_nodes(session, template.node);
    if fields.len() != actual.len() {
        crate::argument_checker::arity(session, (fields.len(), actual.len()), node);
        return None;
    }
    let mut binder = Binder {
        names: &template.parameters,
        bound: vec![None; template.parameters.len()],
    };
    for (field, kind) in fields.into_iter().zip(actual) {
        if let Err(conflict) = bind(session, field, *kind, &mut binder) {
            report(session, node, binder.names.get(conflict));
            return None;
        }
    }
    if let Some(index) = binder.bound.iter().position(Option::is_none) {
        report(session, node, binder.names.get(index));
        return None;
    }
    Some(binder.bound.into_iter().flatten().collect())
}

fn field_type_nodes(session: &AnalysisSession<'_>, template: usize) -> Vec<usize> {
    let mut nodes = Vec::new();
    for field in session.children(template) {
        let Some(declaration) = session.child(field, NodeKind::Declaration) else {
            continue;
        };
        let Some(kind) = session.child(declaration, NodeKind::Type) else {
            continue;
        };
        let names = session
            .children(declaration)
            .into_iter()
            .filter(|child| session.kind(*child) == NodeKind::Identifier)
            .count();
        nodes.extend(std::iter::repeat_n(kind, names));
    }
    nodes
}
