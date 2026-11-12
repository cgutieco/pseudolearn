use pseudolearn_lexicon::Profile;
use pseudolearn_source::SourceText;
use pseudolearn_syntax::{NodeKind, parse_source, reprint_lossless};

#[test]
fn parses_prefix_await_without_losing_source_text() {
    let programs = [
        (
            "Algoritmo Main\nEscribir Aguardar ReadNow();\nFinAlgoritmo\n",
            Profile::Spanish,
        ),
        (
            "algorithm Main\nwrite await ReadNow();\nendAlgorithm\n",
            Profile::English,
        ),
    ];
    for (program, profile) in programs {
        let source = SourceText::new(program.to_owned());
        let (tree, diagnostics) = parse_source(&source, profile);
        assert!(diagnostics.is_empty(), "{diagnostics:?}");
        assert!(
            tree.nodes
                .iter()
                .any(|node| node.kind == NodeKind::AwaitExpression)
        );
        assert_eq!(reprint_lossless(&source, &tree.tokens), program);
    }
}

#[test]
fn parses_awaited_calls_as_statements() {
    let programs = [
        (
            "Algoritmo Main\nAguardar Work();\nFinAlgoritmo\n",
            Profile::Spanish,
        ),
        (
            "algorithm Main\nawait Work();\nendAlgorithm\n",
            Profile::English,
        ),
    ];
    for (program, profile) in programs {
        let source = SourceText::new(program.to_owned());
        let (tree, diagnostics) = parse_source(&source, profile);
        assert!(diagnostics.is_empty(), "{diagnostics:?}");
        assert!(
            tree.nodes
                .iter()
                .any(|node| node.kind == NodeKind::CallStatement)
        );
        assert_eq!(reprint_lossless(&source, &tree.tokens), program);
    }
}
