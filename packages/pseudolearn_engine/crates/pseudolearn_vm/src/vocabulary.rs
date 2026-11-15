#![forbid(unsafe_code)]

pub fn boolean_words(profile: &str) -> (&'static str, &'static str) {
    let lexemes = crate::dispatch::boolean_lexemes(profile);
    (lexemes.truth, lexemes.falsity)
}
