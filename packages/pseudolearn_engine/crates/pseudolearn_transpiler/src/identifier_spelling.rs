use crate::reserved_names::{PYTHON_RESERVED, RUST_RESERVED};
use crate::reserved_type_names::{PYTHON_TYPES, RUST_TYPES};

fn words(name: &str) -> Vec<String> {
    let mut words: Vec<String> = Vec::new();
    let mut current = String::new();
    let mut previous_lower = false;
    for character in name.chars() {
        if !character.is_alphanumeric() {
            push_word(&mut words, &mut current);
            previous_lower = false;
            continue;
        }
        if character.is_uppercase() && previous_lower {
            push_word(&mut words, &mut current);
        }
        previous_lower = character.is_lowercase() || character.is_numeric();
        current.push(character);
    }
    push_word(&mut words, &mut current);
    words
}

fn push_word(words: &mut Vec<String>, current: &mut String) {
    if !current.is_empty() {
        words.push(std::mem::take(current));
    }
}

fn snake(name: &str) -> String {
    let joined = words(name)
        .iter()
        .map(|word| word.to_lowercase())
        .collect::<Vec<_>>()
        .join("_");
    if joined.is_empty() {
        "value".to_owned()
    } else if joined.starts_with(|character: char| character.is_numeric()) {
        format!("value_{joined}")
    } else {
        joined
    }
}

fn pascal(name: &str) -> String {
    let joined: String = words(name)
        .iter()
        .map(|word| {
            let mut characters = word.chars();
            characters.next().map_or_else(String::new, |first| {
                first.to_uppercase().chain(characters).collect::<String>()
            })
        })
        .collect();
    if joined.is_empty() || joined.starts_with(|character: char| character.is_numeric()) {
        format!("Type{joined}")
    } else {
        joined
    }
}

pub(crate) fn rust_value_name(name: &str) -> String {
    let spelled = snake(name);
    if RUST_RESERVED.contains(&spelled.as_str()) {
        format!("{spelled}_value")
    } else {
        spelled
    }
}

pub(crate) fn python_value_name(name: &str) -> String {
    let spelled = snake(name);
    if PYTHON_RESERVED.contains(&spelled.as_str()) {
        format!("{spelled}_value")
    } else {
        spelled
    }
}

fn guarded_type(spelled: String, reserved: &[&str]) -> String {
    if reserved.contains(&spelled.as_str()) {
        format!("{spelled}Type")
    } else {
        spelled
    }
}

pub(crate) fn rust_type_name(name: &str) -> String {
    guarded_type(pascal(name), RUST_TYPES)
}

pub(crate) fn python_type_name(name: &str) -> String {
    guarded_type(pascal(name), PYTHON_TYPES)
}

pub(crate) fn unique_spellings(
    spell: fn(&str) -> String,
    names: impl Iterator<Item = String>,
) -> Vec<(String, String)> {
    let mut assigned: Vec<(String, String)> = Vec::new();
    for name in names {
        if assigned.iter().any(|(raw, _)| *raw == name) {
            continue;
        }
        let base = spell(&name);
        let mut candidate = base.clone();
        let mut suffix = 2_u32;
        while assigned.iter().any(|(_, taken)| *taken == candidate) {
            candidate = format!("{base}_{suffix}");
            suffix = suffix.saturating_add(1);
        }
        assigned.push((name, candidate));
    }
    assigned
}

pub(crate) fn unique_spelling(
    spell: fn(&str) -> String,
    names: impl Iterator<Item = String>,
    wanted: &str,
) -> String {
    unique_spellings(spell, names)
        .into_iter()
        .find(|(raw, _)| raw == wanted)
        .map_or_else(|| spell(wanted), |(_, spelled)| spelled)
}
