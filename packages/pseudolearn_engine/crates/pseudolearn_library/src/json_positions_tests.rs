use crate::json_positions::{code_point_position, end_of_text};

#[test]
fn places_the_end_of_text_after_its_last_character() {
    assert_eq!(end_of_text(""), (1, 1));
    assert_eq!(end_of_text("{\"nombre\": \"Ana\""), (1, 17));
    assert_eq!(end_of_text("[\n"), (2, 1));
    assert_eq!(end_of_text("[\n  "), (2, 3));
}

#[test]
fn counts_the_end_of_text_in_code_points() {
    assert_eq!(end_of_text("[\"ññ\""), (1, 6));
    assert_eq!(end_of_text("😀"), (1, 2));
}

#[test]
fn converts_byte_columns_to_code_point_columns() {
    assert_eq!(code_point_position("[\"ñ\",x]", 1, 7), (1, 6));
    assert_eq!(code_point_position("[\n  1,\n    x\n]", 3, 5), (3, 5));
    assert_eq!(code_point_position("x", 1, 1), (1, 1));
}

#[test]
fn clamps_columns_and_lines_outside_the_text() {
    assert_eq!(code_point_position("ab", 1, 0), (1, 1));
    assert_eq!(code_point_position("ab", 1, 99), (1, 3));
    assert_eq!(code_point_position("ab", 0, 1), (1, 1));
    assert_eq!(code_point_position("ab", 5, 2), (5, 1));
    assert_eq!(code_point_position("ñ", 1, 2), (1, 1));
}
