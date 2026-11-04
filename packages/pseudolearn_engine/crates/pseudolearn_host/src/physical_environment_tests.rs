use crate::physical_environment::{environment_name_is_valid, variable_reply};
use serde_json::json;
use std::ffi::OsString;

#[test]
fn an_absent_variable_is_none() {
    assert_eq!(
        variable_reply(None),
        Ok(json!({"outcome":"committed","value":{"kind":"optional_text","value":null}}))
    );
}

#[test]
fn a_present_variable_keeps_empty_and_unicode_text() {
    for text in ["", "ñandú ✓", " con espacios "] {
        assert_eq!(
            variable_reply(Some(OsString::from(text))),
            Ok(json!({"outcome":"committed","value":{"kind":"optional_text","value":text}}))
        );
    }
}

#[cfg(unix)]
#[test]
fn a_value_that_is_not_utf8_is_an_invalid_utf8_error() {
    use std::os::unix::ffi::OsStringExt;
    let raw = OsString::from_vec(vec![0x66, 0xff, 0x6f]);
    let error = variable_reply(Some(raw)).err();
    assert_eq!(error.map(|found| found.code), Some("utf8_invalido"));
}

#[test]
fn names_with_equals_or_nul_or_nothing_are_invalid() {
    assert!(environment_name_is_valid("PATH"));
    assert!(!environment_name_is_valid(""));
    assert!(!environment_name_is_valid("A=B"));
    assert!(!environment_name_is_valid("A\0B"));
}
