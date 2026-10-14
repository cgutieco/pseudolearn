mod contracts;
use serde_json::json;

fn case(operation: &str, expected: serde_json::Value) -> serde_json::Value {
    json!([{"kind":"caso","fields":{"id":"C1","regla":"R1","operacion":operation,"espera":expected}}])
}

fn errors(operation: &str, expected: serde_json::Value) -> Result<Vec<String>, String> {
    let corpus = contracts::corpus("IR.TEXT-FORMAT", case(operation, expected))?;
    let specification = corpus.first().ok_or("Missing specification")?;
    Ok(see_validation::expectations::check(specification))
}

#[test]
fn accepts_each_intermediate_representation_outcome_and_limit_kind() -> Result<(), String> {
    for outcome in [
        json!({"aceptada":true}),
        json!({"aceptada":false,"regla":"IR.WELL-FORMEDNESS#R2"}),
        json!({"reimpresion":"module {}\n"}),
    ] {
        assert!(errors("ir", json!({"ri":outcome}))?.is_empty());
    }
    for kind in ["sentencias", "tiempo"] {
        assert!(
            errors(
                "execute",
                json!({"terminacion":"limit_reached","limite":kind})
            )?
            .is_empty()
        );
    }
    Ok(())
}

#[test]
fn rejects_malformed_outcomes_and_inconsistent_limits() -> Result<(), String> {
    for outcome in [
        json!(null),
        json!({}),
        json!({"aceptada":true,"regla":"IR.WELL-FORMEDNESS#R1"}),
        json!({"aceptada":false}),
        json!({"aceptada":false,"regla":"LANG.X#R1"}),
        json!({"reimpresion":"x","aceptada":true}),
    ] {
        let found = errors("ir", json!({"ri":outcome}))?;
        assert!(
            found
                .iter()
                .any(|error| error.starts_with("SEE-IR-EXPECTATION")),
            "{found:?}"
        );
    }
    for expected in [
        json!({"terminacion":"limit_reached"}),
        json!({"terminacion":"limit_reached","limite":"micro_steps"}),
        json!({"terminacion":"completed","limite":"tiempo"}),
    ] {
        let found = errors("execute", expected)?;
        assert!(
            found
                .iter()
                .any(|error| error.starts_with("SEE-LIMIT-KIND")),
            "{found:?}"
        );
    }
    Ok(())
}
