use serde_json::json;

fn entry(spanish: &str, english: &str) -> serde_json::Value {
    json!({"mensajes":{"es":spanish,"en":english},"argumentos":["ruta"],"tipos_argumentos":{"ruta":"lexema"}})
}

#[test]
fn accepts_bilingual_messages_with_the_same_typed_arguments() {
    let catalog = json!({"missingFile":entry("No existe {ruta}.","Missing {ruta}.")});
    assert!(see_validation::messages::check(&catalog).is_empty());
}

#[test]
fn rejects_missing_locales_and_argument_drift() {
    let parity = [
        json!({}),
        json!({"usage":{"mensajes":{"es":"Uso."},"argumentos":[],"tipos_argumentos":{}}}),
        json!({"usage":{"mensajes":{"es":"Uso.","en":"  "},"argumentos":[],"tipos_argumentos":{}}}),
    ];
    for catalog in parity {
        let errors = see_validation::messages::check(&catalog);
        assert!(
            errors
                .iter()
                .any(|error| error.starts_with("SEE-MESSAGE-PARITY")),
            "{errors:?}"
        );
    }
    let drift = [
        json!({"missingFile":entry("No existe {ruta}.","Missing {path}.")}),
        json!({"missingFile":entry("No existe.","Missing {ruta}.")}),
        json!({"missingFile":{"mensajes":{"es":"{ruta}","en":"{ruta}"},"argumentos":["ruta"],"tipos_argumentos":{"ruta":"libre"}}}),
        json!({"missingFile":entry("No existe {ruta.","Missing {ruta}.")}),
    ];
    for catalog in drift {
        let errors = see_validation::messages::check(&catalog);
        assert!(
            errors
                .iter()
                .any(|error| error.starts_with("SEE-MESSAGE-ARGUMENTS")),
            "{errors:?}"
        );
    }
}
