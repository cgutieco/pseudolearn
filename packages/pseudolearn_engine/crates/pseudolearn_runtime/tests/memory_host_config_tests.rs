use pseudolearn_runtime::MemoryHostProvider;
use serde_json::json;

#[test]
fn cancellation_directive_is_accepted_in_the_host_configuration() {
    let host = json!({"permissions": ["archivos_lectura"], "files": {"a": "hola"}, "cancel_on_awaiting_effect": 3});
    assert!(MemoryHostProvider::from_value(&host).is_ok());
}

#[test]
fn unknown_host_keys_are_still_rejected() {
    let host = json!({"permissions": [], "unknown_directive": 1});
    assert!(MemoryHostProvider::from_value(&host).is_err());
}
