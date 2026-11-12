use crate::identities::TypeId;
use crate::session::AnalysisSession;
use crate::types::Type;

pub(crate) fn instance_name(
    session: &AnalysisSession<'_>,
    name: &str,
    arguments: &[TypeId],
) -> String {
    let labels: Vec<String> = arguments.iter().map(|kind| label(session, *kind)).collect();
    format!("{name}<{}>", labels.join(","))
}

fn label(session: &AnalysisSession<'_>, kind: TypeId) -> String {
    match session.module.types.get(kind) {
        Type::Integer => "integer".to_owned(),
        Type::Real => "real".to_owned(),
        Type::Boolean => "boolean".to_owned(),
        Type::Character => "character".to_owned(),
        Type::String => "string".to_owned(),
        Type::Array { element, rank } => {
            let suffix = "[]".repeat(usize::try_from(rank).unwrap_or(1));
            format!("{}{suffix}", label(session, element))
        }
        Type::Enum(identifier) => usize::try_from(identifier.0)
            .ok()
            .and_then(|slot| session.module.enums.get(slot))
            .map(|model| model.name.clone())
            .unwrap_or_default(),
        Type::Record(identifier) => usize::try_from(identifier.0)
            .ok()
            .and_then(|slot| session.module.records.get(slot))
            .map(|model| model.name.clone())
            .unwrap_or_default(),
        Type::Object(identifier) => crate::hierarchy::class_model(session, identifier)
            .map(|class| class.name.clone())
            .unwrap_or_default(),
        other => format!("{other:?}").to_lowercase(),
    }
}
