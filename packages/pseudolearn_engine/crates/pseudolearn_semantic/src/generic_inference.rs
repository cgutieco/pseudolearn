use crate::generic_state::GenericTemplate;
use crate::identities::TypeId;
use crate::session::AnalysisSession;
use crate::types::Type;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_syntax::{NodeKind, TokenKind};

struct Binder<'template> {
    names: &'template [String],
    bound: Vec<Option<TypeId>>,
}

enum Failure {
    Arity(usize),
    Unbound(Option<String>),
}

#[derive(Clone, Copy)]
enum Shape {
    Parameters,
    Fields,
}

pub(crate) fn infer(
    session: &mut AnalysisSession<'_>,
    template: &GenericTemplate,
    (actual, node): (&[TypeId], usize),
) -> Option<Vec<TypeId>> {
    resolve(session, template, (actual, node), Shape::Parameters)
}

pub(crate) fn infer_record(
    session: &mut AnalysisSession<'_>,
    template: &GenericTemplate,
    (actual, node): (&[TypeId], usize),
) -> Option<Vec<TypeId>> {
    resolve(session, template, (actual, node), Shape::Fields)
}

fn resolve(
    session: &mut AnalysisSession<'_>,
    template: &GenericTemplate,
    (actual, node): (&[TypeId], usize),
    shape: Shape,
) -> Option<Vec<TypeId>> {
    let outcome = crate::generic_home::at_home(session, template, |session| {
        unify(session, template, actual, shape)
    });
    match outcome {
        Ok(bound) => Some(bound),
        Err(Failure::Arity(expected)) => {
            crate::argument_checker::arity(session, (expected, actual.len()), node);
            None
        }
        Err(Failure::Unbound(name)) => {
            report(session, node, name.as_ref());
            None
        }
    }
}

fn unify(
    session: &AnalysisSession<'_>,
    template: &GenericTemplate,
    actual: &[TypeId],
    shape: Shape,
) -> Result<Vec<TypeId>, Failure> {
    let nodes = match shape {
        Shape::Parameters => parameter_nodes(session, template.node),
        Shape::Fields => field_type_nodes(session, template.node),
    };
    if nodes.len() != actual.len() {
        return Err(Failure::Arity(nodes.len()));
    }
    let mut binder = Binder {
        names: &template.parameters,
        bound: vec![None; template.parameters.len()],
    };
    for (node, kind) in nodes.into_iter().zip(actual) {
        let bound = match shape {
            Shape::Parameters => bind_parameter(session, node, *kind, &mut binder),
            Shape::Fields => bind(session, node, *kind, &mut binder),
        };
        if let Err(conflict) = bound {
            return Err(Failure::Unbound(binder.names.get(conflict).cloned()));
        }
    }
    if let Some(index) = binder.bound.iter().position(Option::is_none) {
        return Err(Failure::Unbound(binder.names.get(index).cloned()));
    }
    Ok(binder.bound.into_iter().flatten().collect())
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
    if session
        .token_kind(node)
        .is_some_and(pseudolearn_syntax::subprogram_keywords::opens_subprogram)
    {
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
    if let Some(result) = bind_immutable(session, (arguments, name), actual, binder) {
        return result;
    }
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
    let Some(kinds) = instance_arguments(session, name, actual) else {
        return Ok(());
    };
    for (child, kind) in session.children(arguments).into_iter().zip(kinds) {
        bind(session, child, kind, binder)?;
    }
    Ok(())
}

fn instance_arguments(
    session: &AnalysisSession<'_>,
    name: &str,
    actual: TypeId,
) -> Option<Vec<TypeId>> {
    let scope = &session.generics;
    let (origin, expected) = match session.module.types.get(actual) {
        Type::Record(record) => (
            session.generic.origins.get(&record),
            scope.records.get(name).or_else(|| scope.variants.get(name)),
        ),
        Type::Object(class) => (
            session.generic.class_origins.get(&class),
            scope.classes.get(name),
        ),
        _ => return None,
    };
    let (unit, node, kinds) = origin?;
    let expected = expected?;
    (expected.unit == *unit && expected.node == *node).then(|| kinds.clone())
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

fn bind_immutable(
    session: &AnalysisSession<'_>,
    syntax: (usize, &str),
    actual: TypeId,
    binder: &mut Binder<'_>,
) -> Option<Result<(), usize>> {
    if crate::collection_types::identity(session, syntax.1) != Some("immutableType") {
        return None;
    }
    let Type::Immutable(inner) = session.module.types.get(actual) else {
        return Some(Ok(()));
    };
    let child = session.children(syntax.0).first().copied()?;
    Some(bind(session, child, inner, binder))
}
