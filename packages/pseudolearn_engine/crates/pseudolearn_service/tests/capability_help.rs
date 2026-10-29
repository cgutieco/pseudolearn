use pseudolearn_lexicon::Profile;
use pseudolearn_service::marked_text::split_cursor;
use pseudolearn_service::{DocumentSession, HelpQueryOutcome, resolve_help_at_position};

fn resolve(marked: &str, profile: Profile) -> Option<HelpQueryOutcome> {
    let (source, position) = split_cursor(marked);
    let document = DocumentSession::new(source, profile, true);
    resolve_help_at_position(&document, position)
}

#[test]
fn capability_type_words_resolve_to_their_token_identity_in_both_profiles() -> Result<(), String> {
    let cases = [
        (
            "Algoritmo P\n  Definir c Como Rel|oj;\nFinAlgoritmo\n",
            Profile::Spanish,
            "clockCapabilityType",
        ),
        (
            "algorithm P\n  define c as Clo|ck;\nendAlgorithm\n",
            Profile::English,
            "clockCapabilityType",
        ),
        (
            "Algoritmo P\n  Definir d Como Directorio|Cap;\nFinAlgoritmo\n",
            Profile::Spanish,
            "directoryCapabilityType",
        ),
        (
            "algorithm P\n  define f as File|Cap;\nendAlgorithm\n",
            Profile::English,
            "fileCapabilityType",
        ),
    ];
    for (marked, profile, expected) in cases {
        let outcome = resolve(marked, profile).ok_or("missing resolution")?;
        assert_eq!(
            outcome.token_identity.as_deref(),
            Some(expected),
            "{marked}"
        );
    }
    Ok(())
}

#[test]
fn bytes_and_io_error_resolve_to_their_token_identity() -> Result<(), String> {
    let bytes = resolve(
        "Algoritmo P\n  Definir b Como Byt|es;\nFinAlgoritmo\n",
        Profile::Spanish,
    )
    .ok_or("missing bytes resolution")?;
    assert_eq!(bytes.token_identity.as_deref(), Some("bytesType"));
    let error = resolve(
        "algorithm P\n  define e as Io|Error;\nendAlgorithm\n",
        Profile::English,
    )
    .ok_or("missing error resolution")?;
    assert_eq!(error.token_identity.as_deref(), Some("ioErrorType"));
    Ok(())
}

#[test]
fn a_plain_identifier_does_not_resolve_to_a_capability() {
    let outcome = resolve(
        "Algoritmo P\n  Definir reloj_local Como Ent|ero;\nFinAlgoritmo\n",
        Profile::Spanish,
    );
    assert!(
        outcome.is_none_or(|found| found.token_identity.as_deref() != Some("clockCapabilityType"))
    );
}
