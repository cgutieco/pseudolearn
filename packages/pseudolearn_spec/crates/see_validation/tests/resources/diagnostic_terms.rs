use see_validation::resources::diagnostic_terms::check;
use serde_json::{Value, json};

fn catalog() -> Value {
    json!({"sample": {"tipos_argumentos": {"cause": "termino", "lexeme": "lexema"}}})
}

fn terms(texts: Value) -> Value {
    json!({"sample": {"cause": {"first": texts}}})
}

#[test]
fn accepts_bilingual_texts_for_term_arguments() {
    let catalog = catalog();
    assert!(
        check(
            &terms(json!({"es": "primer camino", "en": "first path"})),
            Some(&catalog)
        )
        .is_ok()
    );
}

#[test]
fn rejects_unknown_codes_and_arguments_that_are_not_terms() {
    let catalog = catalog();
    let texts = json!({"es": "texto", "en": "text"});
    for malformed in [
        json!({"other": {"cause": {"first": texts}}}),
        json!({"sample": {"lexeme": {"first": texts}}}),
        json!({"sample": {"missing": {"first": texts}}}),
    ] {
        assert!(
            check(&malformed, Some(&catalog))
                .is_err_and(|error| error.starts_with("SEE-DIAGNOSTIC-TERMS"))
        );
    }
    assert!(check(&terms(texts), None).is_err());
}

#[test]
fn rejects_empty_or_malformed_tables_and_texts() {
    let catalog = catalog();
    for malformed in [
        json!(null),
        json!({}),
        json!({"sample": {}}),
        json!({"sample": {"cause": {}}}),
        terms(json!({"es": "texto"})),
        terms(json!({"es": "texto", "en": "text", "fr": "texte"})),
        terms(json!({"es": "", "en": "text"})),
        terms(json!({"es": "texto {x}", "en": "text"})),
        terms(json!({"es": "texto", "en": 1})),
        terms(json!({"es": "fijate en esto", "en": "text"})),
    ] {
        assert!(check(&malformed, Some(&catalog)).is_err(), "{malformed}");
    }
}
