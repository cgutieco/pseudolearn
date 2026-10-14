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
