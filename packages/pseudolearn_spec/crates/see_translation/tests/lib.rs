use see_model::contract::Vocabulary;
use std::collections::BTreeMap;

fn vocabulary() -> Vocabulary {
    BTreeMap::from([
        (
            "algorithm".to_owned(),
            BTreeMap::from([
                ("es".to_owned(), "Algoritmo".to_owned()),
                ("en".to_owned(), "algorithm".to_owned()),
            ]),
        ),
        (
            "write".to_owned(),
            BTreeMap::from([
                ("es".to_owned(), "Escribir".to_owned()),
                ("en".to_owned(), "write".to_owned()),
            ]),
        ),
    ])
}

#[test]
fn preserves_comments_literals_and_unicode_identifiers() -> Result<(), String> {
    let program = "Algoritmo P\n Escribir \"Escribir\" // Algoritmo\n nombreÁ <- 1\n";
    let translated = see_translation::translate(program, "es", "en", &vocabulary())?;
    assert_eq!(
        translated,
        "algorithm P\n write \"Escribir\" // Algoritmo\n nombreÁ <- 1\n"
    );
    assert_eq!(
        see_translation::translate(&translated, "en", "es", &vocabulary())?,
        program
    );
    assert_eq!(
        see_translation::translate("", "es", "en", &vocabulary())?,
        ""
    );
    Ok(())
}

#[test]
fn does_not_translate_identifier_suffixes_and_rejects_unclosed_literals() -> Result<(), String> {
    let program = "EscribirTotal <- 1\n nombreEscribir <- 2\n";
    assert_eq!(
        see_translation::translate(program, "es", "en", &vocabulary())?,
        program
    );
    assert!(see_translation::translate("\"Escribir", "es", "en", &vocabulary()).is_err());
    assert!(see_translation::translate("Algoritmo P", "es", "unknown", &vocabulary()).is_err());
    assert_eq!(
        see_translation::collisions("write <- 1", "es", "en", &vocabulary()),
        vec!["write"]
    );
    Ok(())
}
