use pseudolearn_lexicon::Profile;
use pseudolearn_source::SourceText;
use pseudolearn_syntax::{NodeKind, TokenKind, parse_source, reprint_lossless};

#[test]
fn preserves_contextual_modifier_and_identifier_spelling() {
    let programs = [
        (
            "SubProceso Suspendible Worker()\nFinSubProceso\nAlgoritmo Main\nDefinir Suspendible Como Entero <- 1;\nEscribir Suspendible;\nFinAlgoritmo\n",
            "Suspendible",
            Profile::Spanish,
        ),
        (
            "subroutine suspendable Worker()\nendSubroutine\nalgorithm Main\ndefine suspendable as integer <- 1;\nwrite suspendable;\nendAlgorithm\n",
            "suspendable",
            Profile::English,
        ),
    ];
    for (program, lexeme, profile) in programs {
        let source = SourceText::new(program.to_owned());
        let (tree, diagnostics) = parse_source(&source, profile);
        assert!(diagnostics.is_empty(), "{diagnostics:?}");
        assert_eq!(
            tree.nodes
                .iter()
                .filter(|node| node.kind == NodeKind::SuspendibleModifier)
                .count(),
            1
        );
        assert!(
            tree.nodes
                .iter()
                .filter(|node| node.kind == NodeKind::Identifier)
                .any(|node| {
                    let token = usize::try_from(node.first_token).ok();
                    token.is_some_and(|token| {
                        tree.tokens.kind(token) == Some(TokenKind::Identifier)
                            && tree.tokens.text(source.as_str(), token) == Some(lexeme)
                    })
                })
        );
        assert_eq!(reprint_lossless(&source, &tree.tokens), program);
    }
}

#[test]
fn parses_a_function_with_a_return_variable() {
    let source = pseudolearn_source::SourceText::new(
        "Funcion r <- Doble(a Como Entero)\nDefinir r Como Entero;\nr <- a * 2;\nFinFuncion\nAlgoritmo P\nEscribir Doble(2);\nFinAlgoritmo\n"
            .to_owned(),
    );
    let (tree, diagnostics) =
        pseudolearn_syntax::parse_source(&source, pseudolearn_lexicon::Profile::Spanish);
    assert!(diagnostics.is_empty(), "{diagnostics:?}");
    assert!(
        (0..tree.node_count()).any(|index| tree
            .node(index)
            .is_some_and(|node| node.kind == pseudolearn_syntax::NodeKind::ReturnVariable))
    );
}

#[test]
fn a_return_variable_header_takes_no_return_type() {
    let source = pseudolearn_source::SourceText::new(
        "function r <- Twice(a as integer) as integer\nendSubroutine\n".to_owned(),
    );
    let (_, diagnostics) =
        pseudolearn_syntax::parse_source(&source, pseudolearn_lexicon::Profile::English);
    assert!(!diagnostics.is_empty());
}

#[test]
fn a_return_variable_without_a_function_name_is_rejected() {
    let source = pseudolearn_source::SourceText::new(
        "Funcion r <- (a Como Entero)\nFinFuncion\n".to_owned(),
    );
    let (_, diagnostics) =
        pseudolearn_syntax::parse_source(&source, pseudolearn_lexicon::Profile::Spanish);
    assert!(
        diagnostics
            .iter()
            .any(|diagnostic| diagnostic.code.as_str() == "expectedSubroutineName")
    );
}
