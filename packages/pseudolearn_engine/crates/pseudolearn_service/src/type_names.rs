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
        Type::Object(class_id) => class_name(analysis, class_id.0),
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
