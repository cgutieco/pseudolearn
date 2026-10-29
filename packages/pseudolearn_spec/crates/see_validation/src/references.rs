use see_model::{Specification, field, strings};

pub fn check(specification: &Specification) -> Vec<String> {
    let mut errors = Vec::new();
    if serde_json::to_value(&specification.metadata)
        .is_ok_and(|metadata| contains_external_document_link(&metadata))
        || specification
            .blocks
            .iter()
            .flat_map(|block| block.fields.values())
            .any(contains_external_document_link)
    {
        errors.push("SEE-REFERENCE: external documentation link forbidden".to_owned());
    }
    for block in &specification.blocks {
        match block.kind.as_str() {
            "regla" | "invariante" | "precondicion" | "resultado" => {
                check_rule(specification, block, &mut errors)
            }
            "caso" | "propiedad" => check_primary(specification, block, &mut errors),
            "error" => check_error(specification, block, &mut errors),
            _ => (),
        }
    }
    errors
}

fn contains_external_document_link(value: &serde_json::Value) -> bool {
    match value {
        serde_json::Value::String(text) => {
            let normalized = text.to_ascii_lowercase();
            normalized.contains("www.") || normalized.contains("](") && normalized.contains("://")
        }
        serde_json::Value::Array(values) => values.iter().any(contains_external_document_link),
        serde_json::Value::Object(fields) => fields.values().any(contains_external_document_link),
        _ => false,
    }
}

fn check_rule(specification: &Specification, block: &see_model::Block, errors: &mut Vec<String>) {
    let verification = strings(block.fields.get("verificacion"));
    if verification.is_empty() {
        errors.push(format!(
            "SEE-ORPHAN: {}#{}",
            specification.metadata.id,
            field(block, "id")
        ));
    }
    for reference in verification {
        if reference == "revision_humana" || reference == "estructural" {
            if field(block, "justificacion").is_empty() {
                errors.push("SEE-ORPHAN: justified review required".to_owned());
            }
        } else if !specification.blocks.iter().any(|candidate| {
            field(candidate, "id") == reference
                && ["caso", "propiedad", "medicion"].contains(&candidate.kind.as_str())
        }) {
            errors.push(format!("SEE-REFERENCE: unknown verification {reference}"));
        }
    }
    for reference in strings(block.fields.get("referencias")) {
        if !specification
            .blocks
            .iter()
            .any(|candidate| field(candidate, "id") == reference)
        {
            errors.push(format!("SEE-REFERENCE: undefined term {reference}"));
        }
    }
}

fn check_primary(
    specification: &Specification,
    block: &see_model::Block,
    errors: &mut Vec<String>,
) {
    let primary = field(block, "regla");
    if !specification
        .blocks
        .iter()
        .any(|candidate| field(candidate, "id") == primary && candidate.kind == "regla")
    {
        errors.push(format!("SEE-REFERENCE: missing primary rule {primary}"));
    }
    if specification.metadata.id.starts_with("LANG.") && block.kind == "caso" {
        for profile in ["es", "en"] {
            let excluded = block
                .fields
                .get("exclusiones")
                .and_then(|value| value.get(profile))
                .and_then(|value| value.as_str())
                .is_some_and(|reason| !reason.trim().is_empty());
            if !strings(block.fields.get("perfiles")).contains(&profile) && !excluded {
                errors.push(format!(
                    "SEE-PROFILE: case {} missing {profile} or justified exclusion",
                    field(block, "id")
                ));
            }
        }
    }
}

fn check_error(specification: &Specification, block: &see_model::Block, errors: &mut Vec<String>) {
    let id = field(block, "id");
    for role in ["produce", "evita"] {
        if !specification
            .blocks
            .iter()
            .any(|case| case.kind == "caso" && strings(case.fields.get(role)).contains(&id))
        {
            errors.push(format!("SEE-ERROR-COVERAGE: {id} missing {role} case"));
        }
    }
}

pub fn capture_review(specification: &Specification) -> Vec<String> {
    specification
        .blocks
        .iter()
        .filter(|block| {
            block.kind == "caso"
                && field(block, "origen") == "capturado"
                && specification
                    .metadata
                    .duenos
                    .iter()
                    .any(|owner| owner == field(block, "revisado_por"))
        })
        .map(|_| "SEE-CAPTURE: independent reviewer required".to_owned())
        .collect()
}
