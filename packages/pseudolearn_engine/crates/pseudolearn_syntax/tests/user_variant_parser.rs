use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::Profile;
use pseudolearn_source::SourceText;
use pseudolearn_syntax::{NodeKind, SyntaxTree, parse_source, reprint_lossless};

fn parse(text: &str, profile: Profile) -> (SyntaxTree, Vec<DiagnosticCode>) {
    let source = SourceText::new(text.to_owned());
    let (tree, diagnostics) = parse_source(&source, profile);
    assert_eq!(reprint_lossless(&source, &tree.tokens), text);
    (
        tree,
        diagnostics
            .iter()
            .map(|diagnostic| diagnostic.code)
            .collect(),
    )
}

fn count(tree: &SyntaxTree, kind: NodeKind) -> usize {
    tree.nodes.iter().filter(|node| node.kind == kind).count()
}

#[test]
fn a_variant_declares_alternatives_with_and_without_fields() {
    let text = "variant Shape\ncase Circle(radius as integer)\ncase Rectangle(width as integer, height as integer)\ncase Dot\nendVariant\nalgorithm P\nendAlgorithm\n";
    let (tree, errors) = parse(text, Profile::English);
    assert!(errors.is_empty(), "{errors:?}");
    assert_eq!(count(&tree, NodeKind::VariantUnit), 1);
    assert_eq!(count(&tree, NodeKind::VariantAlternative), 3);
    assert_eq!(count(&tree, NodeKind::AlternativeField), 3);
}

#[test]
fn a_generic_variant_and_the_spanish_profile_use_their_own_words() {
    let (tree, errors) = parse(
        "Variante Arbol<T>\nAlternativa Hoja(valor Como T)\nAlternativa Vacio\nFinVariante\nAlgoritmo P\nFinAlgoritmo\n",
        Profile::Spanish,
    );
    assert!(errors.is_empty(), "{errors:?}");
    assert_eq!(count(&tree, NodeKind::TypeParameters), 1);
    assert_eq!(count(&tree, NodeKind::VariantAlternative), 2);
}

#[test]
fn the_variant_words_remain_ordinary_names_outside_a_unit_header() {
    let text = "algorithm P\ndefine variant as integer <- 1;\ndefine case as integer <- 2;\nwrite variant + case;\nendAlgorithm\n";
    let (tree, errors) = parse(text, Profile::English);
    assert!(errors.is_empty(), "{errors:?}");
    assert_eq!(count(&tree, NodeKind::VariantUnit), 0);
}

#[test]
fn malformed_variants_recover_with_their_specific_diagnostics() {
    let (_, unclosed) = parse(
        "variant Shape\ncase Dot\nalgorithm P\nendAlgorithm\n",
        Profile::English,
    );
    assert_eq!(unclosed, vec![DiagnosticCode::UnclosedVariant]);
    let (_, stray) = parse(
        "variant Shape\ndefine x as integer;\nendVariant\nalgorithm P\nendAlgorithm\n",
        Profile::English,
    );
    assert_eq!(stray, vec![DiagnosticCode::ExpectedVariantAlternative]);
    for text in [
        "variant Shape\ncase Circle(radius integer)\nendVariant\nalgorithm P\nendAlgorithm\n",
        "variant Shape\ncase Circle(radius as integer\nendVariant\nalgorithm P\nendAlgorithm\n",
        "variant Shape<\ncase Dot\nendVariant\nalgorithm P\nendAlgorithm\n",
        "variant Empty\nendVariant\nalgorithm P\nendAlgorithm\n",
    ] {
        let (tree, _) = parse(text, Profile::English);
        assert!(!tree.nodes.is_empty(), "{text}");
    }
}
