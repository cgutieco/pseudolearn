use crate::{text_contains, text_ends_with, text_position, text_starts_with, text_substring};
use pseudolearn_runtime::MemoryError;

#[test]
fn searches_and_slices_by_unicode_scalar() {
    assert_eq!(text_substring("a😀b", 1, 1), Ok("😀".to_owned()));
    assert_eq!(text_position("a😀b", "b"), Some(2));
    assert!(text_contains("a😀b", ""));
    assert!(text_starts_with("text", ""));
    assert!(text_ends_with("text", ""));
}

#[test]
fn rejects_negative_and_overflowing_ranges() {
    assert_eq!(
        text_substring("abc", -1, 1),
        Err(MemoryError::StringPositionOutOfRange)
    );
    assert_eq!(
        text_substring("abc", i64::MAX, 1),
        Err(MemoryError::StringPositionOutOfRange)
    );
}

#[test]
fn accepts_zero_width_suffix() {
    assert_eq!(text_substring("abc", 3, 0), Ok(String::new()));
}
