use pseudolearn_lexicon::{BuiltinKind, KeywordKind, Profile};

pub fn keyword_spelling(kind: KeywordKind, profile: Profile) -> String {
    if let Some(preferred) = preferred_spelling(kind, profile) {
        return preferred.to_owned();
    }
    let lexeme = kind.lexeme(profile).unwrap_or("");
    capitalize_words(lexeme)
}

pub fn boolean_spelling(value: bool, profile: Profile) -> String {
    let kind = if value {
        KeywordKind::BooleanTrue
    } else {
        KeywordKind::BooleanFalse
    };
    keyword_spelling(kind, profile)
}

pub fn builtin_spelling(kind: BuiltinKind, profile: Profile) -> String {
    kind.lexeme(profile).unwrap_or("").to_owned()
}

fn preferred_spelling(kind: KeywordKind, profile: Profile) -> Option<&'static str> {
    match (profile, kind) {
        (Profile::Spanish, KeywordKind::Algorithm) => Some("Algoritmo"),
        (Profile::Spanish, KeywordKind::EndAlgorithm) => Some("FinAlgoritmo"),
        (Profile::Spanish, KeywordKind::ElseKeyword) => Some("Sino"),
        _ => None,
    }
}

fn capitalize_words(lexeme: &str) -> String {
    let mut spelled = String::with_capacity(lexeme.len());
    let mut at_word_start = true;
    for character in lexeme.chars() {
        if at_word_start {
            spelled.extend(character.to_uppercase());
        } else {
            spelled.push(character);
        }
        at_word_start = character == ' ';
    }
    spelled
}
