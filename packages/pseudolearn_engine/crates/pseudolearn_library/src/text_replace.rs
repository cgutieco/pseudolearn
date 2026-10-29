#![forbid(unsafe_code)]

pub fn replace_all(text: &str, searched: &str, replacement: &str) -> String {
    if searched.is_empty() {
        return text.to_owned();
    }
    text.replace(searched, replacement)
}

pub fn trim_text(text: &str) -> String {
    text.trim_matches(|character| matches!(character, ' ' | '\t' | '\n' | '\r'))
        .to_owned()
}
