use crate::Profile;

#[test]
fn detects_opening_after_comments_and_bom() {
    assert_eq!(
        crate::detect_opening_profile("\u{FEFF} // header\n/* next */ Algoritmo Inicio"),
        Some(Profile::Spanish)
    );
    assert_eq!(
        crate::detect_opening_profile("// header\nAlgorithm Start"),
        Some(Profile::English)
    );
}

#[test]
fn rejects_empty_unclosed_and_nonopening_text() {
    assert_eq!(crate::detect_opening_profile(""), None);
    assert_eq!(crate::detect_opening_profile("/* missing"), None);
    assert_eq!(crate::detect_opening_profile("variable <- 1"), None);
}

#[test]
fn detects_every_declared_top_level_opener_in_both_profiles() {
    for (source, profile) in [
        ("interface Shape", Profile::English),
        ("Interfaz Figura", Profile::Spanish),
        ("variant Shape", Profile::English),
        ("Variante Figura", Profile::Spanish),
        ("public subroutine F()", Profile::English),
        ("Publico SubProceso F()", Profile::Spanish),
        ("PRIVATE record R", Profile::English),
        ("Privado Registro R", Profile::Spanish),
        ("enum E", Profile::English),
        ("Constante N", Profile::Spanish),
    ] {
        assert_eq!(
            crate::detect_opening_profile(source),
            Some(profile),
            "{source}"
        );
    }
}

#[test]
fn does_not_treat_contextual_words_that_are_not_openers_as_openers() {
    assert_eq!(crate::detect_opening_profile("defer"), None);
    assert_eq!(crate::detect_opening_profile("vector"), None);
    assert_eq!(crate::detect_opening_profile("p"), None);
}
