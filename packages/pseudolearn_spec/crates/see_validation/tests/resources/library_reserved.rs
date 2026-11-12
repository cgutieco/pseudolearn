use see_validation::resources::library_reserved::check_values;
use serde_json::{Value, json};

fn vocabulary() -> Value {
    json!({
        "write": {
            "lexemas": {"es": "Escribir", "en": "write"},
            "alias": {"es": ["Mostrar"], "en": ["print"]}
        },
        "jsonValueType": {
            "lexemas": {"es": "ValorJson", "en": "JsonValue"}
        }
    })
}

fn functions(spanish: &str, english: &str) -> Value {
    json!({
        "text_first": {
            "lexemas": {"es": spanish, "en": english},
            "alias": {"es": [], "en": []}
        }
    })
}

fn capabilities(spanish: &str, english: &str, aliases: Value) -> Value {
    json!({"operations": [{
        "identity": "console_write",
        "receiver": "console",
        "es": spanish,
        "en": english,
        "alias": aliases
    }]})
}

fn no_aliases() -> Value {
    json!({"es": [], "en": []})
}

#[test]
fn accepts_library_forms_that_are_not_reserved_words() {
    let errors = check_values(
        &vocabulary(),
        &functions("Primero", "first"),
        &capabilities("EscribirTexto", "writeText", no_aliases()),
    );
    assert!(errors.is_empty(), "{errors:?}");
}

#[test]
fn accepts_empty_resources() {
    assert!(check_values(&json!({}), &json!({}), &json!({"operations": []})).is_empty());
}

#[test]
fn rejects_an_operation_named_like_a_reserved_word_in_any_letter_case() {
    let errors = check_values(
        &vocabulary(),
        &functions("Primero", "first"),
        &capabilities("ESCRIBIR", "Write", no_aliases()),
    );
    assert_eq!(errors.len(), 2, "{errors:?}");
    assert!(
        errors
            .iter()
            .all(|error| error.starts_with("SEE-LIB-RESERVED"))
    );
    assert!(
        errors
            .iter()
            .any(|error| error.contains("console_write es"))
    );
    assert!(
        errors
            .iter()
            .any(|error| error.contains("console_write en"))
    );
}

#[test]
fn rejects_a_function_that_collides_with_a_reserved_alias_or_accent_variant() {
    let errors = check_values(
        &vocabulary(),
        &functions("Móstrar", "first"),
        &capabilities("EscribirTexto", "writeText", no_aliases()),
    );
    assert_eq!(errors.len(), 1, "{errors:?}");
    assert!(errors.first().is_some_and(|error| {
        error.contains("text_first es form Móstrar is the reserved word write")
    }));
}

#[test]
fn rejects_a_library_alias_that_collides_with_a_reserved_lexeme() {
    let errors = check_values(
        &vocabulary(),
        &functions("Primero", "first"),
        &capabilities(
            "EscribirTexto",
            "writeText",
            json!({"es": [], "en": ["jsonvalue"]}),
        ),
    );
    assert_eq!(errors.len(), 1, "{errors:?}");
    assert!(
        errors
            .first()
            .is_some_and(|error| error.contains("is the reserved word jsonValueType"))
    );
}
