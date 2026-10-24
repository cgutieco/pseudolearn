use pseudolearn_lexicon::{Profile, is_reserved};

#[test]
fn a_word_is_reserved_only_in_its_own_profile() {
    assert!(is_reserved("Mientras", Profile::Spanish));
    assert!(!is_reserved("Mientras", Profile::English));
    assert!(is_reserved("while", Profile::English));
    assert!(!is_reserved("while", Profile::Spanish));
}

#[test]
fn spanish_reserved_words_fold_case_and_accents() {
    assert!(is_reserved("MIENTRAS", Profile::Spanish));
    assert!(is_reserved("mientras", Profile::Spanish));
}

#[test]
fn ordinary_names_and_empty_text_are_not_reserved() {
    assert!(!is_reserved("total", Profile::Spanish));
    assert!(!is_reserved("total", Profile::English));
    assert!(!is_reserved("", Profile::Spanish));
}
