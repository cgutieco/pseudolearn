use reference_corpus::{LexemeFamily, Lexicon, fold};
use std::collections::BTreeSet;

pub struct Keywords {
    words: BTreeSet<String>,
    phrases: Vec<Vec<String>>,
}

pub fn keyword_set(lexicon: &Lexicon) -> Keywords {
    let mut words = BTreeSet::new();
    let mut phrases = Vec::new();
    let forms = lexicon
        .entries()
        .filter(|entry| {
            matches!(
                entry.family,
                LexemeFamily::Reserved | LexemeFamily::Function
            )
        })
        .flat_map(|entry| {
            std::iter::once(entry.spanish.as_str())
                .chain(entry.spanish_aliases.iter().map(String::as_str))
        });
    for form in forms {
        let parts: Vec<String> = form.split_whitespace().map(fold).collect();
        match parts.as_slice() {
            [] => {}
            [single] => {
                words.insert(single.clone());
            }
            _ => phrases.push(parts),
        }
    }
    Keywords { words, phrases }
}

pub fn skeleton(code: &str, keywords: &Keywords) -> Vec<String> {
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
        if let Some(token) = describe(character, &text) {
            tokens.push(token);
        }
    }
    name_declarations(classify(
        merge_phrases(tokens, &keywords.phrases),
        &keywords.words,
    ))
}

enum Token {
    Word(String),
    Phrase(String),
    Other(String),
}

fn merge_phrases(tokens: Vec<Token>, phrases: &[Vec<String>]) -> Vec<Token> {
    let mut merged = Vec::new();
    let mut position = 0;
    while let Some(token) = tokens.get(position) {
        let matched = phrases.iter().find(|phrase| {
            phrase.iter().enumerate().all(|(offset, word)| {
                matches!(
                    tokens.get(position.saturating_add(offset)),
                    Some(Token::Word(found)) if found == word
                )
            })
        });
        match matched {
            Some(phrase) => {
                merged.push(Token::Phrase(phrase.join(" ")));
                position = position.saturating_add(phrase.len());
            }
            None => {
                merged.push(match token {
                    Token::Word(word) => Token::Word(word.clone()),
                    Token::Phrase(text) => Token::Phrase(text.clone()),
                    Token::Other(text) => Token::Other(text.clone()),
                });
                position = position.saturating_add(1);
            }
        }
    }
    merged
}

fn classify(tokens: Vec<Token>, keywords: &BTreeSet<String>) -> Vec<String> {
    tokens
        .into_iter()
        .map(|token| match token {
            Token::Word(word) if keywords.contains(&word) => word,
            Token::Word(_) => "identifier".to_owned(),
            Token::Phrase(text) | Token::Other(text) => text,
        })
        .collect()
}

fn name_declarations(tokens: Vec<String>) -> Vec<String> {
    let mut named = Vec::new();
    let mut after_algorithm = false;
    for token in tokens {
        named.push(if after_algorithm {
            "identifier".to_owned()
        } else {
            token.clone()
        });
        after_algorithm = token == "algoritmo";
    }
    named
}

fn describe(first: char, text: &str) -> Option<Token> {
    if first.is_whitespace() {
        return None;
    }
    if first == '"' {
        return Some(Token::Other("string".to_owned()));
    }
    if first.is_alphabetic() || first == '_' {
        return Some(Token::Word(fold(text)));
    }
    Some(Token::Other(text.to_owned()))
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
