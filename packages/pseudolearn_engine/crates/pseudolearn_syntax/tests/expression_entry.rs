use pseudolearn_lexicon::Profile;
use pseudolearn_source::SourceText;
use pseudolearn_syntax::expression_entry::parse_expression_source;

#[test]
fn parses_an_expression_without_a_program_wrapper() {
    let source = SourceText::new("answer + 2 * 3".to_owned());
    let (tree, diagnostics) = parse_expression_source(&source, Profile::Spanish);
    assert!(diagnostics.is_empty());
    assert!(!tree.has_errors);
    assert!(tree.node_count() > 1);
}

#[test]
fn rejects_empty_input_and_trailing_tokens() {
    for input in ["", "42 7", "42;", "42\nalgorithm P"] {
        let source = SourceText::new(input.to_owned());
        let (tree, diagnostics) = parse_expression_source(&source, Profile::English);
        assert!(tree.has_errors, "{input}");
        assert!(!diagnostics.is_empty(), "{input}");
    }
}
