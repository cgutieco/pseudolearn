mod support;

use reference_model::Profile;
use reference_verify::check_inline_code;

#[test]
fn flags_reserved_words_outside_code() {
    let violations = check_inline_code(
        &support::fixture("inline-code/concepto.md"),
        &support::corpus(),
        Profile::Spanish,
    );
    let words: Vec<String> = violations
        .iter()
        .map(|violation| violation.detail.clone())
        .collect();
    assert_eq!(violations.len(), 2, "{words:?}");
}

#[test]
fn accepts_code_and_sentence_starts() {
    let violations = check_inline_code(
        &support::fixture("valid/concepto.md"),
        &support::corpus(),
        Profile::Spanish,
    );
    assert!(violations.is_empty(), "{violations:?}");
}
