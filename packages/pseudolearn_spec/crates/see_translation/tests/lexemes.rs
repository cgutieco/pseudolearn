use see_model::contract::Vocabulary;
use std::collections::BTreeMap;

#[test]
fn resolves_profile_markers_and_rejects_unknown_or_unclosed_markers() -> Result<(), String> {
    let vocabulary: Vocabulary = BTreeMap::from([(
        "booleanTrue".to_owned(),
        BTreeMap::from([
            ("es".to_owned(), "Verdadero".to_owned()),
            ("en".to_owned(), "true".to_owned()),
        ]),
    )]);
    assert_eq!(
        see_translation::lexemes::resolve("{{lexema:booleanTrue}}\n", "es", &vocabulary)?,
        "Verdadero\n"
    );
    assert_eq!(
        see_translation::lexemes::resolve("{{lexema:booleanTrue}}\n", "en", &vocabulary)?,
        "true\n"
    );
    assert!(see_translation::lexemes::resolve("{{lexema:unknown}}", "es", &vocabulary).is_err());
    assert!(see_translation::lexemes::resolve("{{lexema:booleanTrue", "es", &vocabulary).is_err());
    assert_eq!(
        see_translation::lexemes::resolve("", "es", &vocabulary)?,
        ""
    );
    Ok(())
}

#[test]
fn resolves_contextual_identities_when_no_reserved_identity_matches() -> Result<(), String> {
    let profiles = |spanish: &str, english: &str| {
        BTreeMap::from([
            ("es".to_owned(), spanish.to_owned()),
            ("en".to_owned(), english.to_owned()),
        ])
    };
    let vocabulary: Vocabulary = BTreeMap::from([
        (
            "contextual:jsonKindArray".to_owned(),
            profiles("Arreglo", "Array"),
        ),
        ("shared".to_owned(), profiles("Reservada", "reserved")),
        (
            "contextual:shared".to_owned(),
            profiles("Contextual", "contextual"),
        ),
    ]);
    assert_eq!(
        see_translation::lexemes::resolve("{{lexema:jsonKindArray}}", "en", &vocabulary)?,
        "Array"
    );
    assert_eq!(
        see_translation::lexemes::resolve("{{lexema:shared}}", "es", &vocabulary)?,
        "Reservada"
    );
    assert!(
        see_translation::lexemes::resolve("{{lexema:jsonKindArray}}", "fr", &vocabulary).is_err()
    );
    Ok(())
}
