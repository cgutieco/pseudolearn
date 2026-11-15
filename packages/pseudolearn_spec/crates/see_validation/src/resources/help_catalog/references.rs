use see_model::{Corpus, field, strings};
use serde_json::Value;

pub(super) fn check(value: &Value, corpus: &Corpus) -> Vec<String> {
    let mut errors = Vec::new();
    if let Some(cards) = value.get("cards").and_then(Value::as_array) {
        for card in cards {
            errors.extend(card_references(card, corpus));
        }
    }
    if let Some(exclusions) = value.get("exclusions").and_then(Value::as_array) {
        for exclusion in exclusions {
            errors.extend(exclusion_reference(exclusion, corpus));
        }
    }
    errors
}

fn card_references(card: &Value, corpus: &Corpus) -> Vec<String> {
    let identifier = card.get("id").and_then(Value::as_str).unwrap_or_default();
    let mut errors = token_references(identifier, card, corpus);
    errors.extend(anchor_references(identifier, card, corpus));
    errors.extend(form_references(identifier, card, corpus));
    if let Some(content) = card.get("content").and_then(Value::as_object) {
        for localized in content.values() {
            errors.extend(example_references(identifier, card, localized, corpus));
            errors.extend(super::catalog_examples::kind_errors(
                identifier, localized, corpus,
            ));
        }
    }
    errors
}

fn token_references(identifier: &str, card: &Value, corpus: &Corpus) -> Vec<String> {
    card.get("tokens")
        .and_then(Value::as_array)
        .into_iter()
        .flatten()
        .filter(|token| !token_source_exists(token, corpus))
        .map(|_| format!("SEE-HELP-CATALOG: {identifier} has a stale token identity"))
        .collect()
}

fn anchor_references(identifier: &str, card: &Value, corpus: &Corpus) -> Vec<String> {
    card.get("anchors")
        .and_then(Value::as_array)
        .into_iter()
        .flatten()
        .filter(|anchor| !has_element(corpus, anchor))
        .map(|_| format!("SEE-HELP-CATALOG: {identifier} has a stale anchor"))
        .collect()
}

fn example_references(
    identifier: &str,
    card: &Value,
    content: &Value,
    corpus: &Corpus,
) -> Vec<String> {
    let examples = entries(content, "examples");
    let error_cases = entries(content, "common_errors").filter_map(|error| error.get("case"));
    examples
        .chain(error_cases)
        .filter(|reference| !example_is_available(corpus, card, reference))
        .map(|_| format!("SEE-HELP-CATALOG: {identifier} has a stale example"))
        .collect()
}

fn form_references(identifier: &str, card: &Value, corpus: &Corpus) -> Vec<String> {
    entries(card, "form")
        .flat_map(|line| entries(line, "segments"))
        .filter_map(|segment| segment.get("token").and_then(Value::as_str))
        .filter(|token| !lexical_identity_exists(corpus, token))
        .map(|token| format!("SEE-HELP-CATALOG: {identifier} has an unknown form token {token}"))
        .collect()
}

fn lexical_identity_exists(corpus: &Corpus, identifier: &str) -> bool {
    corpus
        .iter()
        .filter(|specification| specification.metadata.estado != "retirado")
        .flat_map(|specification| specification.blocks.iter())
        .any(|block| definition_has_identity(block, identifier))
}

fn entries<'value>(value: &'value Value, key: &str) -> impl Iterator<Item = &'value Value> {
    value
        .get(key)
        .and_then(Value::as_array)
        .into_iter()
        .flatten()
}

fn token_source_exists(token: &Value, corpus: &Corpus) -> bool {
    let Some(identifier) = token.get("identity").and_then(Value::as_str) else {
        return false;
    };
    let Some(source) = token.get("source") else {
        return false;
    };
    let Some(target) = target_specification(corpus, source) else {
        return false;
    };
    let Some(element) = source.get("element").and_then(Value::as_str) else {
        return false;
    };
    let Some(block) = target
        .blocks
        .iter()
        .find(|block| field(block, "id") == element)
    else {
        return false;
    };
    definition_has_identity(block, identifier)
}

fn definition_has_identity(block: &see_model::Block, identifier: &str) -> bool {
    if block.kind != "definicion" {
        return false;
    }
    match field(block, "termino") {
        "vocabulary" | "contextualVocabulary" | "functions" => block
            .fields
            .get("valor")
            .and_then(Value::as_object)
            .is_some_and(|entries| entries.contains_key(identifier)),
        "capabilityLibrary" => block
            .fields
            .get("valor")
            .and_then(|value| value.get("operations"))
            .and_then(Value::as_array)
            .is_some_and(|operations| {
                operations.iter().any(|operation| {
                    operation.get("identity").and_then(Value::as_str) == Some(identifier)
                })
            }),
        _ => false,
    }
}

fn example_is_available(corpus: &Corpus, card: &Value, example: &Value) -> bool {
    let Some(case) = example_case(corpus, example) else {
        return false;
    };
    let declared = strings(case.fields.get("perfiles"));
    let programs = case.fields.get("programas");
    entries(card.get("availability").unwrap_or(&Value::Null), "profiles")
        .filter_map(Value::as_str)
        .all(|profile| {
            declared.contains(&profile)
                && programs
                    .and_then(|value| value.get(profile))
                    .and_then(Value::as_str)
                    .is_some_and(|program| !program.is_empty())
        })
}

pub(crate) fn example_case<'corpus>(
    corpus: &'corpus Corpus,
    example: &Value,
) -> Option<&'corpus see_model::Block> {
    let target = target_specification(corpus, example)?;
    let case_identifier = example.get("case").and_then(Value::as_str)?;
    target
        .blocks
        .iter()
        .find(|block| block.kind == "caso" && field(block, "id") == case_identifier)
}

fn exclusion_reference(exclusion: &Value, corpus: &Corpus) -> Vec<String> {
    if exclusion
        .get("anchor")
        .is_some_and(|anchor| has_element(corpus, anchor))
    {
        Vec::new()
    } else {
        vec![format!(
            "SEE-HELP-CATALOG: {} has a stale exclusion anchor",
            exclusion
                .get("id")
                .and_then(Value::as_str)
                .unwrap_or_default()
        )]
    }
}

pub(super) fn specification<'corpus>(
    corpus: &'corpus Corpus,
    identifier: &str,
    version: &str,
) -> Option<&'corpus see_model::Specification> {
    corpus.iter().find(|specification| {
        specification.metadata.id == identifier
            && specification.metadata.version == version
            && specification.metadata.estado != "retirado"
    })
}

fn target_specification<'corpus>(
    corpus: &'corpus Corpus,
    reference: &Value,
) -> Option<&'corpus see_model::Specification> {
    let identifier = reference.get("specification")?.as_str()?;
    let version = reference.get("version")?.as_str()?;
    specification(corpus, identifier, version)
}

fn has_element(corpus: &Corpus, reference: &Value) -> bool {
    let Some(target) = target_specification(corpus, reference) else {
        return false;
    };
    let Some(element) = reference.get("element").and_then(Value::as_str) else {
        return false;
    };
    target
        .blocks
        .iter()
        .any(|block| field(block, "id") == element)
}
