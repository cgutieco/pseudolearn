use crate::source_walk::inline_groups;
use reference_corpus::{Corpus, LexemeFamily};
use reference_model::{Inline, Profile, RuleId, SourceDocument, Violation};
use std::collections::BTreeSet;

pub fn check_inline_code(
    document: &SourceDocument,
    corpus: &Corpus,
    language: Profile,
) -> Vec<Violation> {
    let words = reserved_words(corpus, language);
    let mut groups = inline_groups(&document.blocks);
    groups.push(&document.title);
    let mut violations = Vec::new();
    for group in groups {
        for (index, inline) in group.iter().enumerate() {
            let (Inline::Text(text) | Inline::Strong(text) | Inline::Emphasis(text)) = inline
            else {
                continue;
            };
            for word in flagged(text, index == 0, &words) {
                violations.push(Violation::new(
                    RuleId::InlineCode,
                    document.path.clone(),
                    format!("`{word}` is a reserved word and must be written as code"),
                ));
            }
        }
    }
    violations
}

fn reserved_words(corpus: &Corpus, language: Profile) -> BTreeSet<String> {
    corpus
        .lexicon
        .entries()
        .filter(|entry| {
            matches!(
                entry.family,
                LexemeFamily::Reserved | LexemeFamily::Contextual
            )
        })
        .map(|entry| match language {
            Profile::Spanish => entry.spanish.clone(),
            Profile::English => capitalize(&entry.english),
        })
        .filter(|word| word.chars().count() > 1 && word.chars().all(char::is_alphabetic))
        .collect()
}

fn capitalize(word: &str) -> String {
    let mut characters = word.chars();
    characters
        .next()
        .map(|first| first.to_uppercase().chain(characters).collect())
        .unwrap_or_default()
}

fn flagged(text: &str, group_start: bool, words: &BTreeSet<String>) -> Vec<String> {
    let mut found = Vec::new();
    let mut sentence_start = group_start;
    let mut word = String::new();
    for character in text.chars().chain(std::iter::once(' ')) {
        if character.is_alphanumeric() || character == '_' {
            word.push(character);
            continue;
        }
        if !word.is_empty() {
            if words.contains(&word) && (!sentence_start || inner_capital(&word)) {
                found.push(word.clone());
            }
            sentence_start = false;
            word.clear();
        }
        if matches!(character, '.' | '!' | '?' | ':' | '¿' | '¡') {
            sentence_start = true;
        }
    }
    found
}

fn inner_capital(word: &str) -> bool {
    word.chars().skip(1).any(char::is_uppercase)
}
