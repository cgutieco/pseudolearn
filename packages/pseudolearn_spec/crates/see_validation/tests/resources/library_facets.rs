use see_validation::resources::library_facets::check_values;
use serde_json::json;

fn functions() -> serde_json::Value {
    json!({
        "text_first": {
            "family": "text",
            "lexemas": {"es": "Primero", "en": "first"},
            "alias": {"es": [], "en": []},
            "parametros": ["string"],
            "retorno": "string"
        }
    })
}

fn capabilities() -> serde_json::Value {
    json!({"operations": []})
}

fn catalog() -> serde_json::Value {
    json!({"cards": [{
        "tokens": [{
            "identity": "text_first",
            "source": {"specification": "LIB.MODEL"}
        }],
        "content": {
            "es": {"parts": [{"identity": "text_first", "text": "Primero"}]},
            "en": {"parts": [{"identity": "text_first", "text": "First"}]}
        }
    }]})
}

#[test]
fn accepts_matching_bilingual_facets_and_help() {
    assert!(check_values(&functions(), &capabilities(), &catalog()).is_empty());
}

#[test]
fn rejects_missing_english_facet() {
    let mut definitions = functions();
    let removed = definitions
        .get_mut("text_first")
        .and_then(|function| function.get_mut("lexemas"))
        .and_then(serde_json::Value::as_object_mut)
        .and_then(|lexemes| lexemes.remove("en"));
    assert_eq!(removed, Some(json!("first")));
    let errors = check_values(&definitions, &capabilities(), &catalog());
    assert!(
        errors
            .iter()
            .any(|error| error.contains("M1 missing en facet"))
    );
}

#[test]
fn rejects_identity_with_conflicting_signature() -> Result<(), String> {
    let mut operations = capabilities();
    let fields = operations
        .as_object_mut()
        .ok_or("missing capability library")?;
    fields.insert(
        "operations".to_owned(),
        json!([{
            "identity": "text_first",
            "family": "text",
            "receiver": null,
            "es": "Primero",
            "en": "first",
            "parameters": [],
            "result": "text",
            "effect": false,
            "fallible": false
        }]),
    );
    let errors = check_values(&functions(), &operations, &catalog());
    assert!(
        errors
            .iter()
            .any(|error| error.contains("M1 conflicting signatures"))
    );
    Ok(())
}

#[test]
fn rejects_missing_bilingual_help_card() {
    let errors = check_values(&functions(), &capabilities(), &json!({"cards": []}));
    assert!(
        errors
            .iter()
            .any(|error| error.contains("M3 missing bilingual card"))
    );
}

#[test]
fn rejects_duplicate_profile_forms() -> Result<(), String> {
    let mut definitions = functions();
    let fields = definitions
        .as_object_mut()
        .ok_or("missing builtin functions")?;
    fields.insert(
        "text_second".to_owned(),
        json!({
            "family": "text",
            "lexemas": {"es": "Primero", "en": "second"},
            "alias": {"es": [], "en": []},
            "parametros": [],
            "retorno": "string"
        }),
    );
    let errors = check_values(&definitions, &capabilities(), &catalog());
    assert!(
        errors
            .iter()
            .any(|error| error.contains("M2 duplicate form"))
    );
    Ok(())
}
