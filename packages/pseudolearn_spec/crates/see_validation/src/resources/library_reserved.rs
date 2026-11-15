use crate::openers::folded;
use see_model::Corpus;
use serde_json::Value;
use std::collections::BTreeMap;

const PROFILES: [&str; 2] = ["es", "en"];

type ReservedForms = BTreeMap<String, String>;

pub fn check(corpus: &Corpus) -> Vec<String> {
    let resources = ["vocabulary", "functions", "capabilityLibrary"]
        .map(|term| crate::cli::resource(corpus, term));
    let [Some(vocabulary), Some(functions), Some(capabilities)] = resources else {
        return Vec::new();
    };
    check_values(vocabulary, functions, capabilities)
}

pub fn check_values(vocabulary: &Value, functions: &Value, capabilities: &Value) -> Vec<String> {
    let mut errors = Vec::new();
    for profile in PROFILES {
        let reserved = reserved_forms(vocabulary, profile);
        for (identity, form) in library_forms(functions, capabilities, profile) {
            if let Some(keyword) = reserved.get(&folded(form)) {
                errors.push(format!(
                    "SEE-LIB-RESERVED: M2 {identity} {profile} form {form} is the reserved word {keyword}"
                ));
            }
        }
    }
    errors
}

fn reserved_forms(vocabulary: &Value, profile: &str) -> ReservedForms {
    let mut forms = ReservedForms::new();
    for (keyword, entry) in vocabulary.as_object().into_iter().flatten() {
        let lexeme = entry
            .pointer(&format!("/lexemas/{profile}"))
            .and_then(Value::as_str);
        let aliases = see_model::strings(entry.pointer(&format!("/alias/{profile}")));
        for form in lexeme.into_iter().chain(aliases) {
            forms.insert(folded(form), keyword.clone());
        }
    }
    forms
}

fn library_forms<'value>(
    functions: &'value Value,
    capabilities: &'value Value,
    profile: &str,
) -> Vec<(&'value str, &'value str)> {
    let mut forms = Vec::new();
    for (identity, function) in functions.as_object().into_iter().flatten() {
        let lexeme = function
            .pointer(&format!("/lexemas/{profile}"))
            .and_then(Value::as_str);
        let aliases = see_model::strings(function.pointer(&format!("/alias/{profile}")));
        forms.extend(
            lexeme
                .into_iter()
                .chain(aliases)
                .map(|form| (identity.as_str(), form)),
        );
    }
    let operations = capabilities.get("operations").and_then(Value::as_array);
    for operation in operations.into_iter().flatten() {
        let identity = operation
            .get("identity")
            .and_then(Value::as_str)
            .unwrap_or_default();
        let lexeme = operation.get(profile).and_then(Value::as_str);
        let aliases = see_model::strings(operation.pointer(&format!("/alias/{profile}")));
        forms.extend(
            lexeme
                .into_iter()
                .chain(aliases)
                .map(|form| (identity, form)),
        );
    }
    forms
}
