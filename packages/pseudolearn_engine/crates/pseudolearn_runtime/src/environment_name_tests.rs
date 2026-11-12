use crate::{environment_name_is_sensitive, environment_name_is_valid};

#[test]
fn valid_names_reject_empty_equals_and_nul() {
    assert!(environment_name_is_valid("PATH"));
    assert!(environment_name_is_valid("a"));
    assert!(environment_name_is_valid("ñandú"));
    assert!(!environment_name_is_valid(""));
    assert!(!environment_name_is_valid("A=B"));
    assert!(!environment_name_is_valid("A\0B"));
}

#[test]
fn sensitive_names_end_in_a_secret_word_ignoring_ascii_case() {
    for name in [
        "API_KEY",
        "token",
        "Db_Password",
        "x_SECRET",
        "MYTOKEN",
        "key",
    ] {
        assert!(environment_name_is_sensitive(name), "{name}");
    }
}

#[test]
fn ordinary_names_are_not_sensitive() {
    for name in [
        "PATH",
        "HOME",
        "KEYBOARD",
        "TOKEN_COUNT",
        "",
        "secretos",
        "ke",
    ] {
        assert!(!environment_name_is_sensitive(name), "{name}");
    }
}
