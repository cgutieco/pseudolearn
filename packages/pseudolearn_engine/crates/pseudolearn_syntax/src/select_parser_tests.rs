use crate::NodeKind;
use pseudolearn_lexicon::Profile;
use pseudolearn_source::SourceText;

#[test]
fn select_headers_do_not_capture_an_ordinary_receive_named_call() {
    let source = SourceText::new("Algoritmo Main\nElegir\nRecibir first Desde queue:\nRecibir();\nRecibir second Desde queue:\nFinElegir\nFinAlgoritmo\n".to_owned());
    let (tree, diagnostics) = crate::parse_source(&source, Profile::Spanish);
    assert!(diagnostics.is_empty(), "{diagnostics:?}");
    assert_eq!(
        tree.nodes
            .iter()
            .filter(|node| node.kind == NodeKind::ReceiveBranch)
            .count(),
        2
    );
}

#[test]
fn a_select_close_is_required_and_a_single_branch_remains_analyzable() {
    let source = SourceText::new(
        "Algoritmo Main\nElegir\nRecibir first Desde queue:\nFinElegir\nFinAlgoritmo\n".to_owned(),
    );
    let (tree, diagnostics) = crate::parse_source(&source, Profile::Spanish);
    assert!(diagnostics.is_empty(), "{diagnostics:?}");
    assert_eq!(
        tree.nodes
            .iter()
            .filter(|node| node.kind == NodeKind::ReceiveBranch)
            .count(),
        1
    );
    let unclosed = SourceText::new(
        "Algoritmo Main\nElegir\nRecibir first Desde queue:\nFinAlgoritmo\n".to_owned(),
    );
    let (_, diagnostics) = crate::parse_source(&unclosed, Profile::Spanish);
    assert!(diagnostics.iter().any(|diagnostic| diagnostic.code
        == pseudolearn_diagnostics::DiagnosticCode::UnclosedSwitchStatement));
}
