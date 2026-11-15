#![forbid(unsafe_code)]

use crate::json_source::{append_array, replace_object_field};
use pseudolearn_runtime::MemoryError;

#[test]
fn appends_values_to_empty_and_populated_arrays() {
    assert_eq!(append_array("[]", "1").ok(), Some("[1]".to_owned()));
    assert_eq!(append_array("[1]", "2").ok(), Some("[1,2]".to_owned()));
}

#[test]
fn replaces_fields_without_normalizing_untouched_number_lexemes() {
    assert_eq!(
        replace_object_field("{\"first\":1e400,\"target\":2}", "target", "9").ok(),
        Some("{\"first\":1e400,\"target\":9}".to_owned())
    );
}

#[test]
fn appends_missing_fields_and_escapes_the_field_name() {
    assert_eq!(
        replace_object_field("{}", "quoted\"key", "true").ok(),
        Some("{\"quoted\\\"key\":true}".to_owned())
    );
    assert_eq!(
        replace_object_field("{\"first\":1}", "second", "2").ok(),
        Some("{\"first\":1,\"second\":2}".to_owned())
    );
}

#[test]
fn rejects_malformed_source_ranges() {
    assert_eq!(append_array("[1", "2"), Err(MemoryError::Internal));
    assert_eq!(
        replace_object_field("{\"key\" 1}", "key", "2"),
        Err(MemoryError::Internal)
    );
}
