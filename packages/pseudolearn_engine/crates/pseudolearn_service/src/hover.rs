use crate::navigation::{Position, byte_offset_at_position};
use pseudolearn_lexicon::Profile;
use pseudolearn_semantic::hir::Passing;
use pseudolearn_semantic::types::Type;
use pseudolearn_semantic::{ServiceAnalysis, ServiceSymbolCategory};
use pseudolearn_source::SourceText;
use serde::{Deserialize, Serialize};

#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct HoverOutcome {
    pub type_name: String,
    pub is_inferred: bool,
    pub is_intrinsic: bool,
    pub identifier: String,
    pub signature: Option<String>,
}

#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct SignatureHelp {
    pub active_parameter: u32,
    pub signature: String,
}

pub fn hover_at_position(
    analysis: &ServiceAnalysis,
    source: &SourceText,
    position: Position,
    profile: Profile,
) -> Option<HoverOutcome> {
    let offset = byte_offset_at_position(source, position);
    let word = extract_identifier_at_offset(source.as_str(), offset);
    if let Some(intrinsic_name) = match_intrinsic(&word) {
        return Some(HoverOutcome {
            type_name: String::from("Function"),
            is_inferred: false,
            is_intrinsic: true,
            identifier: intrinsic_name.to_owned(),
            signature: Some(format!("{intrinsic_name}()")),
        });
    }
    let symbol = analysis.symbol_at_byte_offset(offset)?;
    let type_kind = analysis.module.types.get(symbol.type_id);
    let type_name = format_type_name(type_kind, profile);
    let signature = if symbol.category == ServiceSymbolCategory::Function
        || symbol.category == ServiceSymbolCategory::Procedure
    {
        Some(format_signature(
            &symbol.name,
            &symbol.parameter_types,
            profile,
        ))
    } else {
        None
    };
    Some(HoverOutcome {
        type_name,
        is_inferred: symbol.is_inferred,
        is_intrinsic: false,
        identifier: symbol.name.clone(),
        signature,
    })
}

pub fn signature_help_at_position(
    analysis: &ServiceAnalysis,
    source: &SourceText,
    position: Position,
    profile: Profile,
) -> Option<SignatureHelp> {
    let offset = byte_offset_at_position(source, position);
    let text = source.as_str();
    let prefix = text.get(..offset).unwrap_or(text);
    let open_parenthesis_index = prefix.rfind('(')?;
    let call_prefix = prefix.get(..open_parenthesis_index)?;
    let function_name = call_prefix
        .split(|character: char| !character.is_alphanumeric() && character != '_')
        .rfind(|part| !part.is_empty())?;
    let function = analysis.function_by_name(function_name)?;
    let arguments_slice = prefix.get(open_parenthesis_index.saturating_add(1)..)?;
    let active_parameter = u32::try_from(
        arguments_slice
            .chars()
            .filter(|&character| character == ',')
            .count(),
    )
    .unwrap_or(0);
    let parameter_types: Vec<(String, pseudolearn_semantic::identities::TypeId, Passing)> =
        function
            .parameters
            .iter()
            .filter_map(|parameter_id| {
                let parameter_position = usize::try_from(parameter_id.0).ok()?;
                let local = analysis.module.locals.get(parameter_position)?;
                Some((local.name.clone(), local.type_id, local.passing))
            })
            .collect();
    let signature = format_signature(&function.name, &parameter_types, profile);
    Some(SignatureHelp {
        active_parameter,
        signature,
    })
}

fn extract_identifier_at_offset(text: &str, offset: usize) -> String {
    let start = text
        .get(..offset)
        .and_then(|prefix| {
            prefix.rfind(|character: char| !character.is_alphanumeric() && character != '_')
        })
        .map(|index| index.saturating_add(1))
        .unwrap_or(0);
    let ending = text
        .get(offset..)
        .and_then(|suffix| {
            suffix.find(|character: char| !character.is_alphanumeric() && character != '_')
        })
        .map(|index| offset.saturating_add(index))
        .unwrap_or(text.len());
    text.get(start..ending).unwrap_or("").to_owned()
}

fn match_intrinsic(word: &str) -> Option<&'static str> {
    let intrinsics = [
        ("subcadena", "subcadena"),
        ("substring", "substring"),
        ("longitud", "longitud"),
        ("length", "length"),
        ("rc", "rc"),
        ("raiz", "raiz"),
        ("sqrt", "sqrt"),
        ("abs", "abs"),
        ("redon", "redon"),
        ("round", "round"),
        ("trunc", "trunc"),
        ("azar", "azar"),
        ("random", "random"),
        ("mayusculas", "mayusculas"),
        ("uppercase", "uppercase"),
        ("minusculas", "minusculas"),
        ("lowercase", "lowercase"),
    ];
    for &(candidate, canonical) in &intrinsics {
        if word.eq_ignore_ascii_case(candidate) {
            return Some(canonical);
        }
    }
    None
}

fn format_type_name(kind: Type, profile: Profile) -> String {
    match (kind, profile) {
        (Type::Integer, Profile::Spanish) => String::from("Entero"),
        (Type::Integer, Profile::English) => String::from("Integer"),
        (Type::Real, _) => String::from("Real"),
        (Type::Boolean, Profile::Spanish) => String::from("Logico"),
        (Type::Boolean, Profile::English) => String::from("Boolean"),
        (Type::Character, Profile::Spanish) => String::from("Caracter"),
        (Type::Character, Profile::English) => String::from("Character"),
        (Type::String, Profile::Spanish) => String::from("Cadena"),
        (Type::String, Profile::English) => String::from("String"),
        _ => String::from("Desconocido"),
    }
}

fn format_signature(
    name: &str,
    parameters: &[(String, pseudolearn_semantic::identities::TypeId, Passing)],
    profile: Profile,
) -> String {
    let mut parts = Vec::new();
    for (parameter_name, _, passing) in parameters {
        let mode_text = match (passing, profile) {
            (Passing::Reference, Profile::Spanish) => "Por Referencia",
            (Passing::Reference, Profile::English) => "By Reference",
            (Passing::Value, Profile::Spanish) => "Por Valor",
            (Passing::Value, Profile::English) => "By Value",
        };
        parts.push(format!("{parameter_name} {mode_text}"));
    }
    format!("{name}({})", parts.join(", "))
}
