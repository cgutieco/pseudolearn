use pseudolearn_source::IdentifierNormalizer;

#[test]
fn accepts_ascii_and_spanish_identifier_letters() {
    for identifier in [
        "name_2", "ñ", "Ñ", "á", "Á", "é", "É", "í", "Í", "ó", "Ó", "ú", "Ú", "ü", "Ü", "_",
    ] {
        assert!(IdentifierNormalizer::is_valid_identifier(identifier));
    }
}

#[test]
fn validates_the_complete_identifier_after_nfc() {
    assert!(IdentifierNormalizer::is_valid_identifier("n\u{0303}"));
    assert!(IdentifierNormalizer::is_valid_identifier("u\u{0308}"));
    assert!(!IdentifierNormalizer::is_valid_identifier("a\u{0303}"));
    assert!(!IdentifierNormalizer::is_valid_identifier("ç"));
    assert!(!IdentifierNormalizer::is_valid_identifier("α"));
    assert!(!IdentifierNormalizer::is_valid_identifier("\u{0301}"));
    assert!(!IdentifierNormalizer::is_valid_identifier("2name"));
}

#[test]
fn compares_identifiers_after_nfc_without_folding_case_or_accents() {
    assert!(IdentifierNormalizer::equals("an\u{0303}o", "año"));
    assert!(!IdentifierNormalizer::equals("ano", "año"));
    assert!(!IdentifierNormalizer::equals("año", "Año"));
    assert!(!IdentifierNormalizer::equals("ax", "áx"));
}
