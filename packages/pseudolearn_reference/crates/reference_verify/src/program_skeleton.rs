use reference_corpus::{Lexicon, fold};
use std::collections::BTreeSet;

pub fn keyword_set(lexicon: &Lexicon) -> BTreeSet<String> {
    lexicon
        .entries()
        .flat_map(|entry| {
            std::iter::once(entry.spanish.as_str())
                .chain(entry.spanish_aliases.iter().map(String::as_str))
        })
        .flat_map(str::split_whitespace)
        .map(fold)
        .collect()
}

pub fn skeleton(code: &str, keywords: &BTreeSet<String>) -> Vec<String> {
    let characters: Vec<char> = code.chars().collect();
    let mut tokens = Vec::new();
    let mut index = 0;
    while let Some(&character) = characters.get(index) {
        let end = match character {
            '"' => string_end(&characters, index),
            digit if digit.is_ascii_digit() => span_end(&characters, index, is_number_part),
            letter if letter.is_alphabetic() || letter == '_' => {
                span_end(&characters, index, is_word_part)
            }
            _ => index.saturating_add(1),
        };
        let text: String = characters
            .get(index..end)
            .map(|slice| slice.iter().collect())
            .unwrap_or_default();
        index = end;
        if let Some(token) = describe(character, &text, keywords) {
            tokens.push(token);
        }
    }
    tokens
}

fn describe(first: char, text: &str, keywords: &BTreeSet<String>) -> Option<String> {
    if first.is_whitespace() {
        return None;
    }
    if first == '"' {
        return Some("string".to_owned());
    }
    if first.is_alphabetic() || first == '_' {
        let word = fold(text);
        return Some(if keywords.contains(&word) {
            word
        } else {
            "identifier".to_owned()
        });
    }
    Some(text.to_owned())
}

fn string_end(characters: &[char], start: usize) -> usize {
    let mut index = start.saturating_add(1);
    while let Some(&character) = characters.get(index) {
        index = index.saturating_add(1);
        if character == '"' {
            if characters.get(index) == Some(&'"') {
                index = index.saturating_add(1);
                continue;
            }
            break;
        }
    }
    index
}

fn span_end(characters: &[char], start: usize, part: fn(char) -> bool) -> usize {
    let mut index = start;
    while characters
        .get(index)
        .is_some_and(|character| part(*character))
    {
        index = index.saturating_add(1);
    }
    index
}

fn is_number_part(character: char) -> bool {
    character.is_ascii_digit() || character == '.'
}

fn is_word_part(character: char) -> bool {
    character.is_alphanumeric() || character == '_'
}
