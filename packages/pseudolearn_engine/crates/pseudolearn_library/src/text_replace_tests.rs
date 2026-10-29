use crate::{replace_all, trim_text};

#[test]
fn replaces_every_nonempty_match() {
    assert_eq!(replace_all("aba", "a", "x"), "xbx");
}

#[test]
fn preserves_text_when_search_is_empty() {
    assert_eq!(replace_all("text", "", "x"), "text");
}

#[test]
fn trims_only_ascii_whitespace() {
    assert_eq!(trim_text(" \ttext\r\n"), "text");
    assert_eq!(trim_text("\u{00a0}text\u{00a0}"), "\u{00a0}text\u{00a0}");
    assert_eq!(trim_text(" \t\r\n"), "");
}
