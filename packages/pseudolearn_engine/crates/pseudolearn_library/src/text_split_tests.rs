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
    assert_eq!(join_text(&[], ",", 0), Ok(String::new()));
}

#[test]
fn rejects_empty_separator() {
    assert_eq!(split_text("abc", ""), Err(MemoryError::EmptySeparator));
}

#[test]
fn joins_exactly_at_the_point_budget() {
    let parts = ["ab".to_owned(), "cd".to_owned()];
    assert_eq!(join_text(&parts, "-", 5), Ok("ab-cd".to_owned()));
}

#[test]
fn rejects_join_one_point_over_the_budget() {
    let parts = ["ab".to_owned(), "cd".to_owned()];
    assert_eq!(join_text(&parts, "-", 4), Err(MemoryError::CellLimit));
}

#[test]
fn rejects_separators_alone_beyond_the_budget() {
    let parts = vec![String::new(); 4];
    assert_eq!(join_text(&parts, "xy", 5), Err(MemoryError::CellLimit));
    assert_eq!(join_text(&parts, "xy", 6), Ok("xyxyxy".to_owned()));
}

#[test]
fn rejects_separator_multiplication_overflow() {
    let parts = vec![String::new(); 3];
    let separator = "x".repeat(1 << 10);
    assert_eq!(
        join_text(&parts, &separator, 100),
        Err(MemoryError::CellLimit)
    );
}
