mod contracts;
use serde_json::json;

fn conventions() -> serde_json::Value {
    json!({"kind":"definicion","fields":{"id":"D1","termino":"cliConventions","texto":"Convenciones.","valor":{"codigos_salida":{"0":"éxito","2":"uso"},"aperturas":["algorithm"]}}})
}

fn vocabulary() -> serde_json::Value {
    json!({"kind":"definicion","fields":{"id":"D2","termino":"vocabulary","texto":"Vocabulario.","valor":{"algorithm":{"lexemas":{"es":"Proceso","en":"algorithm"},"alias":{"es":["Algoritmo"],"en":[]}}}}})
}

fn cli_case(code: u64) -> serde_json::Value {
    json!({"kind":"caso","fields":{"id":"C1","regla":"R1","operacion":"cli","espera":{"codigo_salida":code}}})
}

#[test]
fn accepts_declared_exit_codes() -> Result<(), String> {
    for code in [0, 2] {
        let corpus = contracts::corpus(
            "TOOL.CLI.CHECK",
            json!([conventions(), vocabulary(), cli_case(code)]),
        )?;
        assert!(see_validation::cli::check(&corpus).is_empty());
    }
    Ok(())
}

#[test]
fn rejects_undeclared_codes_missing_tables_and_invalid_conventions() -> Result<(), String> {
    for blocks in [
        json!([conventions(), vocabulary(), cli_case(9)]),
        json!([cli_case(0)]),
        json!([conventions(), vocabulary(), {"kind":"caso","fields":{"id":"C1","regla":"R1","operacion":"cli","espera":{"salida":""}}}]),
    ] {
        let errors = see_validation::cli::check(&contracts::corpus("TOOL.CLI.CHECK", blocks)?);
        assert!(
            errors.iter().any(|error| error.starts_with("SEE-CLI-EXIT")),
            "{errors:?}"
        );
    }
    for invalid in [
        json!({}),
        json!({"codigos_salida":{},"aperturas":["algorithm"]}),
        json!({"codigos_salida":{"x":"?"},"aperturas":["algorithm"]}),
        json!({"codigos_salida":{"0":"éxito"},"aperturas":[]}),
    ] {
        assert!(see_validation::cli::conventions(&invalid).is_err());
    }
    Ok(())
}
