#![forbid(unsafe_code)]

use pseudolearn_runtime::{DEFAULT_MAX_TAPE_BYTES, SecretHandle, TapeBudget};

#[test]
fn secret_reference_has_the_documented_shape() -> Result<(), String> {
    let handle = SecretHandle::authenticate("primary".to_owned(), b"key", b"private-value")
        .map_err(|error| format!("{error:?}"))?;
    let reference = handle.to_reference_string();
    let parts: Vec<&str> = reference.split(':').collect();
    assert_eq!(parts.len(), 3);
    assert_eq!(parts.first(), Some(&"secret"));
    assert_eq!(parts.get(1), Some(&"primary"));
    let digest = parts.get(2).copied().unwrap_or_default();
    assert_eq!(digest.len(), 64);
    assert!(digest.bytes().all(|octet| octet.is_ascii_hexdigit()));
    Ok(())
}

#[test]
fn secret_authentication_binds_value_and_key() -> Result<(), String> {
    let authenticate = |key: &[u8], value: &[u8]| {
        SecretHandle::authenticate("primary".to_owned(), key, value)
            .map(|handle| handle.value_hmac)
            .map_err(|error| format!("{error:?}"))
    };
    let base = authenticate(b"key", b"private-value")?;
    assert_eq!(base, authenticate(b"key", b"private-value")?);
    assert_ne!(base, authenticate(b"other-key", b"private-value")?);
    assert_ne!(base, authenticate(b"key", b"modified")?);
    Ok(())
}

#[test]
fn secret_reference_never_contains_the_value() -> Result<(), String> {
    let handle = SecretHandle::authenticate("primary".to_owned(), b"key", b"private-value")
        .map_err(|error| format!("{error:?}"))?;
    assert!(!handle.to_reference_string().contains("private-value"));
    Ok(())
}

#[test]
fn empty_value_and_empty_key_still_authenticate_deterministically() -> Result<(), String> {
    let first = SecretHandle::authenticate("k".to_owned(), b"key", b"")
        .map_err(|error| format!("{error:?}"))?;
    let second = SecretHandle::authenticate("k".to_owned(), b"key", b"")
        .map_err(|error| format!("{error:?}"))?;
    assert_eq!(first, second);
    Ok(())
}

#[test]
fn tape_budget_starts_empty_and_defaults_to_sixteen_mebibytes() {
    let budget = TapeBudget::new(DEFAULT_MAX_TAPE_BYTES);
    assert_eq!(budget.current_bytes, 0);
    assert_eq!(DEFAULT_MAX_TAPE_BYTES, 16 * 1024 * 1024);
}
