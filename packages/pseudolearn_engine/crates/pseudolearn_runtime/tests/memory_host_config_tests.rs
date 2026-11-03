use pseudolearn_runtime::MemoryHostProvider;
use serde_json::json;

#[test]
fn cancellation_directive_is_accepted_in_the_host_configuration() {
    let host = json!({ "files": {"a": "hola"}, "cancel_on_awaiting_effect": 3});
    assert!(MemoryHostProvider::from_value(&host).is_ok());
}

#[test]
fn an_empty_host_configuration_needs_no_authority_declaration() {
    let host = json!({});
    assert!(MemoryHostProvider::from_value(&host).is_ok());
}

#[test]
fn retired_authority_keys_are_rejected_by_the_test_host() {
    for key in [
        "permissions",
        "requested_permissions",
        "network_origins",
        "local_origins",
    ] {
        let host = json!({ key: [] });
        assert!(MemoryHostProvider::from_value(&host).is_err(), "{key}");
    }
}

#[test]
fn unknown_host_keys_are_still_rejected() {
    let host = json!({ "unknown_directive": 1});
    assert!(MemoryHostProvider::from_value(&host).is_err());
}

#[test]
fn tape_alteration_directive_is_accepted_in_the_host_configuration() {
    let host = json!({ "files": {"a": "hola"}, "alterar_cinta": "truncar_entrada"});
    assert!(MemoryHostProvider::from_value(&host).is_ok());
}
