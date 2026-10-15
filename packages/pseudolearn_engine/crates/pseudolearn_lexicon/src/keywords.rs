use crate::profile::{Profile, fold_text};

include!(concat!(env!("OUT_DIR"), "/generated_lexicon.rs"));

pub fn find_keyword(word: &str, profile: Profile) -> Option<KeywordKind> {
    let folded_word = fold_text(word);
    find_keyword_by_profile(&folded_word, profile.as_str())
}

pub fn find_builtin(word: &str, profile: Profile) -> Option<BuiltinKind> {
    let folded_word = fold_text(word);
    find_builtin_by_profile(&folded_word, profile.as_str())
}

pub fn detect_opener(word: &str) -> Option<Profile> {
    let folded_word = fold_text(word);
    let profile_name = detect_profile_from_opener(&folded_word)?;
    Profile::from_name(profile_name)
}
