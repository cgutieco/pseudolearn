use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::Profile;
use pseudolearn_source::SourceText;
use pseudolearn_syntax::{TokenKind, parse_source, reprint_lossless};

#[test]
fn accepts_normalized_spanish_identifiers_and_preserves_original_ranges() -> Result<(), String> {
    let program =
        "Algoritmo P\nDefinir año Como Entero;\nan\u{0303}o <- 5;\nEscribir año;\nFinAlgoritmo\n";
    let source = SourceText::new(program.to_owned());
    let (tree, diagnostics) = parse_source(&source, Profile::Spanish);
    assert!(diagnostics.is_empty());
    assert_eq!(reprint_lossless(&source, &tree.tokens), program);
    let composed = (0..tree.tokens.token_count())
        .find(|index| {
            tree.tokens.kind(*index) == Some(TokenKind::Identifier)
                && tree.tokens.text(source.as_str(), *index) == Some("año")
        })
        .ok_or("Missing composed identifier")?;
    let decomposed = (0..tree.tokens.token_count())
        .find(|index| {
            tree.tokens.kind(*index) == Some(TokenKind::Identifier)
                && tree.tokens.text(source.as_str(), *index) == Some("an\u{0303}o")
        })
        .ok_or("Missing decomposed identifier")?;
    assert_eq!(tree.tokens.span(composed).map(|span| span.start), Some(20));
    assert_eq!(
        tree.tokens.span(decomposed).map(|span| span.start),
        Some(38)
    );
    Ok(())
}

#[test]
fn rejects_letters_outside_the_alphabet_and_unattached_marks() {
    let source = SourceText::new(
        "Algoritmo P\nEscribir ç;\nEscribir a\u{0303};\nEscribir \u{0301};\nFinAlgoritmo\n"
            .to_owned(),
    );
    let (tree, diagnostics) = parse_source(&source, Profile::Spanish);
    assert_eq!(
        diagnostics
            .iter()
            .map(|diagnostic| diagnostic.code)
            .collect::<Vec<_>>(),
        [
            DiagnosticCode::UnrecognizedCharacter,
            DiagnosticCode::UnrecognizedCharacter,
            DiagnosticCode::UnrecognizedCharacter
        ]
    );
    for invalid in ["ç", "a\u{0303}", "\u{0301}"] {
        assert!((0..tree.tokens.token_count()).any(|index| {
            tree.tokens.kind(index) == Some(TokenKind::InvalidCharacter)
                && tree.tokens.text(source.as_str(), index) == Some(invalid)
        }));
    }
}
