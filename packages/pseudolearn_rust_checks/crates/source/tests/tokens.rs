#[test]
fn ignores_comment_markers_inside_literals() {
    assert!(
        pseudolearn_check_source::tokens::comment_lines(
            "fn execute() { let text = r#\"// /* */\"#; }"
        )
        .is_empty()
    );
}

#[test]
fn rejects_line_block_and_documentation_comments() {
    let lines =
        pseudolearn_check_source::tokens::comment_lines("// first\n/* second */\n/// third\n");
    assert_eq!(lines, vec![1, 2, 3]);
}

#[test]
fn accepts_empty_source() {
    assert!(pseudolearn_check_source::tokens::comment_lines("").is_empty());
}
