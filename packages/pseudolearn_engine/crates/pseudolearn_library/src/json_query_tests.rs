use crate::json_build::{with_element, with_field};
use crate::json_query::{as_integer, as_real, element, field, keys, kind};
use pseudolearn_runtime::{HostValue, MemoryError};

#[test]
fn extracts_kinds_values_and_ordered_keys() {
    assert_eq!(kind("null"), Ok(HostValue::JsonKind(0)));
    assert_eq!(as_integer("-0"), Ok(HostValue::OptionalInteger(Some(0))));
    assert_eq!(
        keys(r#"{"b":1,"a":2}"#),
        Ok(HostValue::TextList(vec!["b".to_owned(), "a".to_owned()]))
    );
}

#[test]
fn returns_absence_for_mismatched_or_unrepresentable_values() {
    assert_eq!(
        as_integer("9223372036854775808"),
        Ok(HostValue::OptionalInteger(None))
    );
    assert_eq!(as_real("1e400"), Ok(HostValue::OptionalReal(None)));
    assert_eq!(field("[]", "x"), Ok(HostValue::OptionalJsonValue(None)));
    assert_eq!(element("{}", 0), Ok(HostValue::OptionalJsonValue(None)));
}

#[test]
fn updates_existing_fields_and_appends_array_elements() {
    assert_eq!(
        with_field(r#"{"a":1,"b":2,"c":3}"#, "b", "9"),
        Ok(HostValue::JsonValue(r#"{"a":1,"b":9,"c":3}"#.to_owned()))
    );
    assert_eq!(
        with_field(r#"{"original":1e400,"target":2}"#, "target", "9"),
        Ok(HostValue::JsonValue(
            r#"{"original":1e400,"target":9}"#.to_owned()
        ))
    );
    assert_eq!(
        with_element("[1]", "2"),
        Ok(HostValue::JsonValue("[1,2]".to_owned()))
    );
    assert_eq!(
        with_element("[1e400]", "0"),
        Ok(HostValue::JsonValue("[1e400,0]".to_owned()))
    );
}

#[test]
fn rejects_container_updates_for_the_wrong_json_kind() {
    assert_eq!(
        with_element("{}", "null"),
        Err(MemoryError::JsonKindMismatch)
    );
    assert_eq!(
        with_field("[]", "x", "null"),
        Err(MemoryError::JsonKindMismatch)
    );
}
