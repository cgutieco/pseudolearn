use std::collections::BTreeMap;

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct FenceOpening {
    pub name: String,
    pub attributes: BTreeMap<String, String>,
}

impl FenceOpening {
    pub fn attribute(&self, key: &str) -> Option<&str> {
        self.attributes.get(key).map(String::as_str)
    }

    pub fn flag(&self, key: &str) -> bool {
        self.attributes.contains_key(key)
    }
}

pub fn parse_fence_opening(line: &str) -> Option<FenceOpening> {
    let rest = line.strip_prefix("```")?.trim();
    let mut words = split_words(rest).into_iter();
    let name = words.next()?;
    let attributes = words.map(|word| split_attribute(&word)).collect();
    Some(FenceOpening { name, attributes })
}

pub fn parse_attributes(text: &str) -> BTreeMap<String, String> {
    split_words(text.trim())
        .iter()
        .map(|word| split_attribute(word))
        .collect()
}

fn split_attribute(word: &str) -> (String, String) {
    match word.split_once('=') {
        Some((key, value)) => (key.to_owned(), value.trim_matches('"').to_owned()),
        None => (word.to_owned(), String::new()),
    }
}

fn split_words(text: &str) -> Vec<String> {
    let mut words = Vec::new();
    let mut current = String::new();
    let mut quoted = false;
    for character in text.chars() {
        match character {
            '"' => {
                quoted = !quoted;
                current.push(character);
            }
            ' ' if !quoted => flush(&mut words, &mut current),
            _ => current.push(character),
        }
    }
    flush(&mut words, &mut current);
    words
}

fn flush(words: &mut Vec<String>, current: &mut String) {
    if !current.is_empty() {
        words.push(std::mem::take(current));
    }
}
