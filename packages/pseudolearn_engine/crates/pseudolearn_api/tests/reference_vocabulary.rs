use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

fn call(operation: &str, arguments: &Value) -> Value {
    ApiSession::default().call(operation, arguments)
}

#[test]
fn builtins_follow_the_profile_lexemes_and_declare_their_signature() {
    let spanish = call("reference_vocabulary", &json!({"profile":"es"}));
    let english = call("reference_vocabulary", &json!({"profile":"en"}));
    let find = |response: &Value, identity: &str| {
        response
            .pointer("/value/builtins")
            .and_then(Value::as_array)
            .and_then(|entries| {
                entries
                    .iter()
                    .find(|entry| entry.get("identity") == Some(&json!(identity)))
                    .cloned()
            })
    };
    let root_es = find(&spanish, "squareRoot");
    let root_en = find(&english, "squareRoot");
    assert_eq!(
        root_es.as_ref().and_then(|entry| entry.get("parameters")),
        Some(&json!(["numeric"]))
    );
    assert_eq!(
        root_es.as_ref().and_then(|entry| entry.get("returns")),
        Some(&json!("real"))
    );
    assert_ne!(
        root_es.as_ref().and_then(|entry| entry.get("lexeme")),
        root_en.as_ref().and_then(|entry| entry.get("lexeme"))
    );
    assert_eq!(
        spanish
            .pointer("/value/builtins")
            .and_then(Value::as_array)
            .map(Vec::len),
        Some(18)
    );
}

#[test]
fn precedence_has_eight_levels_with_right_associative_unary_and_power() {
    let response = call("reference_vocabulary", &json!({"profile":"es"}));
    let levels = response
        .pointer("/value/precedence")
        .and_then(Value::as_array)
        .cloned()
        .unwrap_or_default();
    assert_eq!(levels.len(), 8);
    assert_eq!(
        levels
            .first()
            .and_then(|level| level.get("right_associative")),
        Some(&json!(true))
    );
    assert_eq!(
        levels
            .get(2)
            .and_then(|level| level.get("right_associative")),
        Some(&json!(false))
    );
}

#[test]
fn the_identifier_label_follows_the_profile() {
    let spanish = call("reference_vocabulary", &json!({"profile":"es"}));
    let english = call("reference_vocabulary", &json!({"profile":"en"}));
    assert_eq!(
        spanish.pointer("/value/identifier_label"),
        Some(&json!("identificador"))
    );
    assert_eq!(
        english.pointer("/value/identifier_label"),
        Some(&json!("identifier"))
    );
}

#[test]
fn unknown_profiles_are_rejected() {
    let response = call("reference_vocabulary", &json!({"profile":"fr"}));
    assert_eq!(response.pointer("/failure/family"), Some(&json!("usage")));
}

#[test]
fn diagnostic_templates_are_localised_and_carry_their_severity() {
    let spanish = call(
        "diagnostic_template",
        &json!({"code":"undeclaredVariable","locale":"es","strictness":"strict"}),
    );
    let english = call(
        "diagnostic_template",
        &json!({"code":"undeclaredVariable","locale":"en","strictness":"strict"}),
    );
    let template = |response: &Value| {
        response
            .pointer("/value/template")
            .and_then(Value::as_str)
            .map(str::to_owned)
    };
    assert!(template(&spanish).is_some_and(|text| text.contains('{')));
    assert_ne!(template(&spanish), template(&english));
    assert_eq!(spanish.pointer("/value/severity"), Some(&json!("error")));
}

#[test]
fn severity_follows_the_requested_strictness() {
    let strict = call(
        "diagnostic_template",
        &json!({"code":"incompatibleSwitchCaseType","locale":"es","strictness":"strict"}),
    );
    let flexible = call(
        "diagnostic_template",
        &json!({"code":"incompatibleSwitchCaseType","locale":"es","strictness":"flexible"}),
    );
    assert_eq!(strict.pointer("/value/severity"), Some(&json!("error")));
    assert_eq!(flexible.pointer("/value/severity"), Some(&json!("warning")));
    let invalid = call(
        "diagnostic_template",
        &json!({"code":"incompatibleSwitchCaseType","locale":"es","strictness":"lax"}),
    );
    assert_eq!(invalid.pointer("/failure/family"), Some(&json!("usage")));
}

#[test]
fn unknown_diagnostic_codes_are_rejected() {
    let response = call(
        "diagnostic_template",
        &json!({"code":"nope","locale":"es","strictness":"strict"}),
    );
    assert_eq!(response.pointer("/failure/family"), Some(&json!("usage")));
}
