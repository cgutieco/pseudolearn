#![forbid(unsafe_code)]

use pseudolearn_runtime::{DEFAULT_MAX_TAPE_BYTES, SecretHandle, TapeBudget};

#[test]
fn secret_handle_formatting_and_parsing() {
    let handle = SecretHandle::new("key_1".to_owned(), "hmac_abc".to_owned());
    let formatted = handle.to_reference_string();
    assert_eq!(formatted, "secret:key_1:hmac_abc");
    let parsed = SecretHandle::parse_reference(&formatted);
    assert_eq!(parsed, Some(handle));
}

#[test]
fn secret_handle_invalid_parsing() {
    assert_eq!(SecretHandle::parse_reference("not_secret:k:h"), None);
    assert_eq!(SecretHandle::parse_reference("secret:only_one"), None);
}

#[test]
fn tape_budget_admission_and_saturation() {
    let mut budget = TapeBudget::new(100);
    assert!(budget.can_admit(50));
    budget.record_admitted(50);
    assert_eq!(budget.current_bytes, 50);
    assert!(budget.can_admit(50));
    assert!(!budget.can_admit(51));
    budget.record_admitted(50);
    assert!(!budget.can_admit(1));
}

#[test]
fn tape_budget_default_is_sixteen_mebibytes() {
    assert_eq!(DEFAULT_MAX_TAPE_BYTES, 16 * 1024 * 1024);
}

#[test]
fn secret_authentication_binds_value_and_key() -> Result<(), String> {
    let handle = SecretHandle::authenticate("primary".to_owned(), b"key", b"private-value")
        .map_err(|error| format!("{error:?}"))?;
    assert!(handle.verifies(b"key", b"private-value"));
    assert!(!handle.verifies(b"other-key", b"private-value"));
    assert!(!handle.verifies(b"key", b"modified"));
    assert!(!handle.to_reference_string().contains("private-value"));
    Ok(())
}
