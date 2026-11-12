use pseudolearn_lexicon::Profile;
use pseudolearn_source::SourceText;
use pseudolearn_syntax::{NodeKind, parse_source, reprint_lossless};

#[test]
fn nested_types_and_patterns_preserve_the_original_source() {
    let source = SourceText::new("algorithm Main\ndefine outcome as optional<result<integer, string>> <- none;\nswitch outcome do\nnone: write 0;\nsome(value): discard value;\nendSwitch\nendAlgorithm\n".to_owned());
    let (tree, diagnostics) = parse_source(&source, Profile::English);
    assert!(diagnostics.is_empty(), "{diagnostics:?}");
    assert_eq!(reprint_lossless(&source, &tree.tokens), source.as_str());
    assert_eq!(
        tree.nodes
            .iter()
            .filter(|node| node.kind == NodeKind::VariantPattern)
            .count(),
        2
    );
}

#[test]
fn incomplete_type_arguments_and_patterns_recover_without_panicking() {
    for statement in [
        "define value as result<integer> <- none;",
        "define value as optional<> <- none;",
        "switch none do\nsome(): write 1;\nendSwitch",
    ] {
        let source = SourceText::new(format!("algorithm Main\n{statement}\nendAlgorithm\n"));
        let (tree, diagnostics) = parse_source(&source, Profile::English);
        assert!(!diagnostics.is_empty());
        assert_eq!(reprint_lossless(&source, &tree.tokens), source.as_str());
    }
}
