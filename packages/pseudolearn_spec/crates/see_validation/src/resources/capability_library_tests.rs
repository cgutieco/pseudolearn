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
