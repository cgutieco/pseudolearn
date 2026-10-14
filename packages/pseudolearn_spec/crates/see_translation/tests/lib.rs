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

#[test]
fn translates_builtin_calls_without_renaming_variables_or_members() -> Result<(), String> {
    let mut vocabulary = vocabulary();
    vocabulary.insert(
        "function:sine".to_owned(),
        BTreeMap::from([
            ("es".to_owned(), "sen".to_owned()),
            ("en".to_owned(), "sin".to_owned()),
        ]),
    );
    let program = "sen <- 1\nEscribir sen, sen(0), object.sen()\n";
    assert_eq!(
        see_translation::translate(program, "es", "en", &vocabulary)?,
        "sen <- 1\nwrite sen, sin(0), object.sen()\n"
    );
    assert!(see_translation::collisions("sin <- 1", "es", "en", &vocabulary).is_empty());
    Ok(())
}

#[test]
fn canonicalizes_aliases_and_preserves_shadowing_subroutine_names() -> Result<(), String> {
    let mut vocabulary = vocabulary();
    for (identity, spanish, english) in [
        ("algorithm.alias.es.0", "Proceso", "algorithm"),
        ("subroutine", "SubProceso", "subroutine"),
        ("function:sine", "sen", "sin"),
    ] {
        vocabulary.insert(
            identity.to_owned(),
            BTreeMap::from([
                ("es".to_owned(), spanish.to_owned()),
                ("en".to_owned(), english.to_owned()),
            ]),
        );
    }
    let translated = see_translation::translate(
        "Proceso P\nSubProceso sen()\nEscribir sen()\n",
        "es",
        "en",
        &vocabulary,
    )?;
    assert_eq!(translated, "algorithm P\nsubroutine sen()\nwrite sen()\n");
    Ok(())
}
