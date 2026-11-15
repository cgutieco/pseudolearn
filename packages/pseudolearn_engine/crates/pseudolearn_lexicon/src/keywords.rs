use crate::profile::Profile;

include!(concat!(env!("OUT_DIR"), "/generated_lexicon.rs"));

pub fn find_keyword(word: &str, profile: Profile) -> Option<KeywordKind> {
    if word.is_ascii() {
        return find_keyword_by_profile(word, profile.as_str());
    }
    let folded_word = profile.fold_word(word);
    find_keyword_by_profile(&folded_word, profile.as_str())
}

pub fn is_reserved(word: &str, profile: Profile) -> bool {
    find_keyword(word, profile).is_some()
}

pub fn find_builtin(word: &str, profile: Profile) -> Option<BuiltinKind> {
    if word.is_ascii() {
        return find_builtin_by_profile(word, profile.as_str());
    }
    let folded_word = profile.fold_word(word);
    find_builtin_by_profile(&folded_word, profile.as_str())
}

pub fn detect_opener(word: &str) -> Option<Profile> {
    [Profile::Spanish, Profile::English]
        .into_iter()
        .find(|profile| {
            detect_profile_from_opener(&profile.fold_word(word)) == Some(profile.as_str())
        })
}

impl KeywordKind {
    pub fn lexeme(&self, profile: Profile) -> Option<&'static str> {
        keyword_lexeme(self.as_str(), profile.as_str())
    }
}

impl BuiltinKind {
    pub fn lexeme(&self, profile: Profile) -> Option<&'static str> {
        builtin_lexeme(self.as_str(), profile.as_str())
    }
}
