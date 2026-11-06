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
fn rejects_negative_inverted_and_overflowing_ranges() {
    for (first, last) in [(-1, 0), (i64::MAX, 1), (0, i64::MAX), (3, 1), (0, 3)] {
        assert_eq!(
            text_substring("abc", first, last),
            Err(MemoryError::StringPositionOutOfRange)
        );
    }
}

#[test]
fn includes_both_positions_and_accepts_empty_ranges() {
    assert_eq!(text_substring("hola", 0, 1), Ok("ho".to_owned()));
    assert_eq!(text_substring("hola", 3, 3), Ok("a".to_owned()));
    assert_eq!(text_substring("hola", 2, 1), Ok(String::new()));
    assert_eq!(text_substring("abc", 3, 2), Ok(String::new()));
    assert_eq!(text_substring("", 0, -1), Ok(String::new()));
}
