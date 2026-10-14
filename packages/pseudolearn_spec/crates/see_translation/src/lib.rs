#![forbid(unsafe_code)]

pub mod lexemes;

use see_model::contract::Vocabulary;

pub fn translate(
    program: &str,
    source: &str,
    target: &str,
    vocabulary: &Vocabulary,
) -> Result<String, String> {
    if source == target {
        return Ok(program.to_owned());
    }
    let mut pairs = Vec::new();
    for profiles in vocabulary.values() {
        let original = profiles.get(source).ok_or("Missing source vocabulary")?;
        let translated = profiles.get(target).ok_or("Missing target vocabulary")?;
        pairs.push((original.as_str(), translated.as_str()));
    }
    pairs.sort_by_key(|(original, _)| std::cmp::Reverse(original.len()));
    reprint(program, &pairs)
}

fn reprint(program: &str, pairs: &[(&str, &str)]) -> Result<String, String> {
    let mut output = String::new();
    let mut remaining = program;
    while !remaining.is_empty() {
        if remaining.starts_with("//") {
            let end = remaining.find('\n').unwrap_or(remaining.len());
            let (comment, tail) = remaining.split_at(end);
            output.push_str(comment);
            remaining = tail;
        } else if remaining.starts_with(['"', '\'']) {
            let (literal, tail) = quoted(remaining)?;
            output.push_str(literal);
            remaining = tail;
        } else {
            remaining = token(remaining, pairs, &mut output);
        }
    }
    Ok(output)
}

fn quoted(remaining: &str) -> Result<(&str, &str), String> {
    let delimiter = remaining.chars().next().ok_or("Empty literal")?;
    let mut escaped = false;
    for (offset, character) in remaining.char_indices().skip(1) {
        if character == delimiter && !escaped {
            let end = offset
                .checked_add(character.len_utf8())
                .ok_or("Source offset overflow")?;
            return Ok(remaining.split_at(end));
        }
        escaped = character == '\\' && !escaped;
    }
    Err("SEE-TRANSLATION: unterminated literal needs explicit profile program".to_owned())
}

fn token<'source>(
    remaining: &'source str,
    pairs: &[(&str, &str)],
    output: &mut String,
) -> &'source str {
    for (original, translated) in pairs {
        let prefix = remaining.get(..original.len());
        let tail = remaining.get(original.len()..);
        if prefix.is_some_and(|prefix| prefix.eq_ignore_ascii_case(original))
            && tail.is_some_and(|tail| {
                !tail.starts_with(|character: char| character.is_alphanumeric() || character == '_')
            })
        {
            output.push_str(translated);
            return tail.unwrap_or("");
        }
    }
    let length = token_length(remaining);
    let (head, tail) = remaining.split_at(length);
    output.push_str(head);
    tail
}

pub fn collisions(
    program: &str,
    source: &str,
    target: &str,
    vocabulary: &Vocabulary,
) -> Vec<String> {
    let source_words: Vec<_> = vocabulary
        .values()
        .filter_map(|profiles| profiles.get(source))
        .map(|word| word.to_lowercase())
        .collect();
    let target_words: Vec<_> = vocabulary
        .values()
        .filter_map(|profiles| profiles.get(target))
        .map(|word| word.to_lowercase())
        .collect();
    words(program)
        .into_iter()
        .filter(|word| {
            target_words.contains(&word.to_lowercase())
                && !source_words.contains(&word.to_lowercase())
        })
        .map(str::to_owned)
        .collect()
}

fn token_length(remaining: &str) -> usize {
    if remaining.starts_with(|character: char| character.is_alphanumeric() || character == '_') {
        return remaining
            .char_indices()
            .find(|(_, character)| !character.is_alphanumeric() && *character != '_')
            .map_or(remaining.len(), |(offset, _)| offset);
    }
    remaining.chars().next().map_or(0, char::len_utf8)
}

fn words(program: &str) -> Vec<&str> {
    let mut remaining = program;
    let mut words = Vec::new();
    while !remaining.is_empty() {
        if remaining.starts_with("//") {
            remaining = remaining
                .get(remaining.find('\n').unwrap_or(remaining.len())..)
                .unwrap_or("");
            continue;
        }
        if remaining.starts_with(['"', '\'']) {
            let Ok((_, tail)) = quoted(remaining) else {
                break;
            };
            remaining = tail;
            continue;
        }
        let (word, tail) = remaining.split_at(token_length(remaining));
        if word.starts_with(|character: char| character.is_alphabetic() || character == '_') {
            words.push(word);
        }
        remaining = tail;
    }
    words
}
