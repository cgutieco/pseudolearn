use crate::{MAXIMUM_PADDING_WIDTH, pad_left, pad_right};
use pseudolearn_runtime::MemoryError;

#[test]
fn pads_on_either_side() {
    assert_eq!(pad_left("7", 3, "0"), Ok("007".to_owned()));
    assert_eq!(pad_right("7", 3, "."), Ok("7..".to_owned()));
}

#[test]
fn never_truncates_longer_text() {
    assert_eq!(pad_left("abcd", 2, "0"), Ok("abcd".to_owned()));
    assert_eq!(pad_right("abcd", 4, "0"), Ok("abcd".to_owned()));
}

#[test]
fn accepts_empty_text_and_zero_width() {
    assert_eq!(pad_left("", 2, "x"), Ok("xx".to_owned()));
    assert_eq!(pad_right("", 0, "x"), Ok(String::new()));
}

#[test]
fn counts_code_points_not_bytes() {
    assert_eq!(
        pad_left("\u{e9}\u{1f600}", 4, "-"),
        Ok("--\u{e9}\u{1f600}".to_owned())
    );
    assert_eq!(pad_right("a", 2, "\u{1f600}"), Ok("a\u{1f600}".to_owned()));
}

#[test]
fn rejects_fill_that_is_not_one_code_point() {
    assert_eq!(pad_left("a", 3, ""), Err(MemoryError::InvalidPaddingText));
    assert_eq!(
        pad_right("a", 3, "ab"),
        Err(MemoryError::InvalidPaddingText)
    );
}

#[test]
fn rejects_negative_width_and_caps_huge_width() {
    assert_eq!(
        pad_left("a", -1, "0"),
        Err(MemoryError::PaddingWidthOutOfRange)
    );
    let beyond = i64::try_from(MAXIMUM_PADDING_WIDTH).unwrap_or(i64::MAX) + 1;
    assert_eq!(pad_right("a", beyond, "0"), Err(MemoryError::CellLimit));
}
