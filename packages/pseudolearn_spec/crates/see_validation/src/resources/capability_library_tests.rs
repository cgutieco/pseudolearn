use serde_json::json;

#[test]
fn accepts_network_and_http_value_kinds() {
    let value = json!({"operations":[{
        "identity":"network_send",
        "family":"network",
        "receiver":"network",
        "es":"Enviar",
        "en":"send",
        "parameters":["http_request"],
        "result":"http_response",
        "effect":true,
        "fallible":true
    }]});
    assert!(super::capability_library::check(&value).is_ok());
}

#[test]
fn rejects_unknown_http_value_kinds() {
    let value = json!({"operations":[{
        "identity":"network_send",
        "family":"network",
        "receiver":"network",
        "es":"Enviar",
        "en":"send",
        "parameters":["unknown_request"],
        "result":"http_response",
        "effect":true,
        "fallible":true
    }]});
    assert_eq!(
        super::capability_library::check(&value),
        Err("Invalid capability operation signature".to_owned())
    );
}

fn upper_operation(alias: serde_json::Value) -> serde_json::Value {
    json!({"operations":[{
        "identity":"text_to_upper",
        "family":"text",
        "receiver":null,
        "es":"AMayusculas",
        "en":"toUpper",
        "parameters":["text"],
        "result":"text",
        "effect":false,
        "fallible":false,
        "alias":alias
    }]})
}

#[test]
fn accepts_bilingual_operation_aliases() {
    let value = upper_operation(json!({"es":["Mayusculas"],"en":[]}));
    assert!(super::capability_library::check(&value).is_ok());
}

#[test]
fn rejects_aliases_without_both_profiles_or_with_empty_names() {
    for alias in [
        json!({"es":["Mayusculas"]}),
        json!({"es":[""],"en":[]}),
        json!(["Mayusculas"]),
    ] {
        assert_eq!(
            super::capability_library::check(&upper_operation(alias)),
            Err("Invalid capability operation alias".to_owned())
        );
    }
}

#[test]
fn rejects_unknown_operation_fields_next_to_an_alias() {
    let mut value = upper_operation(json!({"es":[],"en":[]}));
    if let Some(operation) = value
        .pointer_mut("/operations/0")
        .and_then(serde_json::Value::as_object_mut)
    {
        operation.insert("lexemas".to_owned(), json!({}));
    }
    assert_eq!(
        super::capability_library::check(&value),
        Err("Invalid capability operation fields".to_owned())
    );
}
