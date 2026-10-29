use crate::{join_text, split_text};
use pseudolearn_runtime::MemoryError;

#[test]
fn splits_without_losing_empty_parts() {
    let parts = split_text("a,,b", ",");
    assert_eq!(
        parts,
        Ok(vec!["a".to_owned(), String::new(), "b".to_owned()])
    );
}

#[test]
fn keeps_empty_text_and_joins_empty_vectors() {
    assert_eq!(split_text("", ","), Ok(vec![String::new()]));
    assert_eq!(join_text(&[], ","), "");
}

#[test]
fn rejects_empty_separator() {
    assert_eq!(split_text("abc", ""), Err(MemoryError::EmptySeparator));
}
