use crate::{to_lower_text, to_upper_text};

#[test]
fn converts_ascii_in_both_directions() {
    assert_eq!(to_upper_text("Hello, World 42"), "HELLO, WORLD 42");
    assert_eq!(to_lower_text("Hello, World 42"), "hello, world 42");
}

#[test]
fn keeps_empty_and_already_converted_text() {
    assert_eq!(to_upper_text(""), "");
    assert_eq!(to_lower_text(""), "");
    assert_eq!(to_upper_text("ABC"), "ABC");
    assert_eq!(to_lower_text("abc"), "abc");
}

#[test]
fn converts_accented_letters() {
    assert_eq!(to_upper_text("\u{e9}"), "\u{c9}");
    assert_eq!(to_lower_text("\u{c9}"), "\u{e9}");
}

#[test]
fn expands_sharp_s_to_two_letters() {
    assert_eq!(to_upper_text("\u{df}"), "SS");
}

#[test]
fn maps_dotted_capital_i_to_i_with_combining_dot() {
    assert_eq!(to_lower_text("\u{130}"), "i\u{307}");
}

#[test]
fn uses_final_sigma_only_at_word_end() {
    assert_eq!(to_lower_text("\u{391}\u{3a3}"), "\u{3b1}\u{3c2}");
    assert_eq!(
        to_lower_text("\u{391}\u{3a3}\u{391}"),
        "\u{3b1}\u{3c3}\u{3b1}"
    );
}

#[test]
fn maps_digraph_letters() {
    assert_eq!(to_upper_text("\u{1c6}"), "\u{1c4}");
}

#[test]
fn leaves_emoji_and_combining_marks_unnormalized() {
    assert_eq!(to_upper_text("\u{1f600}"), "\u{1f600}");
    assert_eq!(to_upper_text("e\u{301}"), "E\u{301}");
}
