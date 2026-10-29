use see_model::{Corpus, field};
use serde_json::{Map, Value};
use std::collections::BTreeMap;

const FAMILIES: &[&str] = &[
    "text",
    "bytes",
    "numbers",
    "collections",
    "io",
    "time",
    "json",
    "network",
    "tasks",
];

type SignatureRegistry = BTreeMap<String, Value>;
type FormRegistry = BTreeMap<(String, String, String), String>;
type Registries<'registry> = (
    &'registry mut SignatureRegistry,
    &'registry mut FormRegistry,
);

pub fn check(corpus: &Corpus) -> Vec<String> {
    let Some(functions) = resource(corpus, "functions") else {
        return Vec::new();
    };
    let Some(capabilities) = resource(corpus, "capabilityLibrary") else {
        return Vec::new();
    };
    let Some(catalog) = resource(corpus, "helpCatalog") else {
        return Vec::new();
    };
    check_values(functions, capabilities, catalog)
}

pub fn check_values(functions: &Value, capabilities: &Value, catalog: &Value) -> Vec<String> {
    let mut errors = Vec::new();
    let Some(functions) = functions.as_object() else {
        return vec!["SEE-LIB-FACETS: invalid D1 functions".to_owned()];
    };
    let Some(operations) = capabilities.get("operations").and_then(Value::as_array) else {
        return vec!["SEE-LIB-FACETS: invalid D2 operations".to_owned()];
    };
    let mut signatures = BTreeMap::new();
    let mut forms = BTreeMap::new();
    for (identity, function) in functions {
        check_function(
            (identity, function),
            (&mut signatures, &mut forms),
            &mut errors,
        );
    }
    for operation in operations {
        check_operation(operation, (&mut signatures, &mut forms), &mut errors);
    }
    errors.extend(check_cards(functions, operations, catalog));
    errors
}

fn resource<'corpus>(corpus: &'corpus Corpus, term: &str) -> Option<&'corpus Value> {
    corpus
        .iter()
        .find(|specification| specification.metadata.id == "LIB.MODEL")?
        .blocks
        .iter()
        .find(|block| block.kind == "definicion" && field(block, "termino") == term)?
        .fields
        .get("valor")
}

fn check_function<'value>(
    (identity, function): (&'value str, &'value Value),
    registries: Registries<'_>,
    errors: &mut Vec<String>,
) {
    check_family(identity, function, errors);
    let signature = json_signature(function, "parametros", "retorno");
    check_identity(identity, &signature, registries.0, errors);
    let names = function.get("lexemas");
    let aliases = function.get("alias");
    for profile in ["es", "en"] {
        let Some(name) = names
            .and_then(|value| value.get(profile))
            .and_then(Value::as_str)
        else {
            errors.push(format!(
                "SEE-LIB-FACETS: M1 missing {profile} facet for {identity}"
            ));
            continue;
        };
        check_form(identity, (profile, "", name), registries.1, errors);
        for alias in see_model::strings(aliases.and_then(|value| value.get(profile))) {
            check_form(identity, (profile, "", alias), registries.1, errors);
        }
    }
}

fn check_operation(operation: &Value, registries: Registries<'_>, errors: &mut Vec<String>) {
    let identity = operation
        .get("identity")
        .and_then(Value::as_str)
        .unwrap_or_default();
    check_family(identity, operation, errors);
    let signature = json_signature(operation, "parameters", "result");
    check_identity(identity, &signature, registries.0, errors);
    let receiver = operation
        .get("receiver")
        .and_then(Value::as_str)
        .unwrap_or_default();
    for (profile, field_name) in [("es", "es"), ("en", "en")] {
        let Some(name) = operation.get(field_name).and_then(Value::as_str) else {
            errors.push(format!(
                "SEE-LIB-FACETS: M1 missing {profile} facet for {identity}"
            ));
            continue;
        };
        check_form(identity, (profile, receiver, name), registries.1, errors);
    }
}

fn check_family(identity: &str, entry: &Value, errors: &mut Vec<String>) {
    if !entry
        .get("family")
        .and_then(Value::as_str)
        .is_some_and(|family| FAMILIES.contains(&family))
    {
        errors.push(format!("SEE-LIB-FACETS: M4 invalid family for {identity}"));
    }
}

fn json_signature(entry: &Value, parameters: &str, result: &str) -> Value {
    let mut signature = Map::new();
    signature.insert(
        "parameters".to_owned(),
        entry.get(parameters).cloned().unwrap_or(Value::Null),
    );
    signature.insert(
        "result".to_owned(),
        entry.get(result).cloned().unwrap_or(Value::Null),
    );
    signature.insert(
        "receiver".to_owned(),
        entry.get("receiver").cloned().unwrap_or(Value::Null),
    );
    signature.insert(
        "effect".to_owned(),
        entry.get("effect").cloned().unwrap_or(Value::Bool(false)),
    );
    signature.insert(
        "fallible".to_owned(),
        entry.get("fallible").cloned().unwrap_or(Value::Bool(false)),
    );
    Value::Object(signature)
}

fn check_identity(
    identity: &str,
    signature: &Value,
    identities: &mut SignatureRegistry,
    errors: &mut Vec<String>,
) {
    if let Some(previous) = identities.insert(identity.to_owned(), signature.clone()) {
        let reason = if previous == *signature {
            "duplicate identity"
        } else {
            "conflicting signatures"
        };
        errors.push(format!("SEE-LIB-FACETS: M1 {reason} for {identity}"));
    }
}

fn check_form(
    identity: &str,
    (profile, receiver, name): (&str, &str, &str),
    forms: &mut FormRegistry,
    errors: &mut Vec<String>,
) {
    let key = (profile.to_owned(), receiver.to_owned(), name.to_lowercase());
    if forms
        .insert(key, identity.to_owned())
        .is_some_and(|previous| previous != identity)
    {
        errors.push(format!("SEE-LIB-FACETS: M2 duplicate form for {identity}"));
    }
}

fn check_cards(
    functions: &Map<String, Value>,
    operations: &[Value],
    catalog: &Value,
) -> Vec<String> {
    let cards = catalog.get("cards").and_then(Value::as_array);
    let Some(cards) = cards else {
        return vec!["SEE-LIB-FACETS: M3 missing help cards".to_owned()];
    };
    let identities = functions.keys().map(String::as_str).chain(
        operations
            .iter()
            .filter_map(|operation| operation.get("identity").and_then(Value::as_str)),
    );
    let mut errors = Vec::new();
    for identity in identities {
        if !cards.iter().any(|card| card_covers(card, identity)) {
            errors.push(format!(
                "SEE-LIB-FACETS: M3 missing bilingual card for {identity}"
            ));
        }
    }
    errors
}

fn card_covers(card: &Value, identity: &str) -> bool {
    let token = card
        .get("tokens")
        .and_then(Value::as_array)
        .is_some_and(|tokens| {
            tokens.iter().any(|token| {
                token.get("identity").and_then(Value::as_str) == Some(identity)
                    && token
                        .pointer("/source/specification")
                        .and_then(Value::as_str)
                        == Some("LIB.MODEL")
            })
        });
    token
        && ["es", "en"].iter().all(|locale| {
            card.pointer(&format!("/content/{locale}/parts"))
                .and_then(Value::as_array)
                .is_some_and(|parts| {
                    parts.iter().any(|part| {
                        part.get("identity").and_then(Value::as_str) == Some(identity)
                            && part
                                .get("text")
                                .and_then(Value::as_str)
                                .is_some_and(|text| !text.trim().is_empty())
                    })
                })
        })
}
