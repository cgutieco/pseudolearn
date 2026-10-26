use pseudolearn_lexicon::Profile;
use pseudolearn_source::SourceText;
use pseudolearn_syntax::{NodeKind, parse_source, reprint_lossless};

#[test]
fn interface_signatures_and_realizations_preserve_source() {
    let text = "interface Readable\nmethod readValue() as integer;\nendInterface\nclass Reader implements Readable\nmethod readValue() as integer\nreturn 7;\nendMethod\nendClass\nalgorithm Main\nendAlgorithm\n";
    let source = SourceText::new(text.to_owned());
    let (tree, diagnostics) = parse_source(&source, Profile::English);
    assert!(diagnostics.is_empty(), "{diagnostics:?}");
    assert!(
        tree.nodes
            .iter()
            .any(|node| node.kind == NodeKind::InterfaceUnit)
    );
    assert!(
        tree.nodes
            .iter()
            .any(|node| node.kind == NodeKind::Realization)
    );
    assert_eq!(reprint_lossless(&source, &tree.tokens), text);
}

#[test]
fn interface_names_remain_ordinary_outside_declaration_headers() {
    let source = SourceText::new(
        "algorithm Main\ndefine interface as integer <- 2;\nwrite interface;\nendAlgorithm\n"
            .to_owned(),
    );
    let (_, diagnostics) = parse_source(&source, Profile::English);
    assert!(diagnostics.is_empty(), "{diagnostics:?}");
}

#[test]
fn incomplete_interface_reports_its_opening() {
    let source = SourceText::new("interface Readable\n".to_owned());
    let (_, diagnostics) = parse_source(&source, Profile::English);
    let diagnostic = diagnostics
        .iter()
        .find(|diagnostic| diagnostic.code.as_str() == "unclosedInterface");
    assert!(diagnostic.is_some_and(|diagnostic| !diagnostic.related.is_empty()));
}
