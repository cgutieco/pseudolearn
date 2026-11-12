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
fn unknown_host_keys_are_still_rejected() {
    for key in ["unknown_directive", "permissions", "x"] {
        let host = json!({ key: 1 });
        assert!(MemoryHostProvider::from_value(&host).is_err(), "{key}");
    }
}

#[test]
fn tape_alteration_directive_is_accepted_in_the_host_configuration() {
    let host = json!({ "files": {"a": "hola"}, "alterar_cinta": "truncar_entrada"});
    assert!(MemoryHostProvider::from_value(&host).is_ok());
}

#[test]
fn explicit_directories_are_accepted_and_invalid_ones_rejected() {
    let accepted = json!({ "directories": ["empty", "a/b"] });
    assert!(MemoryHostProvider::from_value(&accepted).is_ok());
    let empty_name = json!({ "directories": [""] });
    assert!(MemoryHostProvider::from_value(&empty_name).is_err());
    let nul_name = json!({ "directories": ["a\u{0}b"] });
    assert!(MemoryHostProvider::from_value(&nul_name).is_err());
    let wrong_type = json!({ "directories": "empty" });
    assert!(MemoryHostProvider::from_value(&wrong_type).is_err());
}
