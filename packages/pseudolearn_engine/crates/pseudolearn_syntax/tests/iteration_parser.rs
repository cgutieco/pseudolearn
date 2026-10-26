use pseudolearn_lexicon::Profile;
use pseudolearn_source::SourceText;
use pseudolearn_syntax::{NodeKind, parse_source};

#[test]
fn iteration_headers_consume_trivia_between_contextual_words() {
    for (profile, text) in [
        (
            Profile::English,
            "algorithm Main\ndefine values as vector<integer> <- vector();\nfor \t each element in values do\ndefer\nwrite element;\nendDefer\nbreak;\nendFor\nendAlgorithm\n",
        ),
        (
            Profile::Spanish,
            "Algoritmo Main\nDefinir values Como Vector<Entero> <- Vector();\nPara \t Cada element En values Hacer\nDiferir\nEscribir element;\nFinDiferir\nSalir;\nFinPara\nFinAlgoritmo\n",
        ),
    ] {
        let source = SourceText::new(text.to_owned());
        let (tree, diagnostics) = parse_source(&source, profile);
        assert!(diagnostics.is_empty(), "{diagnostics:?}");
        for kind in [
            NodeKind::ForEachLoop,
            NodeKind::IterationBindings,
            NodeKind::DeferStatement,
            NodeKind::BreakStatement,
        ] {
            assert_eq!(
                tree.nodes.iter().filter(|node| node.kind == kind).count(),
                1
            );
        }
    }
}

#[test]
fn missing_cleanup_closer_reports_the_structural_error() {
    let source = SourceText::new("algorithm Main\ndefer\nwrite 1;\nendAlgorithm\n".to_owned());
    let (_, diagnostics) = parse_source(&source, Profile::English);
    assert!(
        diagnostics
            .iter()
            .any(|diagnostic| diagnostic.code.as_str() == "unclosedDefer")
    );
}
