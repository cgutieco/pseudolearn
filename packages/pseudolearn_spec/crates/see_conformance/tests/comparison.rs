use serde_json::json;

#[test]
fn preserves_output_bytes_and_diagnostic_multiplicity() {
    let expected = json!({"salida":"1\n","diagnosticos":[{"codigo":"expectedExpression","severidad":"error"}]});
    let actual =
        json!({"output":"1\n","diagnostics":[{"code":"expectedExpression","severity":"error"}]});
    assert!(see_conformance::comparison::compare(&expected, &actual).is_empty());
    let duplicate = json!({"output":"1\n","diagnostics":[{"code":"expectedExpression","severity":"error"},{"code":"expectedExpression","severity":"error"}]});
    assert!(!see_conformance::comparison::compare(&expected, &duplicate).is_empty());
    assert!(!see_conformance::comparison::compare(&json!({"salida":"1"}), &actual).is_empty());
}

#[test]
fn compares_spans_trees_termination_and_warning_severity() -> Result<(), String> {
    let span = json!({"start":{"line":2,"column":3},"end":{"line":2,"column":4}});
    let expected = json!({"arbol":"presente","fallo":{"codigo":"integerOverflow"},"diagnosticos":[{"codigo":"warning","severidad":"advertencia","tramo":span}]});
    let actual = json!({"tree":true,"termination":{"kind":"failed","code":"integerOverflow"},"diagnostics":[{"code":"warning","severity":"warning","span":span}]});
    assert!(see_conformance::comparison::compare(&expected, &actual).is_empty());
    let mut wrong = actual.clone();
    *wrong.get_mut("tree").ok_or("Missing tree")? = json!(false);
    assert!(!see_conformance::comparison::compare(&expected, &wrong).is_empty());
    wrong = actual;
    *wrong
        .get_mut("diagnostics")
        .and_then(|value| value.get_mut(0))
        .and_then(|value| value.get_mut("span"))
        .and_then(|value| value.get_mut("start"))
        .and_then(|value| value.get_mut("column"))
        .ok_or("Missing span")? = json!(4);
    assert!(!see_conformance::comparison::compare(&expected, &wrong).is_empty());
    assert!(!see_conformance::comparison::compare(&json!({"unknown":true}), &wrong).is_empty());
    Ok(())
}
