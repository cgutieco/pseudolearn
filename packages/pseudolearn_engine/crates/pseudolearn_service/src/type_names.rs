use crate::spelling::keyword_spelling;
use pseudolearn_lexicon::{KeywordKind, Profile};
use pseudolearn_semantic::ServiceAnalysis;
use pseudolearn_semantic::identities::TypeId;
use pseudolearn_semantic::types::Type;

pub fn type_display(analysis: &ServiceAnalysis, type_id: TypeId, profile: Profile) -> String {
    match analysis.module.types.get(type_id) {
        Type::Integer => keyword_spelling(KeywordKind::IntegerType, profile),
        Type::Real => keyword_spelling(KeywordKind::RealType, profile),
        Type::Boolean => keyword_spelling(KeywordKind::BooleanType, profile),
        Type::Character => keyword_spelling(KeywordKind::CharacterType, profile),
        Type::String => keyword_spelling(KeywordKind::StringType, profile),
        Type::Task(payload) => format!(
            "{}<{}>",
            keyword_spelling(KeywordKind::TaskType, profile),
            type_display(analysis, payload, profile)
        ),
        Type::Object(class_id) => collection_display(analysis, class_id, profile)
            .unwrap_or_else(|| class_name(analysis, class_id.0)),
        Type::Enum(enumeration) => declared_name(
            analysis
                .module
                .enums
                .get(slot(enumeration.0))
                .map(|model| &model.name),
        ),
        Type::Record(record) => record_display(analysis, record, profile),
        Type::Array { element, rank } => {
            let commas = ",".repeat(usize::try_from(rank.saturating_sub(1)).unwrap_or(0));
            format!("{}[{commas}]", type_display(analysis, element, profile))
        }
        Type::Unit | Type::Never => String::new(),
        Type::Unknown | Type::Error => unknown_type_label(profile).to_owned(),
    }
}

pub fn unknown_type_label(profile: Profile) -> &'static str {
    match profile {
        Profile::Spanish => "Desconocido",
        Profile::English => "Unknown",
    }
}

pub fn builtin_type_display(word: &str, profile: Profile) -> String {
    let kind = match word {
        "integer" => KeywordKind::IntegerType,
        "real" => KeywordKind::RealType,
        "string" => KeywordKind::StringType,
        "character" => KeywordKind::CharacterType,
        "boolean" => KeywordKind::BooleanType,
        "numeric" => return numeric_label(profile).to_owned(),
        _ => return word.to_owned(),
    };
    keyword_spelling(kind, profile)
}

fn numeric_label(profile: Profile) -> &'static str {
    match profile {
        Profile::Spanish => "Numerico",
        Profile::English => "Numeric",
    }
}

fn class_name(analysis: &ServiceAnalysis, identifier: u32) -> String {
    usize::try_from(identifier)
        .ok()
        .and_then(|index| analysis.module.classes.get(index))
        .map(|class| class.name.clone())
        .unwrap_or_default()
}

fn slot(identifier: u32) -> usize {
    usize::try_from(identifier).unwrap_or(usize::MAX)
}

fn declared_name(name: Option<&String>) -> String {
    name.cloned().unwrap_or_default()
}

fn record_display(
    analysis: &ServiceAnalysis,
    record: pseudolearn_semantic::identities::RecordId,
    profile: Profile,
) -> String {
    let Some(variant) = analysis.module.variants.get(&record) else {
        return declared_name(
            analysis
                .module
                .records
                .get(slot(record.0))
                .map(|model| &model.name),
        );
    };
    let keyword = match variant.family {
        pseudolearn_semantic::variant_model::VariantFamily::Optional => KeywordKind::OptionalType,
        pseudolearn_semantic::variant_model::VariantFamily::Result => KeywordKind::ResultType,
    };
    let arguments: Vec<_> = variant
        .payloads
        .iter()
        .flatten()
        .map(|kind| type_display(analysis, *kind, profile))
        .collect();
    format!(
        "{}<{}>",
        keyword_spelling(keyword, profile),
        arguments.join(", ")
    )
}

fn collection_display(
    analysis: &ServiceAnalysis,
    class: pseudolearn_semantic::identities::ClassId,
    profile: Profile,
) -> Option<String> {
    let collection = analysis.module.collections.get(&class)?;
    let identity = if collection.key.is_some() {
        "dictionaryType"
    } else {
        "vectorType"
    };
    let name = pseudolearn_syntax::contextual_spelling(identity, profile.as_str())?;
    let mut arguments = Vec::new();
    if let Some(key) = collection.key {
        arguments.push(type_display(analysis, key, profile));
    }
    arguments.push(type_display(analysis, collection.value, profile));
    Some(format!("{name}<{}>", arguments.join(", ")))
}
