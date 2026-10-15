use pseudolearn_lexicon::{
    BuiltinKind, KeywordKind, Profile, detect_opener, find_builtin, find_keyword,
    signature_for_builtin,
};

#[test]
fn detects_openers_and_folds_accents_correctly() {
    assert_eq!(detect_opener("Algoritmo"), Some(Profile::Spanish));
    assert_eq!(detect_opener("proceso"), Some(Profile::Spanish));
    assert_eq!(detect_opener("algorithm"), Some(Profile::English));
    assert_eq!(detect_opener("class"), Some(Profile::English));
    assert_eq!(detect_opener("Cláse"), Some(Profile::Spanish));
}

#[test]
fn finds_bilingual_keywords_with_aliases() {
    assert_eq!(
        find_keyword("Definir", Profile::Spanish),
        Some(KeywordKind::Declare)
    );
    assert_eq!(
        find_keyword("define", Profile::English),
        Some(KeywordKind::Declare)
    );
    assert_eq!(
        find_keyword("declare", Profile::English),
        Some(KeywordKind::Declare)
    );
    assert_eq!(
        find_keyword("SiNo", Profile::Spanish),
        Some(KeywordKind::ElseKeyword)
    );
}

#[test]
fn distinguishes_builtins_from_keywords() {
    assert_eq!(
        find_builtin("Longitud", Profile::Spanish),
        Some(BuiltinKind::Length)
    );
    assert_eq!(
        find_builtin("length", Profile::English),
        Some(BuiltinKind::Length)
    );
    let signature = signature_for_builtin(BuiltinKind::Length);
    assert_eq!(signature.arity(), 1);
    assert_eq!(signature.return_type, "integer");
}
