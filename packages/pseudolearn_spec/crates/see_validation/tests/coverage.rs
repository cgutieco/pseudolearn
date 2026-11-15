mod contracts;
use serde_json::json;

fn blocks(coverage: serde_json::Value) -> serde_json::Value {
    json!([
        {"kind":"regla","fields":{"id":"R1","fuerza":"DEBE","clase":"semantica","texto":"Suma.","verificacion":["C1"]}},
        {"kind":"regla","fields":{"id":"R2","fuerza":"DEBE","clase":"sintactica","texto":"Forma.","verificacion":["C1"]}},
        {"kind":"instruccion","fields":{"id":"O1","nombre":"int.add","trampas":["integerOverflow"]}},
        {"kind":"definicion","fields":{"id":"D1","termino":"diagnostics","valor":{"integerOverflow":{}}}},
        coverage
    ])
}

fn errors(coverage: serde_json::Value) -> Result<Vec<String>, String> {
    Ok(see_validation::coverage::check(&contracts::corpus(
        "LANG.OPS.ARITHMETIC",
        blocks(coverage),
    )?))
}

#[test]
fn accepts_one_entry_per_semantic_rule_with_known_instructions_or_reason() -> Result<(), String> {
    for entry in [
        json!({"kind":"cobertura","fields":{"id":"V1","regla":"LANG.OPS.ARITHMETIC#R1","instrucciones":["int.add"]}}),
        json!({"kind":"cobertura","fields":{"id":"V1","regla":"LANG.OPS.ARITHMETIC#R1","sin_ri":"Solo análisis."}}),
    ] {
        assert!(errors(entry)?.is_empty());
    }
    let corpus = contracts::corpus("LANG.OPS.ARITHMETIC", json!([]))?;
    assert!(see_validation::coverage::check(&corpus).is_empty());
    assert_eq!(see_validation::coverage::required_rules(&corpus).len(), 0);
    Ok(())
}

#[test]
fn rejects_gaps_duplicates_unknown_instructions_and_ambiguous_entries() -> Result<(), String> {
    let cases = [
        (
            json!({"kind":"pregunta","fields":{"id":"Q1","texto":"?"}}),
            "SEE-IR-COVERAGE",
        ),
        (
            json!({"kind":"cobertura","fields":{"id":"V1","regla":"LANG.OPS.ARITHMETIC#R1","instrucciones":["int.teleport"]}}),
            "SEE-IR-UNKNOWN",
        ),
        (
            json!({"kind":"cobertura","fields":{"id":"V1","regla":"LANG.OPS.ARITHMETIC#R1"}}),
            "SEE-IR-COVERAGE",
        ),
        (
            json!({"kind":"cobertura","fields":{"id":"V1","regla":"LANG.OPS.ARITHMETIC#R1","instrucciones":["int.add"],"sin_ri":"x"}}),
            "SEE-IR-COVERAGE",
        ),
        (
            json!({"kind":"cobertura","fields":{"id":"V1","regla":"LANG.OPS.ARITHMETIC#R2","sin_ri":"x"}}),
            "SEE-IR-COVERAGE",
        ),
        (
            json!({"kind":"instruccion","fields":{"id":"O2","nombre":"int.add","trampas":["unknownTrap"]}}),
            "SEE-DUPLICATE",
        ),
        (
            json!({"kind":"instruccion","fields":{"id":"O2","nombre":"int.sub","trampas":["unknownTrap"]}}),
            "SEE-IR-UNKNOWN",
        ),
    ];
    for (entry, expected) in cases {
        let found = errors(entry)?;
        assert!(
            found.iter().any(|error| error.starts_with(expected)),
            "{expected}: {found:?}"
        );
    }
    Ok(())
}
