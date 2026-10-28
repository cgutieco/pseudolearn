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
