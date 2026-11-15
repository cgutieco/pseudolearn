use crate::declared_names::declaration_collides;
use crate::document_session::DocumentSession;
use crate::symbol_index::NamedOccurrence;
use pseudolearn_semantic::ServiceSymbolTarget;
use pseudolearn_source::IdentifierNormalizer;

pub(crate) fn document_collision(
    session: &DocumentSession,
    occurrence: &NamedOccurrence,
    new_name: &str,
) -> bool {
    match occurrence.target {
        ServiceSymbolTarget::Local(identifier) => local_collision(session, identifier, new_name),
        ServiceSymbolTarget::Function(identifier) => {
            function_collision(session, identifier, new_name)
        }
        ServiceSymbolTarget::Class(identifier) => class_collision(session, identifier, new_name),
        ServiceSymbolTarget::Field(identifier) => field_collision(session, identifier, new_name),
        ServiceSymbolTarget::Record(_)
        | ServiceSymbolTarget::Enum(_)
        | ServiceSymbolTarget::Interface(_)
        | ServiceSymbolTarget::Constant(_)
        | ServiceSymbolTarget::Template(_)
        | ServiceSymbolTarget::TypeParameter(_, _) => {
            crate::declared_names::name_collides(&session.analysis, occurrence.target, new_name)
        }
        ServiceSymbolTarget::Builtin(_) => true,
    }
}

fn local_collision(
    session: &DocumentSession,
    identifier: pseudolearn_semantic::LocalId,
    new_name: &str,
) -> bool {
    let position = usize::try_from(identifier.0).unwrap_or(usize::MAX);
    let Some(current) = session.analysis.module.locals.get(position) else {
        return true;
    };
    if declaration_collides(
        &session.analysis,
        current.span.source_id,
        ServiceSymbolTarget::Local(identifier),
        new_name,
    ) {
        return true;
    }
    session
        .analysis
        .module
        .locals
        .iter()
        .enumerate()
        .any(|(index, candidate)| {
            index != position
                && candidate.scope == current.scope
                && IdentifierNormalizer::equals(&candidate.name, new_name)
        })
}

fn function_collision(
    session: &DocumentSession,
    identifier: pseudolearn_semantic::FunctionId,
    new_name: &str,
) -> bool {
    let position = usize::try_from(identifier.0).unwrap_or(usize::MAX);
    let Some(current) = session.analysis.module.functions.get(position) else {
        return true;
    };
    if current.owner.is_none()
        && declaration_collides(
            &session.analysis,
            current.span.source_id,
            ServiceSymbolTarget::Function(identifier),
            new_name,
        )
    {
        return true;
    }
    session
        .analysis
        .module
        .functions
        .iter()
        .enumerate()
        .any(|(index, candidate)| {
            index != position
                && candidate.owner == current.owner
                && IdentifierNormalizer::equals(&candidate.name, new_name)
        })
}

fn class_collision(
    session: &DocumentSession,
    identifier: pseudolearn_semantic::ClassId,
    new_name: &str,
) -> bool {
    let position = usize::try_from(identifier.0).unwrap_or(usize::MAX);
    let Some(current) = session.analysis.module.classes.get(position) else {
        return true;
    };
    if declaration_collides(
        &session.analysis,
        current.span.source_id,
        ServiceSymbolTarget::Class(identifier),
        new_name,
    ) {
        return true;
    }
    session
        .analysis
        .module
        .classes
        .iter()
        .enumerate()
        .any(|(index, candidate)| {
            index != position && IdentifierNormalizer::equals(&candidate.name, new_name)
        })
}

fn field_collision(
    session: &DocumentSession,
    identifier: pseudolearn_semantic::FieldId,
    new_name: &str,
) -> bool {
    session.analysis.module.classes.iter().any(|class| {
        class.fields.iter().any(|candidate| {
            candidate.id != identifier && IdentifierNormalizer::equals(&candidate.name, new_name)
        })
    })
}
