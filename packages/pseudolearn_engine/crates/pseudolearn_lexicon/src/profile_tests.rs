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
