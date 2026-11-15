use crate::{MAXIMUM_PADDING_WIDTH, pad_left, pad_right};
use pseudolearn_runtime::MemoryError;

const ROOM: u64 = u64::MAX;

#[test]
fn pads_on_either_side() {
    assert_eq!(pad_left("7", 3, "0", ROOM), Ok("007".to_owned()));
    assert_eq!(pad_right("7", 3, ".", ROOM), Ok("7..".to_owned()));
}

#[test]
fn never_truncates_longer_text() {
    assert_eq!(pad_left("abcd", 2, "0", ROOM), Ok("abcd".to_owned()));
    assert_eq!(pad_right("abcd", 4, "0", ROOM), Ok("abcd".to_owned()));
}

#[test]
fn accepts_empty_text_and_zero_width() {
    assert_eq!(pad_left("", 2, "x", ROOM), Ok("xx".to_owned()));
    assert_eq!(pad_right("", 0, "x", ROOM), Ok(String::new()));
}

#[test]
fn counts_code_points_not_bytes() {
    assert_eq!(
        pad_left("\u{e9}\u{1f600}", 4, "-", ROOM),
        Ok("--\u{e9}\u{1f600}".to_owned())
    );
    assert_eq!(
        pad_right("a", 2, "\u{1f600}", ROOM),
        Ok("a\u{1f600}".to_owned())
    );
}

#[test]
fn rejects_fill_that_is_not_one_code_point() {
    assert_eq!(
        pad_left("a", 3, "", ROOM),
        Err(MemoryError::InvalidPaddingText)
    );
    assert_eq!(
        pad_right("a", 3, "ab", ROOM),
        Err(MemoryError::InvalidPaddingText)
    );
}

#[test]
fn rejects_negative_width_and_caps_huge_width() {
    assert_eq!(
        pad_left("a", -1, "0", ROOM),
        Err(MemoryError::PaddingWidthOutOfRange)
    );
    let beyond = i64::try_from(MAXIMUM_PADDING_WIDTH).unwrap_or(i64::MAX) + 1;
    assert_eq!(
        pad_right("a", beyond, "0", ROOM),
        Err(MemoryError::CellLimit)
    );
}

#[test]
fn accepts_result_exactly_at_the_point_budget() {
    assert_eq!(pad_left("a", 4, "0", 4), Ok("000a".to_owned()));
    assert_eq!(pad_right("a", 4, "0", 4), Ok("a000".to_owned()));
}

#[test]
fn rejects_result_one_point_over_the_budget() {
    assert_eq!(pad_left("a", 5, "0", 4), Err(MemoryError::CellLimit));
    assert_eq!(pad_right("a", 5, "0", 4), Err(MemoryError::CellLimit));
}

#[test]
fn rejects_long_text_beyond_the_budget_even_without_padding() {
    assert_eq!(pad_left("abcde", 2, "0", 4), Err(MemoryError::CellLimit));
}

#[test]
fn accepts_empty_result_with_zero_budget() {
    assert_eq!(pad_right("", 0, "x", 0), Ok(String::new()));
}

#[test]
fn rejects_widest_integer_width_before_building() {
    assert_eq!(
        pad_left("a", i64::MAX, "0", ROOM),
        Err(MemoryError::CellLimit)
    );
}
