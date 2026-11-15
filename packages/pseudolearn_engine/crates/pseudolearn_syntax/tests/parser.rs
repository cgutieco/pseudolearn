use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::Profile;
use pseudolearn_source::SourceText;
use pseudolearn_syntax::{parse_source, reprint_lossless};

#[test]
fn rejects_excessive_nesting_without_cascading_closures() {
    for depth in [256, 257, 10000] {
        let program = format!(
            "algorithm Main\nwrite {}1{};\nendAlgorithm\n",
            "(".repeat(depth),
            ")".repeat(depth)
        );
        let source = SourceText::new(program);
        let (tree, diagnostics) = parse_source(&source, Profile::English);
        assert_eq!(reprint_lossless(&source, &tree.tokens), source.as_str());
        if depth == 256 {
            assert!(diagnostics.is_empty(), "{diagnostics:?}");
        } else {
            assert_eq!(diagnostics.len(), 1, "{diagnostics:?}");
            assert_eq!(
                diagnostics.first().map(|diagnostic| diagnostic.code),
                Some(DiagnosticCode::AnalysisNestingLimitExceeded)
            );
        }
    }
}

#[test]
fn preserves_nested_spans_and_direct_child_ranges() {
    let source = SourceText::new(
        "algorithm Main\nif true then\nwrite 1 + 2;\nendIf\nendAlgorithm\n".to_owned(),
    );
    let (tree, diagnostics) = parse_source(&source, Profile::English);
    assert!(diagnostics.is_empty(), "{diagnostics:?}");
    for index in 0..tree.nodes.len() {
        let parent = tree.span_for_node(index).unwrap_or_default();
        for child in tree.child_indices(index) {
            assert!(*child < index);
            let span = tree.span_for_node(*child).unwrap_or_default();
            assert!(span.start >= parent.start && span.ending <= parent.ending);
        }
    }
}
