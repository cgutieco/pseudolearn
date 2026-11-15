use crate::{replace_all, trim_text};
use pseudolearn_runtime::MemoryError;

const ROOM: u64 = u64::MAX;

#[test]
fn replaces_every_nonempty_match() {
    assert_eq!(replace_all("aba", "a", "x", ROOM), Ok("xbx".to_owned()));
}

#[test]
fn preserves_text_when_search_is_empty() {
    assert_eq!(replace_all("text", "", "x", ROOM), Ok("text".to_owned()));
}

#[test]
fn trims_only_ascii_whitespace() {
    assert_eq!(trim_text(" \ttext\r\n"), "text");
    assert_eq!(trim_text("\u{00a0}text\u{00a0}"), "\u{00a0}text\u{00a0}");
    assert_eq!(trim_text(" \t\r\n"), "");
}

#[test]
fn accepts_result_exactly_at_the_point_budget() {
    assert_eq!(replace_all("aa", "a", "xy", 4), Ok("xyxy".to_owned()));
}

#[test]
fn rejects_result_one_point_over_the_budget() {
    assert_eq!(replace_all("aa", "a", "xy", 3), Err(MemoryError::CellLimit));
}

#[test]
fn shrinking_replacement_fits_a_small_budget() {
    assert_eq!(replace_all("aaaa", "aa", "", 0), Ok(String::new()));
}

#[test]
fn counts_code_points_not_bytes() {
    assert_eq!(
        replace_all("a", "a", "\u{1f600}\u{1f600}", 2),
        Ok("\u{1f600}\u{1f600}".to_owned())
    );
}

#[test]
fn empty_text_has_no_matches_and_fits_zero_budget() {
    assert_eq!(replace_all("", "a", "xyz", 0), Ok(String::new()));
}

#[test]
fn rejects_exponential_growth_before_allocating() {
    let text = "a".repeat(1 << 16);
    let replacement = "b".repeat(1 << 16);
    assert_eq!(
        replace_all(&text, "a", &replacement, 1 << 24),
        Err(MemoryError::CellLimit)
    );
}
